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
#import "RequestHandler.h"
#import "RequestHandlerRegistry.h"

@interface HTTPConnection(private)
- (void) dataReceived: (NSNotification*) notification;
- (void) headerDataReceived;
- (void) bodyDataReceived: (NSData*) data;
- (void) close;
- (void) handleRequest;
- (Response*) get404Response;
- (void) writeResponse: (Response*) response;
@end

@implementation HTTPConnection

#pragma mark Constructor/Destructor

- (id)initWithFileHandle: (NSFileHandle*) handle handlerRegistry:(RequestHandlerRegistry *)registry
{
    self = [super init];
    if (self) 
    {
      fileHandle = [handle retain];
      request = NULL;
      headerReceived = NO;
      bodyReceived = NO;
      contentLength = -1;
      readLength = 0;
      handlerRegistry = [registry retain];
      
      NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
      [nc addObserver:self
             selector:@selector(dataReceived:)
                 name:NSFileHandleReadCompletionNotification
               object:fileHandle];

      [fileHandle readInBackgroundAndNotify];
    }
    
    return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  if(request)
  {
    CFRelease(request);
  }
  [handlerRegistry release];
  [url release];
  [fileHandle release];
  
  [super dealloc];
}

#pragma mark Clean up
- (void) close{
  [fileHandle closeFile];
  [requestData release];
  [requestHeaders release];
  // TODO notify http serve that connection is closed
}


- (void) dataReceived: (NSNotification*) notification
{
  NSData *data = [[notification userInfo] objectForKey:
                  NSFileHandleNotificationDataItem];
  // no data, connection reset, close connection.
  if ( [data length] == 0 ) 
  {
    [self close];
  } else 
  {
    // keep reading in background while we process this chunk.
    [fileHandle readInBackgroundAndNotify];
    
    // create reqest if needed.
    if(request == NULL)
    {
      request = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
    }
    
    readLength += [data length];

    // try to read
    Boolean success = CFHTTPMessageAppendBytes(request, [data bytes], [data length]);
    if( success ) 
    {

      // process HTTP Header if not fully received yet.
      if(!headerReceived)
      {
        [self headerDataReceived];
      } 
      
      if(headerReceived)
      {
        [self bodyDataReceived: data];
      }
      
      if(bodyReceived)
      {
        CFRelease(request);
        request = NULL;
        [self handleRequest];
      }
     
    } else
    {
       NSLog(@"Could not read from request.");
      [self close];
    }
  }
}

- (void) headerDataReceived{
  if( CFHTTPMessageIsHeaderComplete(request) ) 
  {
    // build headers dictionary
    headerReceived = YES;
    requestHeaders = (NSDictionary*) CFHTTPMessageCopyAllHeaderFields(request);
    url = (NSURL*) CFHTTPMessageCopyRequestURL(request);
  
    // if content length is set, store it, otherwise mark message as received.
    NSString *headerContentLength = (NSString*) [requestHeaders objectForKey:@"Content-Length"];
    if(headerContentLength)
    {
       contentLength = [headerContentLength integerValue];
    }
  }
}

- (void) bodyDataReceived:(NSData *)data
{
  // content length -1 means no request body
  if(contentLength == -1)
  {
     bodyReceived = YES;
    return;
  }

  if(contentLength <= readLength)
  {
    requestData = (NSData*) CFHTTPMessageCopyBody(request);
    bodyReceived = YES;
  }
}

- (void) handleRequest
{
  id<RequestHandler> handler = [handlerRegistry handlerForURL:url];
  if(handler == nil)
  {
    handler = [handlerRegistry notFoundHandler];
  }
  
  Response *response = [handler handleRequest:requestHeaders body:requestData];
  [self writeResponse:response];
  
  [self close];
}

- (void) writeResponse: (Response*) response
{
  CFHTTPMessageRef cfResponse = CFHTTPMessageCreateResponse(kCFAllocatorDefault, [response httpResponseCode], NULL, kCFHTTPVersion1_1);
  
  CFHTTPMessageSetBody(cfResponse, (CFDataRef) [response content]);
  CFDataRef cfResponseData = CFHTTPMessageCopySerializedMessage(cfResponse);
  @try {
    [fileHandle writeData:(NSData *) cfResponseData];
  }
  @catch (NSException *exception) {
    NSLog(@"Error while writing data on file handle");
  }
  CFRelease(cfResponse);
  CFRelease(cfResponseData);
}

@end
