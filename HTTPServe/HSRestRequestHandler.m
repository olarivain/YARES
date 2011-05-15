//
//  RestRequestHandler.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JSONKit.h"

#import "HSRestRequestHandler.h"
#import "HSSystemUtil.h"
#import "HSClassHolder.h"
#import "HSRestResource.h"
#import "HSResponse.h"
#import "HSRequest.h"
#import "HSResourceDescriptor.h"
#import "HSNotFoundHandler.h"
#import "HSHandlerPath.h"

@interface HSRestRequestHandler(private)
- (HSResourceDescriptor*) descriptorForRequest: (HSRequest*) request;
@end

@implementation HSRestRequestHandler

- (id)init
{
  self = [super init];
  if (self) 
  {
    resources = [[NSMutableArray alloc] init];
    resourceDescriptors = [[NSMutableArray alloc] init];
    decoder = [[JSONDecoder decoder] retain];
  }
  
  return self;
}

- (void)dealloc
{
  [resources release];
  [resourceDescriptors release];
  [super dealloc];
}

- (void) initialize
{
  NSArray *classes = [HSSystemUtil getClassesConformingToProcol:@protocol(HSRestResource)];
  for(HSClassHolder *holder in classes)
  {
    Class class = [holder clazz];
    id<HSRestResource> handler = [[class new] autorelease];
    if(class_respondsToSelector(class, @selector(initialize)))
    {
      [handler initialize];
    }
    [resourceDescriptors addObjectsFromArray: [handler resourceDescriptors]];
    [resources addObject:handler];
  }
}

- (HSResponse*) handleRequest:(HSRequest *)request
{
  HSResourceDescriptor *descriptor = [self descriptorForRequest: request];
  HSResponse *response;
  if(descriptor != nil)
  {
    NSObject *params;
    if([request method] != GET)
    {
      params = [decoder objectWithData: [request body]];
    }
    else
    {
      params = [request parameters];
    }
    
    id<HSRestResource> resource = [descriptor resource];
    response = [resource performSelector:[descriptor selector] withObject: params];
    if(response == nil)
    {
      response = [HSResponse EMPTY_RESPONSE];
    }
  }
  else
  {
    response = [HSResponse NOT_FOUND_RESPONSE];
  }
  
  return response;
}

- (NSArray *) paths
{
  NSMutableArray *paths = [NSMutableArray arrayWithCapacity:[resourceDescriptors count]];
  for(HSResourceDescriptor *descriptor in resourceDescriptors)
  {
    [paths addObject:[descriptor path]];
  }
  return paths;
}

- (HSResourceDescriptor*) descriptorForRequest: (HSRequest*) request
{
  for(HSResourceDescriptor *descriptor in resourceDescriptors)
  {
    if(descriptor.method == request.method)
    {
      if([descriptor.path handlesURL: request.url])
      {
        return descriptor;
      }
    }
  }
  NSLog(@"No descriptor found for method: %i and path: %@", [request method], [request path]);
  return nil;
}

@end
