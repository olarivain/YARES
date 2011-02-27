//
//  RestRequestHandler.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RequestHandler.h"
@class SBJsonParser;

@interface RestRequestHandler : NSObject<RequestHandler> {
@private
  NSMutableArray *resources;
  NSMutableArray *resourceDescriptors;
  SBJsonParser *parser;
}

@property (readonly) NSArray *paths;

@end
