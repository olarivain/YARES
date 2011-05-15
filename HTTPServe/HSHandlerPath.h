//
//  HSHandlerPath.h
//  HTTPServe
//
//  Created by Kra on 5/14/11.
//  Copyright 2011 kra. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HSHandlerPath : NSObject {
@private
  NSString *path;
  BOOL isRegex;
}

@property (readonly) NSString *path;
@property (readonly) BOOL isRegex;

+ (id) handlerPath: (NSString *) path;
+ (id) handlerRegexPath: (NSString *) regex;

- (BOOL) handlesURL: (NSURL*) url;

@end
