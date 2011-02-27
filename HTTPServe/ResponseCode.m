//
//  ResponseCode.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResponseCode.h"

static ResponseCode* OK;
static ResponseCode* CREATED;
static ResponseCode* NO_CONTENT;
static ResponseCode* MOVED_PERMANENTLY;
static ResponseCode* BAD_REQUEST;
static ResponseCode* FORBIDDEN;
static ResponseCode* NOT_FOUND;
static ResponseCode* INTERNAL_SERVER_ERROR;
static ResponseCode* UNAVAILABLE;


@implementation ResponseCode

- (id)initWithCode: (int) responseCode
{
  self = [super init];
  if (self) 
  {
    code = responseCode;
  }
  
  return self;
}

- (void)dealloc
{
    [super dealloc];
}

@synthesize code;

+ (ResponseCode*) OK
{
  if(OK == nil)
  {
    OK = [[ResponseCode alloc] initWithCode:200];
  }
  return OK;
}

+ (ResponseCode*) CREATED
{
  if(CREATED == nil)
  {
    CREATED = [[ResponseCode alloc] initWithCode:201];
  }
  return CREATED;
}

+ (ResponseCode*) NO_CONTENT
{
  if(NO_CONTENT == nil)
  {
    NO_CONTENT = [[ResponseCode alloc] initWithCode:204];
  }
  return NO_CONTENT;
}

+ (ResponseCode*) MOVED_PERMANENTLY
{
  if(MOVED_PERMANENTLY == nil)
  {
    MOVED_PERMANENTLY = [[ResponseCode alloc] initWithCode:302];
  }
  return MOVED_PERMANENTLY;
}

+ (ResponseCode*) BAD_REQUEST
{
  if(BAD_REQUEST == nil)
  {
    BAD_REQUEST = [[ResponseCode alloc] initWithCode:400];
  }
  return BAD_REQUEST;
}

+ (ResponseCode*) FORBIDDEN
{
  if(FORBIDDEN == nil)
  {
    FORBIDDEN = [[ResponseCode alloc] initWithCode:403];
  }
  return FORBIDDEN;
}

+ (ResponseCode*) NOT_FOUND
{
  if(NOT_FOUND == nil)
  {
    NOT_FOUND = [[ResponseCode alloc] initWithCode:404];
  }
  return NOT_FOUND;
}

+ (ResponseCode*) INTERNAL_SERVER_ERROR
{
  if(INTERNAL_SERVER_ERROR == nil)
  {
    INTERNAL_SERVER_ERROR = [[ResponseCode alloc] initWithCode:500];
  }
  return INTERNAL_SERVER_ERROR;
}

+ (ResponseCode*) UNAVAILABLE
{
  if(UNAVAILABLE == nil)
  {
    UNAVAILABLE = [[ResponseCode alloc] initWithCode:503];
  }
  return UNAVAILABLE;
}

@end
