//
//  Method.c
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Method.h"

Method methodFromString(NSString *method)
{
  if([method caseInsensitiveCompare:@"GET"] == 0)
  {
    return GET;
  } else if([method caseInsensitiveCompare:@"PUT"] == 0)
  {
    return PUT;
  } else if([method caseInsensitiveCompare:@"POST"] == 0)
  {
    return POST;
  } else if([method caseInsensitiveCompare:@"DELETE"] == 0)
  {
    return DELETE;
  }
  NSException *exception = [NSException exceptionWithName:@"IllegalArgumentException" reason:[NSString stringWithFormat: @"Unknown method %@", method]  userInfo:nil];
  @throw exception;
}

NSString* stringFromMethod(Method method)
{
  switch(method)
  {
    case GET:
      return @"GET";
    case PUT:
      return @"PUT";
    case POST:
      return @"POST";
    case DELETE:
      return @"DELETE";
  }
  NSException *exception = [NSException exceptionWithName:@"IllegalArgumentException" reason:[NSString stringWithFormat: @"Unknown method %@", method]  userInfo:nil];
  @throw exception;
}