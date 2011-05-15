//
//  RequestHandlerRegistry.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <objc/objc-runtime.h>
#import "HSRequestHandlerRegistry.h"
#import "HSSystemUtil.h"
#import "HSClassHolder.h"
#import "HSNotFoundHandler.h"
#import "HSRestRequestHandler.h"
#import "HSHandlerPath.h"

@interface HSRequestHandlerRegistry()
@end

@implementation HSRequestHandlerRegistry

- (id)init
{
    self = [super init];
    if (self) 
    {
      handlers = [[NSMutableArray alloc] initWithCapacity:10];
      notFoundHandler = [[HSNotFoundHandler alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
  [notFoundHandler release];
  [super dealloc];
}

- (void) bootstrapClasses
{
  [HSRestRequestHandler class];
}

@synthesize notFoundHandler;

- (void) autoregister
{
  NSLog(@"Autoregistering handlers...");
  NSArray *classes = [HSSystemUtil getClassesConformingToProcol: @protocol(HSRequestHandler)];
  for(HSClassHolder *classHolder in classes)
  {
    Class class = [classHolder clazz];
    // don't register built in handlers, obviously...
    if(class != [HSNotFoundHandler class])
    {
      id<HSRequestHandler> handler = [[class new] autorelease];
      if(class_respondsToSelector(class, @selector(initialize)))
      {
        [handler initialize];
      }
      [self registerHandler: handler];
    }
  }
}

- (void) registerHandler: (id<HSRequestHandler>) handler
{
  if(![handlers containsObject: handler])
  {
    [handlers addObject:handler];
  }
}

- (void) unregisterHandler: (id<HSRequestHandler>) handler
{
  [handlers removeObject: handler];
}

- (void) unregisterRequestHandlers
{
  while([handlers count] > 0)
  {
    id<HSRequestHandler> handler = [handlers objectAtIndex:0];
    [self unregisterHandler:handler];
  }
}

- (id<HSRequestHandler>) handlerForURL: (NSURL*) url
{
  // and attempt to match it to all declared handlers 
  for(id<HSRequestHandler> handler in handlers)
  {
    NSArray *urls = [handler paths];
    for(HSHandlerPath *handlerPath in urls)
    {
      if([handlerPath handlesURL: url])
      {
        return handler;
      }
    } 
  }
  return nil;
}

@end
