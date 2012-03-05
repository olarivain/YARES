//
//  NSURL+HTTPServe.h
//  HTTPServe
//
//  Created by Kra on 5/14/11.
//  Copyright 2011 kra. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning move to KraCommons
@interface NSURL (NSURL_HTTPServe)
- (NSDictionary*) queryParameters;
@end
