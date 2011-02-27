//
//  Response.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
  OK,
  CREATED,
  NO_CONTENT,
  MOVED_PERMANENTLY,
  BAD_REQUEST,
  FORBIDDEN,
  NOT_FOUND,
  INTERNAL_SERVER_ERROR,
  UNAVAILABLE
  
} ResponseCode;

@interface Response : NSObject 
{
@private
  NSMutableDictionary *headers;
  ResponseCode responseCode;
  id<NSObject, NSCoding> content;
    
}

@property (readwrite, assign) ResponseCode responseCode;
@property (readwrite, retain) id<NSObject, NSCoding> content;
@property (readonly) NSDictionary *headers;

- (void) addHeader: (id) value forKey: (NSString*) key;
- (void) removeHeader: (id) key;
- (int) httpResponseCode;
@end
