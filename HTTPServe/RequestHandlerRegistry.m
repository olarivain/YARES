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
#import "SimpleRequestHandler.h"
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
  NSLog(@"Autoregistering...");
  NSArray *classes = [SystemUtil getAllRegisteredClasses];
  for(ClassHolder *classHolder in classes)
  {
    Class class = [classHolder clazz];
    // don't register SimpleRequestHandler, obviously...
    if(class != [SimpleRequestHandler class] && class != [NotFoundHandler class] 
       && class_conformsToProtocol(class, @protocol(RequestHandler)) )
    {
      id<RequestHandler> handler = [class new];
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

- (id<RequestHandler>) handlerForURL: (NSURL*) url
{
  NSString *relativePath = [url relativePath];
  for(id<RequestHandler> handler in handlers)
  {
    NSArray *urls = [handler urls];
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
