//
//  Request.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HttpMethod.h"

@interface Request : NSObject {
@private
  NSDictionary *headers;
  NSData *body;
  NSURL *url;
  HttpMethod method;
}

@property (readonly) NSDictionary *headers;
@property (readonly) NSData *body;
@property (readonly) NSURL *url;
@property (readonly) HttpMethod method;

- (id) initWithHeaders: (NSDictionary*) header body: (NSData*) content url: (NSURL*) requestedURL andMethod: (HttpMethod) requestMethod;

- (NSString*) getContentType;
- (NSString*) getContentLength;
- (NSString*) path;

@end
