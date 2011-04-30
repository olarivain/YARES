//
//  RequestHandlerRegistry.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HSRequestHandler.h"

@interface HSRequestHandlerRegistry : NSObject {
@private
  NSMutableArray *handlers;
  id<HSRequestHandler> notFoundHandler;
}

@property (readonly) id<HSRequestHandler> notFoundHandler;

- (void) autoregister;
- (void) registerHandler: (id<HSRequestHandler>) handler; 
- (void) unregisterHandler: (id<HSRequestHandler>) handler;
- (void) unregisterRequestHandlers;
- (id<HSRequestHandler>) handlerForURL: (NSURL*) url;
@end
