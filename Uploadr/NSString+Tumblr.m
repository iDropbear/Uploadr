//
//  NSString+Tumblr.m
//  Uploadr
//
//  Created by Callum Sulivan on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+Tumblr.h"


@implementation NSString(Tumblr)

+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    return [[[[self class] alloc] initWithData:data encoding:encoding] autorelease];
}

+ (NSString *)uniqueString
{
    return [[NSProcessInfo processInfo] globallyUniqueString];
}

@end
