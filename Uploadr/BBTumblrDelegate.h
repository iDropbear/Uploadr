//
//  BBTumblrDelegate.h
//  Uploadr
//
//  Created by Callum Sulivan on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBTumblr, BBTumblrRequest, BBError;

@protocol BBTumblrDelegate <NSObject>

@optional
- (void)tumblrRequest:(BBTumblr *)tumblr didFailWithError:(BBError *)error;
- (void)tumblrRequest:(BBTumblr *)tumblr receivedAvatar:(NSImage *)avatar;
- (void)tumblrRequest:(BBTumblr *)tumblr receivedBlogInfo:(NSDictionary *)dictionary;
- (void)tumblrRequest:(BBTumblr *)tumblr receivedResponse:(NSURLResponse *)response;
- (void)tumblrRequest:(BBTumblr *)tumblr percentageSent:(CGFloat)percent;

@end
