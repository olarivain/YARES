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
#import "HSRequestParameters.h"

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
  // Crawl through all classes implementing our fancy HSRestResource protocol
  NSArray *classes = [HSSystemUtil getClassesConformingToProcol:@protocol(HSRestResource)];
  for(HSClassHolder *holder in classes)
  {
    // instantiate those dudes. 
    // Yes. IoC a la ObjectiveC.
    Class class = [holder clazz];
    id<HSRestResource> handler = [[class new] autorelease];
    
    // initialize if the object responds to selector
    if(class_respondsToSelector(class, @selector(initialize)))
    {
      [handler initialize];
    }
    
    // keep track of the resource
    [resourceDescriptors addObjectsFromArray: [handler resourceDescriptors]];
    [resources addObject:handler];
  }
}

- (HSResponse*) handleRequest:(HSRequest *)request
{
  // get a grip on the resource descriptor, if any
  HSResourceDescriptor *descriptor = [self descriptorForRequest: request];
  
  // return a 404 if we have nobody handling the resource. Shouldn't happen though,
  // we wouldn't have gottent the request if we didn't have a handler.
  if(descriptor == nil)
  {
    return [HSResponse NOT_FOUND_RESPONSE];
  }
  
  // figure out where the params come from: body or query string,
  // depending on HTTP Method.
  NSObject *params;
  if([request method] != GET)
  {
    params = [decoder objectWithData: [request body]];
  }
  else
  {
    params = [request parameters];
  }
  
  // TODO this piece of code could be useful for all handlers, not just the rest ones
  // figure out how to move it out to HSHTTPConnection
  // Extract path parameters and merge with request parameters.
  HSHandlerPath *handlerPath = descriptor.path;
  NSDictionary *pathParameters = [handlerPath pathParametersForURL: [request.url relativePath]];
  
  HSRequestParameters *requestParameters = [HSRequestParameters requestParmetersWithPathParameters:pathParameters andParamters:params];
  
  // call appropriate selector on resource with the parsed params
  id<HSRestResource> resource = [descriptor resource];
  HSResponse *response = [resource performSelector:[descriptor selector] withObject: requestParameters];
  
  // fail back to 204 No Content if no response was supplied by resource.
  if(response == nil)
  {
    response = [HSResponse EMPTY_RESPONSE];
  }
  
  return response;
}

- (NSArray *) paths
{
  // aggregate resources descriptors and return their HSHAndlerPath objects
  NSMutableArray *paths = [NSMutableArray arrayWithCapacity:[resourceDescriptors count]];
  for(HSResourceDescriptor *descriptor in resourceDescriptors)
  {
    [paths addObject:[descriptor path]];
  }
  return paths;
}

- (HSResourceDescriptor*) descriptorForRequest: (HSRequest*) request
{
  // look for the first resource that will handle the request
  NSString *relativePath = [request.url relativePath];
  for(HSResourceDescriptor *descriptor in resourceDescriptors)
  {
    if(descriptor.method == request.method)
    {
      if([descriptor.path handlesPath: relativePath])
      {
        return descriptor;
      }
    }
  }
  NSLog(@"No descriptor found for method: %i and path: %@", [request method], [request path]);
  return nil;
}

@end
