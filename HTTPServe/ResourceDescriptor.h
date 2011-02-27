//
//  ResourceDescriptor.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HttpMethod.h"
#import "RestResource.h"

@interface ResourceDescriptor : NSObject {
@private
  NSString *path;
  HttpMethod method;
  SEL selector;
  id<RestResource> resource;
}

- (id) initWithPath: (NSString*) resourcePath resource: (id<RestResource>) resource andSelector: (SEL) sel;
- (id)initWithPath: (NSString*) resourcePath resource: (id<RestResource>) resource selector: (SEL) sel andMethod: (HttpMethod) resourceMethod;

@property (readonly) NSString *path;
@property (readonly) HttpMethod method;
@property (readonly) SEL selector;
@property (readonly) id<RestResource> resource;

@end
