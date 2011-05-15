//
//  NSString+HTTPServe.m
//  HTTPServe
//
//  Created by Kra on 5/14/11.
//  Copyright 2011 kra. All rights reserved.
//

#import "NSString+HTTPServe.h"


@implementation NSString (NSString_HTTPServe)
- (BOOL) contains: (NSString*) other
{
  NSRange range = [self rangeOfString:other];
  return range.location != NSNotFound;
}
@end
