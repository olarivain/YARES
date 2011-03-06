//
//  RequestHandlerRegistry.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <objc/objc-runtime.h>
#import "RequestHandlerRegistry.h"
#import "SystemUtil.h"
#import "ClassHolder.h"
#import "NotFoundHandler.h"

@interface RequestHandlerRegistry(private)
@end

@implementation RequestHandlerRegistry

- (id)init
{
    self = [super init];
    if (self) 
    {
      handlers = [[NSMutableArray alloc] initWithCapacity:10];
      notFoundHandler = [[NotFoundHandler alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
  [notFoundHandler release];
  [super dealloc];
}

@synthesize notFoundHandler;

- (void) autoregister
{
  NSLog(@"Autoregistering handlers...");
  NSArray *classes = [SystemUtil getClassesConformingToProcol: @protocol(RequestHandler)];
  for(ClassHolder *classHolder in classes)
  {
    Class class = [classHolder clazz];
    // don't register built in handlers, obviously...
    if(class != [NotFoundHandler class])
    {
      id<RequestHandler> handler = [[class new] autorelease];
      if(class_respondsToSelector(class, @selector(initialize)))
      {
        [handler initialize];
      }
      [self registerHandler: handler];
    }
  }
}

- (void) registerHandler: (id<RequestHandler>) handler
{
  if(![handlers containsObject: handler])
  {
    [handlers addObject:handler];
  }
}

- (void) unregisterHandler: (id<RequestHandler>) handler
{
  [handlers removeObject: handler];
}

- (void) unregisterRequestHandlers
{
  while([handlers count] > 0)
  {
    id<RequestHandler> handler = [handlers objectAtIndex:0];
    [self unregisterHandler:handler];
  }
}

- (id<RequestHandler>) handlerForURL: (NSURL*) url
{
  NSString *relativePath = [url relativePath];
  for(id<RequestHandler> handler in handlers)
  {
    NSArray *urls = [handler paths];
    for(NSString *url in urls)
    {
      if([url isEqualToString: relativePath])
      {
        return handler;
      }
    } 
  }
  return nil;
}

@end
