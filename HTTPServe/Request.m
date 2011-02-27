//
//  Request.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Request.h"


@implementation Request

- (id) initWithHeaders: (NSDictionary*) header parameters: (NSDictionary*) params body: (NSData*) content url: (NSURL*) requestedURL andMethod: (HttpMethod) requestMethod
{
  self = [super init];
  if (self) {
    headers = [header retain];
    parameters = [params retain];
    body = [content retain];
    url = [requestedURL retain];
    method = requestMethod;
  }
  
  return self;
}

- (void)dealloc
{
  [headers release];
  [parameters release];
  [body release];
  [url release];
  [super dealloc];
}

@synthesize headers;
@synthesize parameters;
@synthesize body;
@synthesize url;
@synthesize method;

- (NSString*) getContentType
{
  return [headers objectForKey: @"Content-Type"];
}
- (NSString*) getContentLength
{
  return [headers objectForKey: @"Content-Length"];
}

- (NSString*) path
{
  return [url relativePath];
}


@end
