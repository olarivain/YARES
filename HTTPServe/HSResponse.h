//
//  Response.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSResponseCode.h"

@interface HSResponse : NSObject 
{
@private
  NSMutableDictionary *headers;
  HSResponseCode code;
  NSData *content;
  id object;
}

@property (nonatomic,readwrite, assign) HSResponseCode code;
@property (readonly) NSDictionary *headers;
@property (nonatomic,readwrite, retain) NSData *content;
@property (nonatomic, readwrite, retain) id object;

+ (HSResponse*) response;
+ (HSResponse*) jsonResponse;
+ (HSResponse*) errorResponse;
+ (HSResponse*) emptyResponse;

- (id) init;
- (id)initWithContentType: (NSString*) contentType;

- (NSUInteger) contentLength;
- (NSString*) contentLengthAsString;

- (void) setStringContent: (NSString*) content;

- (void) setContentType: (NSString*) type;
- (void) setContentEncoding: (NSString*) encoding;

- (void) addHeader: (NSString*) value forKey: (NSString*) key;
- (void) removeHeader: (NSString*) key;

+ (HSResponse*) NOT_FOUND_RESPONSE;
+ (HSResponse*) UNAVAILABLE_RESPONSE;


@end
