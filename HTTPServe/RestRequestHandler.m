//
//  RestRequestHandler.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <JSON/SBJsonParser.h>

#import "RestRequestHandler.h"
#import "SystemUtil.h"
#import "ClassHolder.h"
#import "RestResource.h"
#import "Response.h"
#import "Request.h"
#import "ResourceDescriptor.h"
#import "NotFoundHandler.h"

@interface RestRequestHandler(private)
- (ResourceDescriptor*) descriptorForRequest: (Request*) request;
@end

@implementation RestRequestHandler

- (id)init
{
  self = [super init];
  if (self) 
  {
    resources = [[NSMutableArray alloc] init];
    resourceDescriptors = [[NSMutableArray alloc] init];
    parser = [[SBJsonParser alloc] init];
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
  NSArray *classes = [SystemUtil getClassesConformingToProcol:@protocol(RestResource)];
  for(ClassHolder *holder in classes)
  {
    Class class = [holder clazz];
    id<RestResource> handler = [class new];
    if(class_respondsToSelector(class, @selector(initialize)))
    {
      [handler initialize];
    }
    [resourceDescriptors addObjectsFromArray: [handler resourceDescriptors]];
    [resources addObject:handler];
  }
}

- (Response*) handleRequest:(Request *)request
{
  ResourceDescriptor *descriptor = [self descriptorForRequest: request];
  Response *response;
  if(descriptor != nil)
  {
    NSObject *jsonObject = [parser objectWithData:[request body]];
    id<RestResource> resource = [descriptor resource];
    response = [resource performSelector:[descriptor selector] withObject: jsonObject];
  }
  else
  {
    response = [Response NOT_FOUND_RESPONSE];
  }
  return response;
}

- (NSArray *) paths
{
  NSMutableArray *paths = [NSMutableArray arrayWithCapacity:[resourceDescriptors count]];
  for(ResourceDescriptor *descriptor in resourceDescriptors)
  {
    [paths addObject:[descriptor path]];
  }
  return paths;
}

- (ResourceDescriptor*) descriptorForRequest: (Request*) request
{
  for(ResourceDescriptor *descriptor in resourceDescriptors)
  {
    if([descriptor method] == [request method] && [[request path] caseInsensitiveCompare: [descriptor path]] == 0)
    {
      return descriptor;
    }
  }
  return nil;
}

@end
