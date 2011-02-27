//
//  ResponseCode.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ResponseCode : NSObject {
@private
  int code;
}

- (id) initWithCode: (int) responseCode;

@property (readonly) int code;

+ (ResponseCode*) OK;
+ (ResponseCode*) CREATED;
+ (ResponseCode*) NO_CONTENT;
+ (ResponseCode*) MOVED_PERMANENTLY;
+ (ResponseCode*) BAD_REQUEST;
+ (ResponseCode*) FORBIDDEN;
+ (ResponseCode*) NOT_FOUND;
+ (ResponseCode*) INTERNAL_SERVER_ERROR;
+ (ResponseCode*) UNAVAILABLE;


@end
