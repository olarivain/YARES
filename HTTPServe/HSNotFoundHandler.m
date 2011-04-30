//
//  NotFoundHandler.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HSNotFoundHandler.h"
#import "HSResponse.h"
#import "HSResponseCode.h"

@implementation HSNotFoundHandler

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

- (NSArray*) paths
{
  return [NSArray array];
}

- (HSResponse*) handleRequest: (HSRequest*) request
{
  return [HSResponse NOT_FOUND_RESPONSE];
}

@end
