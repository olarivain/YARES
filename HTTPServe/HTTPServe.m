//
//  HTTPServe.m
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPServeProtected.h"
#import "HTTPConnection.h"
#import "RequestHandlerRegistry.h"

@interface HTTPServe(private)
- (void) newConnection: (NSNotification*) notification;
@end

@implementation HTTPServe

- (id)initWithPort: (int) port
{
  self = [super init];
  if (self) {
    listenPort = port;
    connections = [[NSMutableArray alloc] init];
    handlerRegistry = [[RequestHandlerRegistry alloc] init];
  }
  
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if(fileHandle)
  {
    [fileHandle closeFile];
    [fileHandle release];
  }
  
  if(socketPort)
  {
    [socketPort invalidate];
    [socketPort release];
  }
  
  [handlerRegistry release];
  [super dealloc];
}

- (void) start
{
  [handlerRegistry autoregister];
  socketPort = [[NSSocketPort alloc] initWithTCPPort:listenPort];
  if(!socketPort)
  {
    NSLog(@"Error, could not create socketPort");
  }
  fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:[socketPort socket] closeOnDealloc:TRUE];
  if(!fileHandle)
  {
    NSLog(@"could not create file handle");
  }
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(newConnection:)
             name:NSFileHandleConnectionAcceptedNotification
           object:nil];
  
  [fileHandle acceptConnectionInBackgroundAndNotify];
}

- (void) newConnection:(NSNotification *)notification
{
  NSDictionary *userInfo = [notification userInfo];
  NSFileHandle *remoteFileHandle = [userInfo objectForKey:
                                    NSFileHandleNotificationFileHandleItem];
  
  NSNumber *errorNo = [userInfo objectForKey:@"NSFileHandleError"];
  if( errorNo ) 
  {
    NSLog(@"NSFileHandle Error: %@", errorNo);
    return;
  }
  
  [fileHandle acceptConnectionInBackgroundAndNotify];
  
  if( remoteFileHandle ) 
  {
    HTTPConnection *connection = [[HTTPConnection alloc] initWithFileHandle:remoteFileHandle handlerRegistry: handlerRegistry];
    if( connection ) 
    {
      [connections addObject:connection];
      [connection release];
    }
  }
}

- (void) connectionHandled: (HTTPConnection*) connection{
  [connections removeObject: connection];
}


- (void) stop
{
  [fileHandle closeFile];
  [fileHandle release];
  [socketPort invalidate];
  [socketPort release];
}

@end
