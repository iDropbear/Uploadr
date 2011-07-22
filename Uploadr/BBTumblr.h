//
//  BBTumblr.h
//  Uploadr
//
//  Created by Callum Sulivan on 17/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthConsumer.h"
#import "BBTumblrVars.h"
#import "BBTumblrDelegate.h"
#import "BBTumblrPost.h"

@interface BBTumblr : NSObject {
@private
    id<BBTumblrDelegate,NSObject> _delegate;
    NSMutableSet *_transactions;
    
    OAConsumer *_consumer;
    OAToken *_token;
    NSString *_hostname;
}

@property (nonatomic, readwrite, assign) id<BBTumblrDelegate> delegate;
@property (nonatomic, readwrite, retain) NSMutableSet *transactions;

@property (nonatomic, readwrite, retain) OAConsumer *consumer;
@property (nonatomic, readwrite, retain) OAToken *token;
@property (nonatomic, readwrite, copy) NSString *hostname;


+ (BBTumblr *)sharedInstance;

// -- Requests
- (NSString *)requestTokenWithEmail:(NSString *)email Password:(NSString *)password;

- (NSString *)requestBlogAvatar:(NSString *)blog withSize:(BBTumblrAvatarSize)size;
- (NSString *)requestBlogInfo:(NSString *)blog;
- (NSString *)createPost:(BBTumblrPost *)post;

@end
