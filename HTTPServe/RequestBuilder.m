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
  NSString *paramString = [url parameterString];
  NSArray *paramArray = [paramString componentsSeparatedByString:@"="];
  for(int i = 0; i < [paramArray count]; i+=2)
  {
    NSString *key = [paramArray objectAtIndex:i];
    NSString *value = [paramArray objectAtIndex:i+1];
    [requestParameters setObject:value forKey:key];
  }

  Request *request = [[[Request alloc] initWithHeaders:headers parameters:requestParameters body:data url: url  andMethod:method] autorelease];
  return request;
}

@end
