//
//  ResourceDescriptor.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HSHttpMethod.h"
#import "HSRestResource.h"

@class HSHandlerPath;

@interface HSResourceDescriptor : NSObject {
@private
  HSHandlerPath *path;

  HSHttpMethod method;
  SEL selector;
  id<HSRestResource> resource;
}

+ (id) descriptorWithPath: (NSString*) resourcePath resource: (id<HSRestResource>) resource andSelector: (SEL) sel;
+ (id) descriptorWithPath: (NSString*) resourcePath resource: (id<HSRestResource>) resource selector: (SEL) sel andMethod: (HSHttpMethod) resourceMethod;

@property (readwrite, strong) HSHandlerPath *path;
@property (readwrite, assign) HSHttpMethod method;
@property (readwrite, assign) SEL selector;
@property (readwrite, strong) id<HSRestResource> resource;

@end
