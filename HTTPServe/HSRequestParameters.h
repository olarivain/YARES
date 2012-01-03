//
//  HSRequestParameters.h
//  HTTPServe
//
//  Created by Kra on 5/14/11.
//  Copyright 2011 kra. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HSRequestParameters : NSObject {
@private
#warning this should be an id, not an NSDictionary - it can be a JSON array
  NSDictionary *__strong pathParameters;
  id __strong parameters;
}

@property (readonly) NSDictionary *pathParameters;
@property (readonly) id parameters;

+ (id) requestParmetersWithPathParameters: (NSDictionary*) pathParams andParamters: (id) param;

- (id) pathParameterForKey: (NSString *) key;
@end
