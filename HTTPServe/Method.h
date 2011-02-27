//
//  Method.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum
{
  GET,
  PUT,
  POST,
  DELETE
} Method;

Method methodFromString(NSString *method);
NSString* stringFromMethod(Method method);