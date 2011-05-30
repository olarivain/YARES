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
static HSResponse *NOT_AVAILABLE_RESPONSE;

@implementation HSResponse

@synthesize object;
@synthesize code;
@synthesize content;
@synthesize headers;

+ (HSResponse*) jsonResponse
{
  return [[[HSResponse alloc] initWithContentType:@"application/json"] autorelease];

}

+ (HSResponse*) response
{
  return [[[HSResponse alloc] init] autorelease];
}

+ (HSResponse*) errorResponse
{
  HSResponse *response = [HSResponse response];
  response.code = INTERNAL_SERVER_ERROR;
  [response setContentType:@"text/html"];
  return response;
}

+ (HSResponse*) emptyResponse
{
  HSResponse *response = [HSResponse response];
  response.code = NO_CONTENT;
  return response;  
}

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

- (id)initWithContentType: (NSString*) contentType
{
  self = [super init];
  if (self) 
  {
    code = OK;
    [self setContentEncoding: @"UTF-8"];
    [self setContentType: contentType];
  }
  return self;
}

- (void)dealloc
{
  self.object = nil;
  self.content = nil;
  [headers release];
  [super dealloc];
}

#pragma mark - Content accessor
- (NSData*) content 
{
  if(content == nil) 
  {
    // we have no physical content, that means we'll assume it's a JSON output.
    // use JSONKit to turn array or dictionary into JSON and return that.
    // if we don't have array/dict don't do anything as we have no clue what's going on.
    if([object isKindOfClass: [NSArray class]]) 
    {
      NSArray *array = (NSArray*) object;
      NSData *data = [array JSONData];
      self.content = data;
    }
    else if([object isKindOfClass: [NSDictionary class]])
    {
      NSDictionary *dictionary = (NSDictionary *) object;
      NSData *data = [dictionary JSONData];
      self.content = data;
    }
  }
  return content;
}

#pragma mark - Headers manipulation
- (void) addHeader:(NSString*)value forKey:(NSString *)key
{
  if(headers == nil)
  {
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
  return [self.content length];
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
