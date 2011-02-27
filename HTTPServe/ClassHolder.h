//
//  ClassHolder.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ClassHolder : NSObject {
@private
  Class clazz;
}
@property (readonly) Class clazz;

- (id) initWithClass: (Class) class;
@end
