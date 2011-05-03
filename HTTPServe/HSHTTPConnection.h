//
//  HTTPConnection.h
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSRequest.h"

@class HSResponse;
@class HSRequestHandlerRegistry;
@class HSHTTPServe;

@interface HSHTTPConnection : NSObject <NSStreamDelegate>
{
@private
  HSHTTPServe *httpServer;
  HSRequestHandlerRegistry *handlerRegistry;
  
  NSData *peerAddress;
  NSInputStream *istream;
  NSOutputStream *ostream;
  
  HSRequest *request;
  HSResponse *response;
  CFHTTPMessageRef requestRef;
  BOOL headerReceived;
  BOOL bodyReceived;
  NSInteger contentLength;
  int bytesRead;
}

- (id)initWithPeerAddress:(NSData *)address inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr forServer:(HSHTTPServe *)server andRegistry: (HSRequestHandlerRegistry*) registry;

// starts listening and getting content from the client, then processes it.
- (void) processRequest;
@end
