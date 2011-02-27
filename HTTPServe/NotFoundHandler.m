//
//  NotFoundHandler.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotFoundHandler.h"
#import "Response.h"

@implementation NotFoundHandler

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSArray*) urls
{
  return [NSArray array];
}

- (Response*) handleRequest: (Request*) request
{
  Response *response = [[Response alloc] init];
  [response setResponseCode: NOT_FOUND];
  
  NSString *content = @"This page was not found.";
  [response setContent:[content dataUsingEncoding:NSUTF8StringEncoding]];
  
  return response;
}

@end
