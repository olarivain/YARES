//
//  Response.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HSResponse.h"
#import "HSResponseCode.h"
#import "JSONKit.h"

static HSResponse *NOT_FOUND_RESPONSE;
static HSResponse *INTERNAL_SERVER_ERROR_RESPONSE;
static HSResponse *NOT_AVAILABLE_RESPONSE;
static HSResponse *EMPTY_RESPONSE;

@implementation HSResponse

@synthesize object;
@synthesize code;
@synthesize content;
@synthesize headers;

- (id)init
{
  self = [super init];
  if (self) 
  {
    code = OK;
    [self setContentEncoding: @"UTF-8"];
  }
  return self;
}

+ (HSResponse*) response
{
  return [[[HSResponse alloc] init] autorelease];
}

- (void)dealloc
{
  [content release];
  [headers release];
  [super dealloc];
}

#pragma mark - Content accessor
- (NSData*) content {
  if(content == nil) {
    if([object isKindOfClass: [NSArray class]]) 
    {
      NSArray *array = (NSArray*) object;
      content = [array JSONData];
    }
    else if([object isKindOfClass: [NSDictionary class]])
    {
      NSDictionary *dictionary = (NSDictionary *) object;
      content = [dictionary JSONData];
    }
  }
  return content;
}

#pragma mark - Headers manipulation
- (void) addHeader:(NSString*)value forKey:(NSString *)key{
  if(headers == nil){
    headers = [[NSMutableDictionary alloc] init];
  }
  
  [headers setObject:value forKey:key];
}

- (void) removeHeader:(NSString*)key{
  [headers removeObjectForKey: key];
}

#pragma mark convenience methods
- (void) setContentEncoding:(NSString *)encoding 
{
  [self addHeader:encoding forKey:@"Content-Encoding"];
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

#pragma mark - Singletons
+ (HSResponse*) EMPTY_RESPONSE
{
  if(EMPTY_RESPONSE == nil)
  {
    EMPTY_RESPONSE = [[HSResponse alloc] init];
    [EMPTY_RESPONSE setCode: OK];
  }
  return EMPTY_RESPONSE;
}

+ (HSResponse*) NOT_FOUND_RESPONSE
{
  if(NOT_FOUND_RESPONSE == nil)
  {
    NOT_FOUND_RESPONSE = [[HSResponse alloc] init];
    [NOT_FOUND_RESPONSE setCode: NOT_FOUND];
    [NOT_FOUND_RESPONSE setContentType: @"text/html"];
    [NOT_FOUND_RESPONSE setContent:[@"Page not found." dataUsingEncoding:NSUTF8StringEncoding]];
  }
  return NOT_FOUND_RESPONSE;
}

+ (HSResponse*) INTERNAL_SERVER_ERROR_RESPONSE
{
  if(INTERNAL_SERVER_ERROR_RESPONSE == nil)
  {
    INTERNAL_SERVER_ERROR_RESPONSE = [[HSResponse alloc] init];
    [INTERNAL_SERVER_ERROR_RESPONSE setCode: INTERNAL_SERVER_ERROR];
    [INTERNAL_SERVER_ERROR_RESPONSE setContentType: @"text/html"];
    [INTERNAL_SERVER_ERROR_RESPONSE setContent:[@"Internal Server Error." dataUsingEncoding:NSUTF8StringEncoding]];
  }
  return INTERNAL_SERVER_ERROR_RESPONSE;
}

+ (HSResponse*) UNAVAILABLE_RESPONSE
{
  if(NOT_AVAILABLE_RESPONSE == nil)
  {
    NOT_AVAILABLE_RESPONSE = [[HSResponse alloc] init];
    [NOT_AVAILABLE_RESPONSE setCode: UNAVAILABLE];
    [NOT_AVAILABLE_RESPONSE setContentType: @"text/html"];
    [NOT_AVAILABLE_RESPONSE setContent:[@"Server Unavailable." dataUsingEncoding:NSUTF8StringEncoding]];
  }
  return NOT_AVAILABLE_RESPONSE;
}
@end
