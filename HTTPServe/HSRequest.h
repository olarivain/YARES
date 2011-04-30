//
//  Request.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HSHttpMethod.h"

@interface HSRequest : NSObject {
@private
  NSDictionary *headers;
  NSDictionary *parameters;
  NSData *body;
  NSURL *url;
  HSHttpMethod method;
}

@property (readonly) NSDictionary *headers;
@property (readonly) NSDictionary *parameters;
@property (readonly) NSData *body;
@property (readonly) NSURL *url;
@property (readonly) HSHttpMethod method;

- (id) initWithHeaders: (NSDictionary*) header parameters: (NSDictionary*) parameters body: (NSData*) content url: (NSURL*) requestedURL andMethod: (HSHttpMethod) requestMethod;

- (NSString*) getContentType;
- (NSString*) getContentLength;
- (NSString*) path;

@end
