//
//  HTTPConnection.m
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HSHTTPConnection.h"
#import "HSResponse.h"
#import "HSResponseCode.h"
#import "HSRequestHandler.h"
#import "HSRequestHandlerRegistry.h"
#import "HSHttpMethod.h"
#import "HSHTTPServe.h"
#import "NSURL+HTTPServe.h"
#import "HSHandlerPath.h"

#define MAX_OUTPUT_BUFFER_SIZE 1024

@interface HSHTTPConnection(private)
- (void) initRequest;
- (void) handleRequest;

- (CFHTTPMessageRef) initHTTPResponse;
- (void) readRequest: (NSData*) data;
- (void) writeResponse;
- (void) close;

- (void) headerDataReceived;
- (void) bodyDataReceived;

@end

@implementation HSHTTPConnection

#pragma mark Constructor/Destructor

- (id)initWithPeerAddress:(NSData *)address inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr forServer:(HSHTTPServe *)server andRegistry: (HSRequestHandlerRegistry*) registry
{
    self = [super init];
    if (self) 
    {
      handlerRegistry = registry;
      peerAddress = [address copy];

      httpServer = server;
      
      istream = istr;
      ostream = ostr;
      
      [istream setDelegate:self];
      [ostream setDelegate:self];
    }
    
    return self;
}

- (void)dealloc
{
  [self close];
}

#pragma mark - Clean up
- (void) close 
{
  [istream close];
  [istream removeFromRunLoop:[NSRunLoop currentRunLoop]
                    forMode:NSDefaultRunLoopMode];
  [ostream close];
  [ostream removeFromRunLoop:[NSRunLoop currentRunLoop]
                     forMode:NSDefaultRunLoopMode];
  istream = nil;
  ostream = nil;
  [httpServer connectionHandled: self];
}

#pragma mark - Process the request
- (void) processRequest
{
  NSRunLoop *current = [NSRunLoop currentRunLoop];

  
  [istream scheduleInRunLoop: current forMode:(id)kCFRunLoopCommonModes];
  [ostream scheduleInRunLoop:current forMode:(id)kCFRunLoopCommonModes];
  [istream open];
  [ostream open];
  
  // this gives the client .5 seconds to start sending shit on the stream.
  // After that, he's dead. Too little, too late, RIP.
  [current runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 60]];
}

#pragma mark - NSStreamDelegate methods
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent 
{
  switch(streamEvent) {
    case NSStreamEventHasBytesAvailable:;
      // read from stream
      // default to 16k buffer
      uint8_t tempBuffer[16 * 1024];
      NSInteger lengthRead = [istream read:tempBuffer maxLength:sizeof(tempBuffer)];
      if (lengthRead > 0) 
      {
        // if we actually read, pass the NSData to the read handler method
        NSData *data = [NSData dataWithBytes:tempBuffer length:lengthRead];
        [self readRequest: data];
      }
      
      break;
    case NSStreamEventHasSpaceAvailable:
      // output stream is now available, write response if we already have it,
      // otherwise it will be written after the request has been handled
      if(stream == ostream && response != nil)
      {
        [self writeResponse];
      }
      break;
    case NSStreamEventEndEncountered:
      NSLog(@"end encountered");
      // the end of the stream has been found, close
      [self close];
      break;
    case NSStreamEventErrorOccurred:
      // network issue, same thing, close
      [self close];
      break;
    default:
//      NSLog(@"default has happened");
      break;
  }
}

#pragma mark - Stream I/O methods
- (void) readRequest: (NSData*) data 
{
  // create request if it hasn't been done yet
  if(requestRef == nil)
  {
    requestRef = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, YES);
  }

  // append incoming bytes and increment bytes read counter accordingly
  BOOL didAppend = CFHTTPMessageAppendBytes(requestRef, [data bytes], [data length]);
  if(didAppend)
  {
    bodyBytesRead += [data length];
  }
  
  // process headers
  if(!headerReceived)
  {
    [self headerDataReceived];
  }
  // then body
  if(!bodyReceived)
  {
    [self bodyDataReceived];
  }

  // request is complete: process it
  if(bodyReceived)
  {
    [self initRequest];
    [self handleRequest];
    
    // outputstream is already available, write the response then
    if([ostream hasSpaceAvailable])
    {
      [self writeResponse];
    }
  }
}

- (void) headerDataReceived
{
  // build headers dictionary if headers are received
  if(CFHTTPMessageIsHeaderComplete(requestRef)) 
  {
    headerReceived = YES;
    // if content length is set, store it, otherwise mark message as received.
    NSString *headerContentLength = (__bridge_transfer NSString*) CFHTTPMessageCopyHeaderFieldValue(requestRef, (CFStringRef) @"Content-Length");
    if(headerContentLength)
    {
      // store content lenght for body processing
      contentLength = [headerContentLength integerValue];
      
      // the chunk we just received might contain bytes for the body, figure out how much of the body has been read by
      // copying the current body and counting its length.
      NSData *incompleteRequest = (__bridge_transfer NSData *) CFHTTPMessageCopyBody(requestRef);
      bodyBytesRead = [incompleteRequest length];
      incompleteRequest = nil;
    }
  }
}

- (void) bodyDataReceived
{
  // body is received if there was none or if we read at least as many bytes
  // as the content length specified.
  bodyReceived = (contentLength <= 0) || (contentLength <= bodyBytesRead);
}

- (void)writeResponse
{
  // outputstream is not ready, bail out.
  if (![ostream hasSpaceAvailable]) 
  {
    return;
  }
  
  // create CF http message, serialize and write response on stream
  CFHTTPMessageRef cfResponse = [self initHTTPResponse];
  NSData *serialized = (__bridge_transfer NSData *)CFHTTPMessageCopySerializedMessage(cfResponse);
  
  NSUInteger offset = 0;
  NSUInteger remainingLength = [serialized length];
  NSUInteger bufferSize = MIN(MAX_OUTPUT_BUFFER_SIZE, remainingLength);
  
  // write in burst of MAX_OUTPUT_BUFFER_SIZE
  void *bytes = malloc(bufferSize * sizeof(void*));
  while (remainingLength > 0) {
    NSRange range = NSMakeRange(offset, bufferSize);
    [serialized getBytes:bytes range: range];
    
    NSInteger bytesWritten = [ostream write:bytes maxLength:bufferSize];
    if(bytesWritten == -1)
    {
      // TODO: figure out a decent error handling here
      break;
    }
    remainingLength -= bytesWritten;
    offset += bytesWritten;
    // update buffer size, required when remainingLength becomes smaller than max output size
    bufferSize = MIN(MAX_OUTPUT_BUFFER_SIZE, remainingLength);
  }
  
  // don't forget to clean up behind :)
  free(bytes);
  CFRelease(cfResponse);
  
  [self close];
}

- (void) initRequest
{
  NSURL *url = (__bridge_transfer NSURL*) CFHTTPMessageCopyRequestURL(requestRef);
  
  // HTTP method first
  NSString *methodString = (__bridge_transfer NSString*) CFHTTPMessageCopyRequestMethod(requestRef);
  HSHttpMethod method = methodFromString(methodString);
  // now headers
  NSDictionary *headers = (__bridge_transfer NSDictionary*) CFHTTPMessageCopyAllHeaderFields(requestRef);
  // query parameters
  NSDictionary *requestParameters = [url queryParameters];
  // payload
  NSData *data = (__bridge_transfer NSData*) CFHTTPMessageCopyBody(requestRef);
  request = [[HSRequest alloc] initWithHeaders:headers parameters:requestParameters body:data url: url  andMethod:method];
  CFRelease(requestRef);
}

- (CFHTTPMessageRef) initHTTPResponse
{
  // create lousy core foundation objects
  CFHTTPMessageRef cfResponse = CFHTTPMessageCreateResponse(kCFAllocatorDefault, [response code], NULL, kCFHTTPVersion1_1);
  
  // don't forget to copy response headers
  NSDictionary *headers = [response headers];
  for(NSString *key in [headers keyEnumerator])
  {
    NSString *value = [headers objectForKey: key];
    CFHTTPMessageSetHeaderFieldValue(cfResponse, (__bridge CFStringRef) key, (__bridge CFStringRef) value);
  }
  
  // compute content length now
  CFHTTPMessageSetHeaderFieldValue(cfResponse, (CFStringRef) @"Content-Length", (__bridge CFStringRef) [response contentLengthAsString]);
  // and copy payload to response
  CFHTTPMessageSetBody(cfResponse, (__bridge CFDataRef) [response content]);
  
  return cfResponse;
}


#pragma mark - Request handling
- (void) handleRequest
{
  // find handler for incoming url, or grab 404 handler if not found
  id<HSRequestHandler> handler = [handlerRegistry handlerForURL:[request url]];

  if(handler == nil)
  {
    handler = [handlerRegistry notFoundHandler];
  }
  
  @try 
  {
    // run handler
    response = [handler handleRequest: request];  
  } 
  @catch (NSException *exception) 
  {
    NSLog(@"It happened, again.");
    // exception maps to 500
    response = [HSResponse errorResponse];
    NSData *error = [[exception reason] dataUsingEncoding:NSUTF8StringEncoding];
    response.content = error;
  }
}
@end
