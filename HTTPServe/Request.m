//
//  Request.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Request.h"


@implementation Request

- (id) initWithHeaders: (NSDictionary*) header body: (NSData*) content andURL: (NSURL*) requestedURL
{
  self = [super init];
  if (self) {
    headers = [header retain];
    body = [content retain];
    url = requestedURL;
  }
  
  return self;
}

- (void)dealloc
{
  [headers release];
  [body release];
  [url release];
  [super dealloc];
}

@synthesize headers;
@synthesize body;
@synthesize url;

- (NSString*) getContentType
{
  return [headers objectForKey: @"Content-Type"];
}
- (NSString*) getContentLength
{
  return [headers objectForKey: @"Content-Length"];
}


@end
