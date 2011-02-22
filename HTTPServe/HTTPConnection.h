//
//  HTTPConnection.h
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTTPConnection : NSObject {
@private
  NSFileHandle *fileHandle;
  CFHTTPMessageRef request;
  long contentLength;
  long readLength;
  BOOL headerReceived;
  BOOL bodyReceived;
  NSDictionary *requestHeaders;
  NSData *requestData;
}

- (id) initWithFileHandle: (NSFileHandle*) handle;

@end
