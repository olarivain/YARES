//
//  RestRequestHandler.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SBJsonParser.h"

#import "HSRestRequestHandler.h"
#import "HSSystemUtil.h"
#import "HSClassHolder.h"
#import "HSRestResource.h"
#import "HSResponse.h"
#import "HSRequest.h"
#import "HSResourceDescriptor.h"
#import "HSNotFoundHandler.h"

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
      params = [parser objectWithData:[request body]];  
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
  
#warning FIXME: content type should be parametrizable
  [response setContentType:@"application/json"];
  
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
    if([descriptor method] == [request method] && [[request path] caseInsensitiveCompare: [descriptor path]] == 0)
    {
      return descriptor;
    }
  }
  NSLog(@"No descriptor found for method: %i and path: %@", [request method], [request path]);
  return nil;
}

@end
