//
//  BBError.h
//  Uploadr
//
//  Created by Callum Sulivan on 17/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BBError : NSError {
@private
    NSString *_description;
    Class _class;
}

@property (nonatomic, readwrite, copy) NSString *description;
@property (nonatomic, readwrite, assign ) Class ownerClass;

@end
