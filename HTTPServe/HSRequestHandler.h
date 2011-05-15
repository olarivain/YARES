//
//  RequestHandler.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HSRequest;
@class HSResponse;

@protocol HSRequestHandler <NSObject>
- (HSResponse*) handleRequest: (HSRequest*) request;
// array of HSHandlerPath
- (NSArray*) paths;

@optional
- (void) initialize;
@end
