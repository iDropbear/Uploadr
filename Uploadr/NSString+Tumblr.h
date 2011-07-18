//
//  NSString+Tumblr.h
//  Uploadr
//
//  Created by Callum Sulivan on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(Tumblr)

+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
+ (NSString *)uniqueString;

@end
