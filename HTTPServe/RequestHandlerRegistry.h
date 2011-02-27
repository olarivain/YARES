//
//  RequestHandlerRegistry.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RequestHandler.h"
@class NotFoundHandler;
@interface RequestHandlerRegistry : NSObject {
@private
  NSMutableArray *handlers;
  id<RequestHandler> notFoundHandler;
}

@property (readonly) id<RequestHandler> notFoundHandler;

- (void) autoregister;
- (void) registerHandler: (id<RequestHandler>) handler; 
- (void) unregisterHandler: (id<RequestHandler>) handler;
- (id<RequestHandler>) handlerForURL: (NSURL*) url;
@end
