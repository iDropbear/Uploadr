//
//  BBError.m
//  Uploadr
//
//  Created by Callum Sulivan on 17/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BBError.h"

@implementation BBError

@synthesize description=_description, code=_code, ownerClass=_class;

+ (BBError *)errorWithDescription:(NSString *)desc andCode:(NSInteger)code andClass:(Class)classs
{
    BBError *error = [[[self class] alloc] init];
    
    [error setDescription:desc];
    [error setCode:code];
    [error setOwnerClass:classs];
    
    return [error autorelease];
}

@end
