//
//  HTTPServe.h
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RequestHandlerRegistry;

/*
 * <p>HTTPServe is the class implenting the server.<br/>
 * Instance of this class are built passing the port number the server will be listening to.
 * Server then has to be explicitly started by sending the start message.<br/></p>
 * <p>On start up, the server will do the following:
 * <ul>
 *   <li>Send it's HandlerRegistry object the "autoregister" signal. This will scan the class path
 * for classes implementing RequestHandler protocol, instantiate them and register them.</li>
 *  <li>Open an NSSocketPort on provided port, and create a NSFileHandle on it</li>
 *  <li>Start listening on this file handle and register for incoming connection notifications</li>
 * </ul>
 * </p>
 *
 * <p>The server can be stopped by sending the stop signal. This will do the following:
 * <ul>
 *   <li>Send its RequestHandlerRegistry object the "unregisterRequestHandlers" message. This message will 
 * unregister all handlers. As a result handlers will be released (and most certainly freed)</li>
 *  <li>Close and release NSSocketPort and NSFileHandle</li>
 * </ul>
 * </p>
 */
@class HTTPConnection;

@interface HTTPServe : NSObject 
{
@private
  int listenPort;
  NSSocketPort *socketPort;
  NSFileHandle *fileHandle;
  NSMutableArray *connections;
  RequestHandlerRegistry *handlerRegistry;
}

- (HTTPServe*) initWithPort: (int) port;
- (void) start;
- (void) stop;

- (void) connectionHandled: (HTTPConnection*) connection;

@end
