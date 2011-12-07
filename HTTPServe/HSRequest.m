//
//  Request.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HSRequest.h"


@implementation HSRequest

- (id) initWithHeaders: (NSDictionary*) header parameters: (NSDictionary*) params body: (NSData*) content url: (NSURL*) requestedURL andMethod: (HSHttpMethod) requestMethod
{
  self = [super init];
  if (self) {
    headers = header;
    parameters = params;
    body = content;
    url = requestedURL;
    method = requestMethod;
  }
  
  return self;
}


@synthesize headers;
@synthesize parameters;
@synthesize pathParameters;
@synthesize body;
@synthesize url;
@synthesize method;

#pragma mark - Synthetic getters
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
