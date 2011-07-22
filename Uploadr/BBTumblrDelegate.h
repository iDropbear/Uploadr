//
//  BBTumblrDelegate.h
//  Uploadr
//
//  Created by Callum Sulivan on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBTumblr, BBTumblrRequest;

@protocol BBTumblrDelegate <NSObject>

@optional
- (void)tumblrRequest:(NSString *)identifier didFailWithError:(NSError *)error;
- (void)tumblrRequest:(NSString *)identifier receivedResponse:(NSURLResponse *)response;
- (void)tumblrRequest:(NSString *)identifier percentageSent:(CGFloat)percent;

- (void)tumblrRequest:(NSString *)identifier receivedAvatar:(NSImage *)avatar;

- (void)tumblrRequest:(NSString *)identifier receivedBlogInfo:(NSDictionary *)dictionary;

- (void)tumblrRequest:(NSString *)identifier newPostCreated:(NSInteger)postID;

- (void)tumblrRequestUserAuthenticated:(NSString *)identifier;

@end
