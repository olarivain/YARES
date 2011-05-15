//
//  HSHandlerPath.m
//  HTTPServe
//
//  Created by Kra on 5/14/11.
//  Copyright 2011 kra. All rights reserved.
//

#import "HSHandlerPath.h"
#import "NSString+HTTPServe.h"

@interface HSHandlerPath()
- (id)initWithPath: (NSString*) handlerPath;
- (NSString*) predicatePath;
@end

@implementation HSHandlerPath

+ (id) handlerPath: (NSString *) path
{
  return [[[HSHandlerPath alloc] initWithPath:path] autorelease];
}

- (id)initWithPath: (NSString*) handlerPath
{
  self = [super init];
  if (self) 
  {
    path = [handlerPath retain];
  }
  
  return self;
}

- (void)dealloc
{
  [path release];
  [super dealloc];
}

@synthesize path;

- (BOOL) handlesURL:(NSURL *)url
{
  NSString *relativePath = [url relativePath];

  // use regex for processed paths, exact match otherwise
  NSString *predicateTemplate = [self predicatePath];
  NSString *predicateFormat = predicateFormat != path ? @"SELF matches %@" : @"SELF == %@";
  NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateFormat, predicateTemplate];
  return [predicate evaluateWithObject: relativePath];
}

- (NSString *) predicatePath
{
  // if we don't have any variable, don't even evalute.
  if(![path contains: @"${"] && ![path contains:@"*"])
  {
    return path;
  }
  
  NSMutableString *predicatePath = [NSMutableString string];
  NSArray *components = [path componentsSeparatedByString:@"/"];
  for(NSString *component in components)
  {
    NSString *appended = component;
    // subsitute variable with regex matching "everything but /"
    if([component contains: @"${"])
    {
      appended = @"[^/]+";
    }
    
    [predicatePath appendString: appended];
    if(component != [components lastObject])
    {
      [predicatePath appendString:@"/"];
    }
  }
  
  NSRange range = NSMakeRange(0, [predicatePath length]);
  [predicatePath replaceOccurrencesOfString:@"**" withString:@".*" options:NSLiteralSearch range: range];
  range = NSMakeRange(0, [predicatePath length]);
  [predicatePath replaceOccurrencesOfString:@"*" withString:@"[^/]*" options:NSLiteralSearch range: range]; 
  
  return predicatePath;
}



@end
