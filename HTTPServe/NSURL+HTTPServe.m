//
//  NSURL+HTTPServe.m
//  HTTPServe
//
//  Created by Kra on 5/14/11.
//  Copyright 2011 kra. All rights reserved.
//

#import "NSURL+HTTPServe.h"


@implementation NSURL (NSURL_HTTPServe)
- (NSDictionary*) queryParameters
{
  NSMutableDictionary *queryParameters = [NSMutableDictionary dictionary];
  
  // NSURL doesn't give you HTTP GET param. Meh.
  // TODO: this obviously doesn't give a shit whether the params are URL encoding.
  // implement this at some point.
  NSString *paramsString = [self query];
  NSArray *paramsArray = [paramsString componentsSeparatedByString:@"&"];
  for(NSString *paramString in paramsArray)
  {
    NSArray *paramArray = [paramString componentsSeparatedByString:@"="];
    NSString *key = [paramArray objectAtIndex:0];
    NSString *value = [paramArray count] > 1 ? [paramArray objectAtIndex:1] : @"";
    [queryParameters setObject:value forKey:key];
  }
  return queryParameters;
}
@end
