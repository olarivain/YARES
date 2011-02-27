//
//  ResourceDescriptor.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResourceDescriptor.h"


@implementation ResourceDescriptor

- (id) initWithPath: (NSString*) resourcePath resource: (id<RestResource>) parent andSelector: (SEL) sel;
{
  return [self initWithPath:resourcePath resource: parent selector: sel andMethod: GET];
}

- (id)initWithPath: (NSString*) resourcePath resource: (id<RestResource>) parent selector: (SEL) sel andMethod: (HttpMethod) resourceMethod;
{
  self = [super init];
  if (self) 
  {
    path = resourcePath;
    method = resourceMethod;
    selector = sel;
    resource = [parent retain];
  }
  
  return self;
}

- (void)dealloc
{
  [path release];
  [resource release];
  [super dealloc];
}

@synthesize path;
@synthesize method;
@synthesize selector;
@synthesize resource;
@end
