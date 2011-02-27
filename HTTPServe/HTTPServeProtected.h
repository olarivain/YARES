//
//  HTTPServeProtected.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPServe.h"
#import "RequestHandler.h"

@class HTTPConnection;

@interface HTTPServe(protected)
- (id<RequestHandler>) handlerForURL: (NSURL*) url;
- (void) connectionHandled: (HTTPConnection*) connection;
@end
