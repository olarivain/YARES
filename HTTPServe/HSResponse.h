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
@property (nonatomic,readwrite, retain) NSData *content;
@property (readonly) NSDictionary *headers;
@property (nonatomic, readwrite, retain) id object;

- (NSUInteger) contentLength;
- (NSString*) contentLengthAsString;

- (void) setStringContent: (NSString*) content;

- (void) setContentType: (NSString*) type;
- (void) setContentEncoding: (NSString*) encoding;

- (void) addHeader: (NSString*) value forKey: (NSString*) key;
- (void) removeHeader: (NSString*) key;

+ (HSResponse*) response;

+ (HSResponse*) NOT_FOUND_RESPONSE;
+ (HSResponse*) INTERNAL_SERVER_ERROR_RESPONSE;
+ (HSResponse*) UNAVAILABLE_RESPONSE;
+ (HSResponse*) EMPTY_RESPONSE;

@end
