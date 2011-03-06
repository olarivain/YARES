//
//  HTTPConnection.h
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"

@class Response;
@class RequestHandlerRegistry;
@class HTTPServe;

@interface HTTPConnection : NSObject <NSStreamDelegate>
{
@private
  HTTPServe *httpServer;
  RequestHandlerRegistry *handlerRegistry;
  
  NSData *peerAddress;
  NSInputStream *istream;
  NSOutputStream *ostream;
  
  Request *request;
  Response *response;
  CFHTTPMessageRef requestRef;
  BOOL headerReceived;
  BOOL bodyReceived;
  NSInteger contentLength;
  int bytesRead;
}

- (id)initWithPeerAddress:(NSData *)address inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr forServer:(HTTPServe *)server andRegistry: (RequestHandlerRegistry*) registry;
@end
