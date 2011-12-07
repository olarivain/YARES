//
//  RestRequestHandler.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HSRequestHandler.h"

@interface HSRestRequestHandler : NSObject<HSRequestHandler> {
@private
  NSMutableArray *resources;
  NSMutableArray *resourceDescriptors;
}

@property (unsafe_unretained, readonly) NSArray *paths;

@end
