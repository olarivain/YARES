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

#pragma mark - URL matching
- (BOOL) handlesPath:(NSString *)relativePath
{
  // use regex for processed paths, exact match otherwise
  // processed path == path is different than predicatePath. Rough, but it works.
  NSString *predicateTemplate = [self predicatePath];
  NSString *predicateFormat = predicateFormat != path ? @"SELF matches %@" : @"SELF == %@";
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateFormat, predicateTemplate];
  return [predicate evaluateWithObject: relativePath];
}

- (NSString *) predicatePath
{
  // if we don't have any variable, don't even evaluate and GTFO.
  if(![path contains: @"{"] && ![path contains:@"*"])
  {
    return path;
  }
  
  NSMutableString *predicatePath = [NSMutableString string];
  NSArray *components = [path componentsSeparatedByString:@"/"];
  // evaluate the path by replacing all ${var} with "anything but / and 
  for(NSString *component in components)
  {
    // copy the component
    NSString *appended = component;
    // unless it is a variable, in this case subsitute it with regex matching "everything but /"
    if([component contains: @"{"])
    {
      appended = @"[^/]+";
    }
    [predicatePath appendString: appended];
    
    // don't append / on the last element unless it's empty string - that means path
    // was in the form /foo/ and we want to maintain the last in this case.
    if(component != [components lastObject] && [component length] > 0)
    {
      [predicatePath appendString:@"/"];
    }
  }
  
  // now replace double stars with "anything" and single stars with "anything but /"
  NSRange range = NSMakeRange(0, [predicatePath length]);
  [predicatePath replaceOccurrencesOfString:@"**" withString:@".*" options:NSLiteralSearch range: range];
  range = NSMakeRange(0, [predicatePath length]);
  [predicatePath replaceOccurrencesOfString:@"*" withString:@"[^/]*" options:NSLiteralSearch range: range]; 
  
  return predicatePath;
}

#pragma mark - URL path parameters extraction
- (NSDictionary*) pathParametersForURL: (NSString*) path
{
  
}

@end
