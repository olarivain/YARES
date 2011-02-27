//
//  NotFoundHandler.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotFoundHandler.h"
#import "Response.h"
#import "ResponseCode.h"

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
  return [Response NOT_FOUND_RESPONSE];
}

@end
