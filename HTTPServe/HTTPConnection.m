//
//  HTTPConnection.m
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPConnection.h"
#import "HTTPServeProtected.h"
#import "Response.h"
#import "ResponseCode.h"
#import "RequestHandler.h"
#import "RequestHandlerRegistry.h"
#import "HttpMethod.h"

@interface HTTPConnection(private)
- (void) initRequest;
- (void) handleRequest;

- (CFHTTPMessageRef) initHTTPResponse;
- (void) readRequest: (NSData*) data;
- (void) writeResponse;
- (void) close;

- (void) headerDataReceived;
- (void) bodyDataReceived;

@end

@implementation HTTPConnection

#pragma mark Constructor/Destructor

- (id)initWithPeerAddress:(NSData *)address inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr forServer:(HTTPServe *)server andRegistry: (RequestHandlerRegistry*) registry
{
    self = [super init];
    if (self) 
    {
      handlerRegistry = [registry retain];
      peerAddress = [address copy];
      httpServer = [server retain];
      
      istream = [istr retain];
      ostream = [ostr retain];
      
      [istream setDelegate:self];
      [ostream setDelegate:self];
      
      [istream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:(id)kCFRunLoopCommonModes];
      [ostream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:(id)kCFRunLoopCommonModes];
      
      [istream open];
      [ostream open];
    }
    
    return self;
}

- (void)dealloc
{
  [self close];
  [request release];
  [response release];
  [peerAddress release];
  [httpServer release];
  [handlerRegistry release];
  [super dealloc];
}

#pragma mark - Clean up
- (void) close 
{
  [istream close];
  [ostream close];
  [istream release];
  [ostream release];
  istream = nil;
  ostream = nil;
  [httpServer connectionHandled: self];
}

#pragma mark - NSStreamDelegate methods
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent 
{
  switch(streamEvent) {
    case NSStreamEventHasBytesAvailable:;
      // read from stream
      uint8_t tempBuffer[16 * 1024];
      NSInteger lengthRead = [istream read:tempBuffer maxLength:sizeof(tempBuffer)];
      if (lengthRead > 0) 
      {
        // if we actually read, pass the NSData to the read hanler method
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
      // the end of the stream has been found, close
      [self close];
      break;
    case NSStreamEventErrorOccurred:
      // network issue, same thing, close
      [self close];
      break;
    default:
      break;
  }
}

#pragma mark - Stream I/O methods
- (void) readRequest: (NSData*) data 
{
  // create request if it hasn't been done yet
  if(requestRef == nil)
  {
    requestRef = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
  }

  // append incoming bytes and increment bytes read counter accordingly
  CFHTTPMessageAppendBytes(requestRef, [data bytes], [data length]);
  bytesRead += [data length];
  
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
    NSString *headerContentLength = [(NSString*) CFHTTPMessageCopyHeaderFieldValue(requestRef, (CFStringRef) @"Content-Length") autorelease];
    if(headerContentLength)
    {
      // store content lenght for body processing
      contentLength = [headerContentLength integerValue];
    }
  }
}

- (void) bodyDataReceived
{
  // body is received if there was none or if we read at least as many bytes
  // as the content length specified.
  bodyReceived = (contentLength <= 0) || (contentLength <= bytesRead);
}

- (void)writeResponse
{
  // outputstream is not ready, bail out.
  if (![ostream hasSpaceAvailable]) 
  {
    return;
  }
  
  // create CF http message, serialize and write
  CFHTTPMessageRef cfResponse = [self initHTTPResponse];
  NSData *serialized = [(NSData *)CFHTTPMessageCopySerializedMessage(cfResponse) autorelease];
  NSUInteger length = [serialized length];
  if (0 < length) 
  {
    [ostream write:[serialized bytes] maxLength:length];
  }
  
  // clean up memory and close this connection
  CFRelease(cfResponse);
  [self close];
}

- (void) initRequest
{
  NSURL *url = [(NSURL*) CFHTTPMessageCopyRequestURL(requestRef) autorelease];
  NSString *methodString = [(NSString*) CFHTTPMessageCopyRequestMethod(requestRef) autorelease];
  HttpMethod method = methodFromString(methodString);
  NSDictionary *headers = [(NSDictionary*) CFHTTPMessageCopyAllHeaderFields(requestRef) autorelease];
  NSData *data = [(NSData*) CFHTTPMessageCopyBody(requestRef) autorelease];
  
  NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
  // this is weird. [url parameterString] returns nil. Seems like the URL is built with no protocol/host.
  // hence, the manual parsing of the string.
  NSArray *split = [[url absoluteString] componentsSeparatedByString:@"?"];
  NSString *paramsString = [split count] > 1 ? [split objectAtIndex:1] : nil;
  NSArray *paramsArray = [paramsString componentsSeparatedByString:@"&"];
  for(NSString *paramString in paramsArray)
  {
    NSArray *paramArray = [paramString componentsSeparatedByString:@"="];
    NSString *key = [paramArray objectAtIndex:0];
    NSString *value = [paramArray count] > 1 ? [paramArray objectAtIndex:1] : @"";
    [requestParameters setObject:value forKey:key];
  }
  
  request = [[Request alloc] initWithHeaders:headers parameters:requestParameters body:data url: url  andMethod:method];
  CFRelease(requestRef);
}

- (CFHTTPMessageRef) initHTTPResponse
{
  // copy response object into CFHttpMessage struct
  CFHTTPMessageRef cfResponse = CFHTTPMessageCreateResponse(kCFAllocatorDefault, [response code], NULL, kCFHTTPVersion1_1);
  NSDictionary *headers = [response headers];
  for(NSString *key in [headers keyEnumerator])
  {
    NSString *value = [headers objectForKey: key];
    CFHTTPMessageSetHeaderFieldValue(cfResponse, (CFStringRef) key, (CFStringRef) value);
  }
  CFHTTPMessageSetHeaderFieldValue(cfResponse, (CFStringRef) @"Content-Length", (CFStringRef) [response contentLengthAsString]);
  CFHTTPMessageSetBody(cfResponse, (CFDataRef) [response content]);
  
  return cfResponse;
}


#pragma mark - Request handling
- (void) handleRequest
{
  // find handler for incoming url, or grab 404 handler if not found
  id<RequestHandler> handler = [handlerRegistry handlerForURL:[request url]];
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
    // exception maps to 500
    response = [Response INTERNAL_SERVER_ERROR_RESPONSE];
  }
  [response retain];
}
@end
