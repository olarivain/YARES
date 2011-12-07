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
  NSDictionary *__strong headers;
  NSDictionary *__strong parameters;
  NSDictionary *pathParameters;
  NSData *__strong body;
  NSURL *__strong url;
  HSHttpMethod method;
}

@property (readonly) NSDictionary *headers;
@property (readonly) NSDictionary *parameters;
@property (nonatomic, readwrite, strong) NSDictionary *pathParameters;
@property (readonly) NSData *body;
@property (readonly) NSURL *url;
@property (readonly) HSHttpMethod method;

- (id) initWithHeaders: (NSDictionary*) header parameters: (NSDictionary*) parameters body: (NSData*) content url: (NSURL*) requestedURL andMethod: (HSHttpMethod) requestMethod;

- (NSString*) getContentType;
- (NSString*) getContentLength;
- (NSString*) path;

@end
