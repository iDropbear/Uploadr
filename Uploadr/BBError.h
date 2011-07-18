//
//  BBError.h
//  Uploadr
//
//  Created by Callum Sulivan on 17/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BBError : NSObject {
@private
    NSString *_description;
    NSInteger _code;
    Class _class;
}

@property (nonatomic, readwrite, copy) NSString *description;
@property (nonatomic, readwrite, assign ) NSInteger code;
@property (nonatomic, readwrite, assign ) Class ownerClass;

+ (BBError *)errorWithDescription:(NSString *)desc andCode:(NSInteger)code andClass:(Class)ownerClass;

@end
