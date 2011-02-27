//
//  Response.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ResponseCode;

@interface Response : NSObject 
{
@private
  NSMutableDictionary *headers;
  ResponseCode *responseCode;
  NSData *content;
    
}

@property (readwrite, retain) ResponseCode *responseCode;
@property (readwrite, retain) NSData *content;
@property (readonly) NSDictionary *headers;

- (NSUInteger) contentLength;
- (NSString*) contentLengthAsString;

- (void) setContentType: (NSString*) type;

- (void) addHeader: (NSString*) value forKey: (NSString*) key;
- (void) removeHeader: (NSString*) key;

+ (Response*) NOT_FOUND_RESPONSE;
+ (Response*) INTERNAL_SERVER_ERROR_RESPONSE;
+ (Response*) UNAVAILABLE_RESPONSE;
@end
