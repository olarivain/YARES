//
//  HTTPConnection.h
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"
@class RequestHandlerRegistry;
@class RequestBuilder;
@interface HTTPConnection : NSObject 
{
@private
  NSFileHandle *fileHandle;
  
  RequestHandlerRegistry *handlerRegistry;
  
  long contentLength;
  long readLength;
  
  BOOL headerReceived;
  BOOL bodyReceived;
  
  CFHTTPMessageRef cfRequest;
  Request *request;
  
  RequestBuilder *requestBuilder;
}

- (id) initWithFileHandle: (NSFileHandle*) handle handlerRegistry: (RequestHandlerRegistry*) registry;

@end
