//
//  ResourceDescriptor.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HSResourceDescriptor.h"
#import "HSHandlerPath.h"

@implementation HSResourceDescriptor

+ (id) descriptorWithPath: (NSString*) resourcePath resource: (id<HSRestResource>) parent andSelector: (SEL) sel;
{
  HSHandlerPath *handlerPath = [HSHandlerPath handlerPath: resourcePath];
  return [HSResourceDescriptor descriptorWithHandlerPath:handlerPath resource: parent selector: sel andMethod: GET];
}

+ (id) descriptorWithHandlerPath: (HSHandlerPath*) resourcePath resource: (id<HSRestResource>) resource andSelector: (SEL) sel
{
  return [HSResourceDescriptor descriptorWithHandlerPath:resourcePath resource:resource selector:sel andMethod: GET];
}

+ (id)descriptorWithPath: (NSString*) resourcePath resource: (id<HSRestResource>) parent selector: (SEL) sel andMethod: (HSHttpMethod) resourceMethod;
{
  HSHandlerPath *handlerPath = [HSHandlerPath handlerPath: resourcePath];
  return [HSResourceDescriptor descriptorWithHandlerPath:handlerPath resource:parent selector:sel andMethod: GET];
}

+ (id) descriptorWithHandlerPath: (HSHandlerPath*) resourcePath resource: (id<HSRestResource>) parent selector: (SEL) sel andMethod: (HSHttpMethod) resourceMethod
{
  HSResourceDescriptor *descriptor = [[[HSResourceDescriptor alloc] init] autorelease];
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
