//
//  HTTPServe.m
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPServe.h"

@interface HTTPServe(private)
- (void) newConnection: (NSNotification*) notification;
@end

@implementation HTTPServe

- (id)initWithPort: (int) port
{
  self = [super init];
  if (self) {
    listenPort = port;
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
  
}

@end
