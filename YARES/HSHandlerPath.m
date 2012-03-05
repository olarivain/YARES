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
- (BOOL) shouldEvaluate;
- (BOOL) hasPathParams;
- (BOOL) isParameterName: (NSString *) string;
@end

@implementation HSHandlerPath

+ (id) handlerPath: (NSString *) path
{
  return [[HSHandlerPath alloc] initWithPath:path];
}

- (id)initWithPath: (NSString*) handlerPath
{
  self = [super init];
  if (self) 
  {
    path = handlerPath;
  }
  
  return self;
}


@synthesize path;

#pragma mark - URL matching
- (BOOL) handlesPath:(NSString *)relativePath
{
  // use regex for evaluated paths, exact match otherwise
  NSString *predicateTemplate = [self predicatePath];
  NSString *predicateFormat = [self shouldEvaluate] ? @"SELF matches %@" : @"SELF == %@";
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateFormat, predicateTemplate];
  BOOL matches = [predicate evaluateWithObject: relativePath];
  return matches;
}

- (BOOL) hasPathParams
{
  return [path contains: @"{"];
}

- (BOOL) shouldEvaluate
{
  return [path contains: @"{"] || [path contains:@"*"];
}

- (NSString *) predicatePath
{
  // if we don't have any variable, don't even evaluate and GTFO.
  if(![self shouldEvaluate])
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
    if(component != [components lastObject] || [component length] == 0)
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
- (BOOL) isParameterName: (NSString *) string
{
  return [string contains:@"{"];
}
- (NSDictionary*) pathParametersForURL: (NSString*) relativePath
{
  if(![self hasPathParams])
  {
    return [NSDictionary dictionary];
  }
  
  
  NSMutableDictionary *pathParameters = [NSMutableDictionary dictionary];
  NSArray *pathComponents = [relativePath componentsSeparatedByString:@"/"];
  NSArray *variableComponents = [path componentsSeparatedByString:@"/"];
  
  // just to be safe.
  if([pathComponents count] < [variableComponents count])
  {
    NSLog(@"FATAL: cannot extract path parameters, actual URL is shorter than path definition, aborting.");
    return pathParameters;
  }
  
  // start at -1 and increment at the BEGINNING of loop, this will make the for more readable
  // and less bug prone
  NSInteger index = -1;
  for(NSString *variableComponent in variableComponents)
  {
    index++;
    // no param here, skip
    if(![self isParameterName: variableComponent])
    {
      continue;
    }
    
    // strip {} out of param name
    NSString *paramName = [variableComponent stringByReplacingOccurrencesOfString:@"{" withString:@""];
    paramName = [paramName stringByReplacingOccurrencesOfString:@"}" withString:@""];
    
    // get value out of actual URL
    NSString *paramValue = [pathComponents objectAtIndex: index];
    
    // and add to param list
    [pathParameters setObject: paramValue forKey: paramName];
  }
  
  return pathParameters;
}

@end
