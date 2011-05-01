//
//  RestRequestHandler.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HSRequestHandler.h"
@class JSONDecoder;

@interface HSRestRequestHandler : NSObject<HSRequestHandler> {
@private
  NSMutableArray *resources;
  NSMutableArray *resourceDescriptors;
  JSONDecoder *decoder;
}

@property (readonly) NSArray *paths;

@end
