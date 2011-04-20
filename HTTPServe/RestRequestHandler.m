//
//  RestRequestHandler.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SBJsonParser.h"

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
    id<RestResource> handler = [[class new] autorelease];
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
    NSObject *params;
    if([request method] != GET)
    {
      params = [parser objectWithData:[request body]];  
    }
    else
    {
      params = [request parameters];
    }
    
    id<RestResource> resource = [descriptor resource];
    response = [resource performSelector:[descriptor selector] withObject: params];
    if(response == nil)
    {
      response = [Response EMPTY_RESPONSE];
    }
  }
  else
  {
    response = [Response NOT_FOUND_RESPONSE];
  }
  
#warning FIXME: content type should be parametrizable
  [response setContentType:@"application/json"];
  
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
  NSLog(@"No descriptor found for method: %i and path: %@", [request method], [request path]);
  return nil;
}

@end
