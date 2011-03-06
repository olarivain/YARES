//
//  ResourceDescriptor.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResourceDescriptor.h"


@implementation ResourceDescriptor

+ (id) descriptorWithPath: (NSString*) resourcePath resource: (id<RestResource>) parent andSelector: (SEL) sel;
{
  return [ResourceDescriptor descriptorWithPath:resourcePath resource: parent selector: sel andMethod: GET];
}

+ (id)descriptorWithPath: (NSString*) resourcePath resource: (id<RestResource>) parent selector: (SEL) sel andMethod: (HttpMethod) resourceMethod;
{
  ResourceDescriptor *descriptor = [[[ResourceDescriptor alloc] init] autorelease];
  if (descriptor) 
  {
    descriptor.path = resourcePath;
    descriptor.method = resourceMethod;
    descriptor.selector = sel;
    descriptor.resource = [parent retain];
  }
  
  return descriptor;
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
