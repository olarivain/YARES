//
//  ClassHolder.m
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HSClassHolder.h"


@implementation HSClassHolder

- (id)initWithClass: (Class) class
{
    self = [super init];
    if (self) 
    {
      clazz = class;
    }
    
    return self;
}


@synthesize clazz;

@end
