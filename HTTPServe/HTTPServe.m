//
//  HTTPServe.m
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPServe.h"
#import "HTTPConnection.h"

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
  }
  
  return self;
}

- (void)dealloc
{
  [super dealloc];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [fileHandle closeFile];
  [fileHandle dealloc];
  [socketPort dealloc];
}

- (void) start{
  socketPort = [[NSSocketPort alloc] initWithTCPPort:listenPort];
  fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:[socketPort socket] closeOnDealloc:TRUE];
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(newConnection:)
             name:NSFileHandleConnectionAcceptedNotification
           object:nil];
  
  [fileHandle acceptConnectionInBackgroundAndNotify];
}

- (void) newConnection:(NSNotification *)notification{
  NSDictionary *userInfo = [notification userInfo];
  NSFileHandle *remoteFileHandle = [userInfo objectForKey:
                                    NSFileHandleNotificationFileHandleItem];
  
  NSNumber *errorNo = [userInfo objectForKey:@"NSFileHandleError"];
  if( errorNo ) {
    NSLog(@"NSFileHandle Error: %@", errorNo);
    return;
  }
  
  [fileHandle acceptConnectionInBackgroundAndNotify];
  
  if( remoteFileHandle ) {
    HTTPConnection *connection = [[HTTPConnection alloc] initWithFileHandle:remoteFileHandle];
    if( connection ) {
      NSIndexSet *insertedIndexes;
      insertedIndexes = [NSIndexSet indexSetWithIndex:
                         [connections count]];
      [self willChange:NSKeyValueChangeInsertion
       valuesAtIndexes:insertedIndexes forKey:@"connections"];
      [connections addObject:connection];
      [self didChange:NSKeyValueChangeInsertion
      valuesAtIndexes:insertedIndexes forKey:@"connections"];
      [connection release];
    }
  }
}

@end
