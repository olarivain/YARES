//
//  HSHandlerPath.h
//  HTTPServe
//
//  Created by Kra on 5/14/11.
//  Copyright 2011 kra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSHandlerPath : NSObject 
{
@private
  NSString *path;
}

@property (readonly) NSString *path;

+ (id) handlerPath: (NSString *) path;

- (BOOL) handlesPath: (NSString*) relativePath;
- (NSDictionary*) pathParametersForURL: (NSString*) url;

@end
