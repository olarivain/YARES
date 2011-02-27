//
//  Request.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
  GET,
  PUT,
  POST,
  DELETE
} Method;

@interface Request : NSObject {
@private
  NSDictionary *headers;
  NSData *body;
  NSURL *url;
  Method method;
}

@property (readonly) NSDictionary *headers;
@property (readonly) NSData *body;
@property (readonly) NSURL *url;
@property (readonly) Method method;

- (id) initWithHeaders: (NSDictionary*) header body: (NSData*) content url: (NSURL*) requestedURL andMethod: (Method) requestMethod;

- (NSString*) getContentType;
- (NSString*) getContentLength;

@end
