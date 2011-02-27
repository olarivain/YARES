//
//  SystemUtil.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>
@interface SystemUtil : NSObject {
@private
    
}
+ (NSArray*) getAllRegisteredClasses;
+ (NSArray*) getClassesConformingToProcol: (Protocol*) protocol;

@end
