//
//  RequestBuilder.h
//  HTTPServe
//
//  Created by Kra on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Request;

@interface RequestBuilder : NSObject {
@private
    
}

- (Request*) buildRequest: (CFHTTPMessageRef) messageRef;

@end
