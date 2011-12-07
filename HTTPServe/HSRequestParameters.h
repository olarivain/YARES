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
  NSDictionary *__unsafe_unretained pathParameters;
  id __unsafe_unretained parameters;
}

@property (readonly) NSDictionary *pathParameters;
@property (readonly) id parameters;

+ (id) requestParmetersWithPathParameters: (NSDictionary*) pathParams andParamters: (id) param;

@end
