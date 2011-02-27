//
//  Response.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Response.h"
#import "ResponseCode.h"

static Response *NOT_FOUND_RESPONSE;
static Response *INTERNAL_SERVER_ERROR_RESPONSE;
static Response *NOT_AVAILABLE_RESPONSE;
static Response *EMPTY_RESPONSE;

@implementation Response

@synthesize code;
@synthesize content;
@synthesize headers;

- (id)init
{
    self = [super init];
    if (self) {
      code = OK;
    }
    
    return self;
}

- (void)dealloc
{
  [content release];
  [headers release];
  [super dealloc];
}

- (void) addHeader:(NSString*)value forKey:(NSString *)key{
  if(headers == nil){
    headers = [[NSMutableDictionary alloc] init];
  }
  
  [headers setObject:value forKey:key];
}

- (void) removeHeader:(NSString*)key{
  [headers removeObjectForKey: key];
}

- (void) setContentType: (NSString*) type
{
  [self addHeader:type forKey:@"Content-Type"];
}

- (NSUInteger) contentLength
{
  return [content length];
}
- (NSString*) contentLengthAsString
{
  return [NSString stringWithFormat:@"%i", [self contentLength]];
}

- (void) setStringContent: (NSString*) stringContent
{
  self.content = [stringContent dataUsingEncoding:NSUTF8StringEncoding];
}

+ (Response*) EMPTY_RESPONSE
{
  if(EMPTY_RESPONSE == nil)
  {
    EMPTY_RESPONSE = [[Response alloc] init];
    [EMPTY_RESPONSE setCode: OK];
  }
  return EMPTY_RESPONSE;
}

+ (Response*) NOT_FOUND_RESPONSE
{
  if(NOT_FOUND_RESPONSE == nil)
  {
    NOT_FOUND_RESPONSE = [[Response alloc] init];
    [NOT_FOUND_RESPONSE setCode: NOT_FOUND];
    [NOT_FOUND_RESPONSE setContentType: @"text/html"];
    [NOT_FOUND_RESPONSE setContent:[@"Page not found." dataUsingEncoding:NSUTF8StringEncoding]];
  }
  return NOT_FOUND_RESPONSE;
}

+ (Response*) INTERNAL_SERVER_ERROR_RESPONSE
{
  if(INTERNAL_SERVER_ERROR_RESPONSE == nil)
  {
    INTERNAL_SERVER_ERROR_RESPONSE = [[Response alloc] init];
    [INTERNAL_SERVER_ERROR_RESPONSE setCode: INTERNAL_SERVER_ERROR];
    [INTERNAL_SERVER_ERROR_RESPONSE setContentType: @"text/html"];
    [INTERNAL_SERVER_ERROR_RESPONSE setContent:[@"Internal Server Error." dataUsingEncoding:NSUTF8StringEncoding]];
  }
  return INTERNAL_SERVER_ERROR_RESPONSE;
}

+ (Response*) UNAVAILABLE_RESPONSE
{
  if(NOT_AVAILABLE_RESPONSE == nil)
  {
    NOT_AVAILABLE_RESPONSE = [[Response alloc] init];
    [NOT_AVAILABLE_RESPONSE setCode: UNAVAILABLE];
    [NOT_AVAILABLE_RESPONSE setContentType: @"text/html"];
    [NOT_AVAILABLE_RESPONSE setContent:[@"Server Unavailable." dataUsingEncoding:NSUTF8StringEncoding]];
  }
  return NOT_AVAILABLE_RESPONSE;
}
@end
