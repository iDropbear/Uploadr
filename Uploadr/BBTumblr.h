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

@interface BBTumblr : NSObject {
@private
    id<BBTumblrDelegate,NSObject> _delegate;
    NSMutableSet *_transactions;
    
    OAConsumer *_consumer;
    OAToken *_token;
    NSString *_hostname;
    
    // --- Default Post Parameters
    BBTumblrPostType _type;
    NSArray *_tags;
    NSString *_tweet;
    //NSDate *_date;
    BOOL _markdown;
    
    // ---Text
    NSString *_title;
    NSString *_body;
    // ---Photo
    NSString *_caption;
    NSString *_link;
    NSString *_source;
    NSData *_data;
    // ---Quote
    NSString *_quote;
    //NSString *_source;
    // ---Link
    //NSString *_title;
    NSString *_URL;
    NSString *_description;
    // ---Conversation
    //NSString *_title;
    NSString *_conversation;
    // ---Audio
    //NSString *_caption;
    NSString *_externalURL;
    //NSData *_data
    // ---Video
    //NSString *_caption;
    NSString *_embed;
    //NSData *_data;
}

@property (nonatomic, readwrite, assign) id<BBTumblrDelegate> delegate;
@property (nonatomic, readwrite, retain) NSMutableSet *transactions;

@property (nonatomic, readwrite, retain) OAConsumer *consumer;
@property (nonatomic, readwrite, retain) OAToken *token;
@property (nonatomic, readwrite, copy) NSString *hostname;

// --- Default Post Parameters
@property (nonatomic, readwrite, assign) BBTumblrPostType type;
@property (nonatomic, readwrite, retain) NSArray *tags;
@property (nonatomic, readwrite, copy) NSString *tweet;
//NSDate *_date;
@property (nonatomic, readwrite, assign, getter=isMarkdown) BOOL markdown;

// ---Text
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSString *body;
// ---Photo
@property (nonatomic, readwrite, copy) NSString *caption;
@property (nonatomic, readwrite, copy) NSString *link;
@property (nonatomic, readwrite, copy) NSString *source;
@property (nonatomic, readwrite, retain) NSData *data;
// ---Quote
@property (nonatomic, readwrite, copy) NSString *quote;
//NSString *_source;
// ---Link
//NSString *_title;
@property (nonatomic, readwrite, copy) NSString *URL;
@property (nonatomic, readwrite, copy) NSString *description;
// ---Conversation
//NSString *_title;
@property (nonatomic, readwrite, copy) NSString *conversation;
// ---Audio
//NSString *_caption;
@property (nonatomic, readwrite, copy) NSString *externalURL;
//NSData *_data
// ---Video
//NSString *_caption;
@property (nonatomic, readwrite, copy) NSString *embed;
//NSData *_data;


+ (BBTumblr *)sharedInstance;

- (BOOL)isReady;

// -- Requests
- (NSString *)requestBlogAvatar:(NSString *)blog withSize:(BBTumblrAvatarSize)size;
- (NSString *)requestBlogInfo:(NSString *)blog;
- (NSString *)createNewPost;

@end
