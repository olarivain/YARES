//
//  HTTPConnection.m
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPConnection.h"

@interface HTTPConnection(private)
- (void) dataReceived: (NSNotification*) notification;
- (void) headerDataReceived;
- (void) bodyDataReceived: (NSData*) data;
- (void) close;
@end

@implementation HTTPConnection

#pragma mark Constructor/Destructor

- (id)initWithFileHandle: (NSFileHandle*) handle
{
    self = [super init];
    if (self) {
      fileHandle = [handle retain];
      request = NULL;
      headerReceived = NO;
      bodyReceived = NO;
      contentLength = -1;
      readLength = 0;
      
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
  if(request){
    CFRelease(request);
  }
  [fileHandle dealloc];
  
  [super dealloc];
}

#pragma mark Clean up
- (void) close{
  [fileHandle closeFile];
  [requestData release];
  [requestHeaders release];
  // TODO dispatch "connection done" event.
}


- (void) dataReceived: (NSNotification*) notification{
  NSData *data = [[notification userInfo] objectForKey:
                  NSFileHandleNotificationDataItem];
  // no data, connection reset, close connection.
  if ( [data length] == 0 ) {
    [self close];
  } else {
    // keep reading in background while we process this chunk.
    [fileHandle readInBackgroundAndNotify];
    
    // create reqest if needed.
    if(request == NULL){
      request = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
    }
    
    readLength += [data length];

    // try to read
    Boolean success = CFHTTPMessageAppendBytes(request, [data bytes], [data length]);
    if( success ) {

      // process HTTP Header if not fully received yet.
      if(!headerReceived){
        [self headerDataReceived];
      } 
      
      if(headerReceived){
        [self bodyDataReceived: data];
      }
      
      if(bodyReceived){
        CFRelease(request);
        request = NULL;
        NSLog(@"Processing request");
        // TODO: process content here.
      }
     
    } else{
       NSLog(@"Could not read from request.");
      [self close];
    }
  }
}

- (void) headerDataReceived{
  if( CFHTTPMessageIsHeaderComplete(request) ) {
    // build headers dictionary
    headerReceived = YES;
    requestHeaders = (NSDictionary*) CFHTTPMessageCopyAllHeaderFields(request);
  
    // if content length is set, store it, otherwise mark message as received.
    NSString *headerContentLength = (NSString*) [requestHeaders objectForKey:@"Content-Length"];
    if(headerContentLength){
       contentLength = [headerContentLength integerValue];
    }
  }
}

- (void) bodyDataReceived:(NSData *)data{
  // content length -1 means no request body
  if(contentLength == -1){
     bodyReceived = YES;
    return;
  }

  if(contentLength <= readLength){
    requestData = (NSData*) CFHTTPMessageCopyBody(request);
    bodyReceived = YES;
  }
}

@end
