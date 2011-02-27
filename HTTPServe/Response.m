//
//  Response.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Response.h"
#import "ResponseCode.h"

@implementation Response

@synthesize responseCode;
@synthesize content;
@synthesize headers;

- (id)init
{
    self = [super init];
    if (self) {
      responseCode = [ResponseCode OK];
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

@end
