//
//  RequestHandler.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Response;

@protocol RequestHandler <NSObject>
- (Response*) handleRequest: (NSDictionary*) headers body: (NSData*) data;
- (NSArray*) urls;
@end
