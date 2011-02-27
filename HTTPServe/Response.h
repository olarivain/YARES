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
  id<NSObject, NSCoding> content;
    
}

@property (readwrite, retain) ResponseCode *responseCode;
@property (readwrite, retain) id<NSObject, NSCoding> content;
@property (readonly) NSDictionary *headers;

- (void) addHeader: (id) value forKey: (NSString*) key;
- (void) removeHeader: (id) key;
@end
