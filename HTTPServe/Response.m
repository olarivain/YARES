//
//  Response.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Response.h"


@implementation Response

@synthesize responseCode;
@synthesize content;
@synthesize headers;

- (id)init
{
    self = [super init];
    if (self) {
      responseCode = OK;
    }
    
    return self;
}

- (void)dealloc
{
  [content release];
  [headers release];
  [super dealloc];
}

- (void) addHeader:(id)value forKey:(NSString *)key{
  if(headers == nil){
    headers = [[NSMutableDictionary alloc] init];
  }
  
  [headers setObject:value forKey:key];
}

- (void) removeHeader:(id)key{
  [headers removeObjectForKey: key];
}

- (int) httpResponseCode
{
  int code;
  switch(responseCode)
  {
    case OK:
      code = 200;
      break;
      
    case CREATED: 
      code = 201;
      break;
    case NO_CONTENT: 
      code = 204;
      break;
    case MOVED_PERMANENTLY: 
      code = 302;
      break;
    case BAD_REQUEST: 
      code = 400;
      break;
    case FORBIDDEN: 
      code = 403;
      break;
    case NOT_FOUND: 
      code = 404;
      break;
    case INTERNAL_SERVER_ERROR: 
      code = 500;
      break;
    case UNAVAILABLE:
      code = 503;
      break;
    default:
      code = 404;
      break;

  }
  
  return code;
}

@end
