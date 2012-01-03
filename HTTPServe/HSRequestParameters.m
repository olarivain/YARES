//
//  HSRequestParameters.m
//  HTTPServe
//
//  Created by Kra on 5/14/11.
//  Copyright 2011 kra. All rights reserved.
//

#import "HSRequestParameters.h"

@interface HSRequestParameters()
- (id) initWithPathParameters: (NSDictionary*) pathParams andParamters: (id) param;
@end

@implementation HSRequestParameters

+ (id) requestParmetersWithPathParameters: (NSDictionary*) pathParams andParamters: (id) param
{
  return [[HSRequestParameters alloc] initWithPathParameters: pathParams andParamters: param];
}


- (id) initWithPathParameters: (NSDictionary*) pathParams andParamters: (id) param
{
  self = [super init];
  if (self) 
  {
    pathParameters = pathParams;
    parameters = param;
  }
  
  return self;
}


@synthesize pathParameters;
@synthesize parameters;

- (id) pathParameterForKey: (NSString *) key
{
  return [pathParameters objectForKey: key];
}

@end
