//
//  RestRequestHandler.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RestRequestHandler.h"


@implementation RestRequestHandler

- (id)init
{
  self = [super init];
  if (self) 
  {
    resources = [[NSMutableArray alloc] init];
  }
  
  return self;
}

- (void)dealloc
{
  [resources release];
  [super dealloc];
}

- (void) initialize
{
  // Scan for classes implementing protocol here
}

- (NSArray *) urls
{
  return nil;
}

@end
