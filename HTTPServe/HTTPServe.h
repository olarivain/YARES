//
//  HTTPServe.h
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RequestHandlerRegistry;

@interface HTTPServe : NSObject 
{
@private
  int listenPort;
  NSSocketPort *socketPort;
  NSFileHandle *fileHandle;
  NSMutableArray *connections;
  RequestHandlerRegistry *handlerRegistry;
}

- (HTTPServe*) initWithPort: (int) port;
- (void) start;

@end
