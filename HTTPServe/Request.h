//
//  Request.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Request : NSObject {
@private
  NSDictionary *headers;
  NSData *body;
  NSURL *url;
}

@property (readonly) NSDictionary *headers;
@property (readonly) NSData *body;
@property (readonly) NSURL *url;

- (id) initWithHeaders: (NSDictionary*) header body: (NSData*) content andURL: (NSURL*) requestedURL;

- (NSString*) getContentType;
- (NSString*) getContentLength;

@end
