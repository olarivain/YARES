//
//  HSHandlerPath.m
//  HTTPServe
//
//  Created by Kra on 5/14/11.
//  Copyright 2011 kra. All rights reserved.
//

#import "HSHandlerPath.h"

@interface HSHandlerPath()
- (id)initWithPath: (NSString*) handlerPath regex: (BOOL) regex;
- (NSString*) predicatePath;
@end

@implementation HSHandlerPath

+ (id) handlerPath: (NSString *) path
{
  return [[[HSHandlerPath alloc] initWithPath:path regex: NO] autorelease];
}

+ (id) handlerRegexPath: (NSString *) regex
{
  return [[[HSHandlerPath alloc] initWithPath:regex regex: YES] autorelease];  
}

- (id)initWithPath: (NSString*) handlerPath regex: (BOOL) regex
{
  self = [super init];
  if (self) 
  {
    path = [handlerPath retain];
    isRegex = regex;
  }
  
  return self;
}

- (void)dealloc
{
  [path release];
  [super dealloc];
}

@synthesize path;
@synthesize isRegex;

- (BOOL) handlesURL:(NSURL *)url
{
  NSString *relativePath = [url relativePath];

  // use regex for regex, exact match otherwise
  NSString *predicateFormat = isRegex ? @"SELF matches %@" : @"SELF == %@";
  NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateFormat, path];
  return [predicate evaluateWithObject: relativePath];
}

- (NSString *) predicatePath
{
  
}

@end
