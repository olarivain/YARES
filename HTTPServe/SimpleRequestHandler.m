//
//  SimpleRequestHandler.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SimpleRequestHandler.h"


@implementation SimpleRequestHandler

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

- (Response*) handleRequest: (NSDictionary*) headers body: (NSData*) data{
  return nil;
}

@end
