//
//  ClassHolder.h
//  HTTPServe
//
//  Created by Kra on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


// TODO: This is utterly pointless... Look at NSValue and fix this nonsense...
@interface HSClassHolder : NSObject {
@private
  Class clazz;
}
@property (readonly) Class clazz;

- (id) initWithClass: (Class) class;
@end
