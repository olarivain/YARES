//
//  NSURL+HTTPServe.m
//  HTTPServe
//
//  Created by Kra on 5/14/11.
//  Copyright 2011 kra. All rights reserved.
//
#import <KraCommons/NSString+URLEncoding.h>
#import "NSURL+HTTPServe.h"


@implementation NSURL (NSURL_HTTPServe)
- (NSDictionary*) queryParameters
{
	NSMutableDictionary *queryParameters = [NSMutableDictionary dictionary];
	
	// NSURL doesn't give you HTTP GET param. Meh.
	// TODO: this obviously doesn't give a shit whether the params are URL encoded.
	// implement this at some point.
	NSString *paramsString = [self query];
	NSArray *paramsArray = [paramsString componentsSeparatedByString:@"&"];
	
	for(NSString *paramString in paramsArray)
	{
		NSArray *paramArray = [paramString componentsSeparatedByString:@"="];
		
		// first, the key
		NSString *key = [paramArray boundSafeObjectAtIndex: 0];
		// url decode
		key = [key stringByURLDecoding];
		// some people, namely AFNetworking, add freaking [] at the end of param name for array
		if([key hasSuffix: @"[]"]) {
			key = [key stringByReplacingOccurrencesOfString: @"[]"
												 withString: @""];
		}
		
		// now, the value
		NSString *value = [paramArray boundSafeObjectAtIndex: 1];
		value = [value stringByURLDecoding];
		if(value.length == 0) {
			// no value, who fucking cares?
			continue;
		}
		
		id existingValue = [queryParameters objectForKey: key];
		// no param for that key existed before, just shove the value the in the params dictionary
		if(existingValue == nil) {
			[queryParameters setObject:value forKey:key];
			continue;
		}
		
		// we already have an array, so add to it and keep on going
		if([existingValue isKindOfClass: NSMutableArray.class]) {
			[(NSMutableArray *) existingValue addObjectNilSafe: value];
			continue;
		}
		
		// we must create an array, and wrap the previous value, plus the current value
		NSMutableArray *values = [NSMutableArray arrayWithObjects: existingValue, value, nil];
		[queryParameters setObjectNilSafe: values forKey: key];
	}
	return queryParameters;
}
@end
