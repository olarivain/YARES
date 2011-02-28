//
//  RequestBuilder.m
//  HTTPServe
//
//  Created by Kra on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RequestBuilder.h"
#import "HttpMethod.h"
#import "Request.h"


@implementation RequestBuilder

- (id)init
{
  self = [super init];
  if (self) {
      // Initialization code here.
  }
  
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (Request*) buildRequest: (CFHTTPMessageRef) messageRef
{
  NSURL *url = [(NSURL*) CFHTTPMessageCopyRequestURL(messageRef) autorelease];
  NSString *methodString = [(NSString*) CFHTTPMessageCopyRequestMethod(messageRef) autorelease];
  HttpMethod method = methodFromString(methodString);
  NSDictionary *headers = [(NSDictionary*) CFHTTPMessageCopyAllHeaderFields(messageRef) autorelease];
  NSData *data = [(NSData*) CFHTTPMessageCopyBody(messageRef) autorelease];
  
  NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
  // this is weird. [url parameterString] returns nil. Seems like the URL is built with no protocol/host.
  // hence, the manual parsing of the string.
  NSArray *split = [[url absoluteString] componentsSeparatedByString:@"?"];
  NSString *paramsString = [split count] > 1 ? [split objectAtIndex:1] : nil;
  NSArray *paramsArray = [paramsString componentsSeparatedByString:@"&"];
  for(NSString *paramString in paramsArray)
  {
    NSArray *paramArray = [paramString componentsSeparatedByString:@"="];
    NSString *key = [paramArray objectAtIndex:0];
    NSString *value = [paramArray count] > 1 ? [paramArray objectAtIndex:1] : @"";
        [requestParameters setObject:value forKey:key];
  }

  Request *request = [[[Request alloc] initWithHeaders:headers parameters:requestParameters body:data url: url  andMethod:method] autorelease];
  return request;
}

@end
