//
//  BBTumblrRequest.h
//  Uploadr
//
//  Created by Callum Sulivan on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBTumblrVars.h"
#import "BBTumblrDelegate.h"
#import "OAuthConsumer.h"

@interface BBTumblrRequest : NSObject {
@private
    OAConsumer *_consumer;
    OAToken *_token;
    
    NSMutableSet *_transactions;
    
    NSString *_blog;
    BBTumblrRequestType __type;
    NSURL *__URL;
    
    id <BBTumblrDelegate,NSObject> _delegate;
    
    // --- Avatar Parameter
    NSImage *_avatar;
    BOOL _avatarLoaded;
    BBTumblrAvatarSize _avatarSize;
    
    // --- Default Post Parameters
    BBTumblrPostType _type;
    NSArray *_tags;
    NSString *_tweet;
    BOOL _markdown;
    
    // --- Text
    NSString *_title;
    NSString *_body;
    
    // --- Photo
    NSString *_caption;
    NSString *_link;
    NSString *_source;
    NSArray *_photoData;
    
    // --- Quote
    NSString *_quote;
    //NSString *_source;
    
    // -- Link
    //NSString *_title;
    NSString *_URL;
    NSString *_description;
    
    // --- Conversation
    //NSString *_title;
    NSString *_conversation;
    
    // --- Audio
    //NSString *_caption;
    NSString *_externalURL;
    NSData *_data;
    
    // --- Video
    //NSString *_caption;
    NSString *_embed;
    //NSData *_data;
    
    // --- Reblog
    NSInteger _id;
    NSString *_reblogKey;
    NSString *_comment;
    

}

@property (nonatomic, readwrite, retain) OAConsumer *consumer;
@property (nonatomic, readwrite, retain) OAToken *token;
@property (nonatomic, readwrite, retain) NSMutableSet *transactions;

@property (nonatomic, readwrite, copy) NSString *blog;

@property (nonatomic, readwrite, assign) id <BBTumblrDelegate> delegate;

// --- Avatar Parameters
@property (nonatomic, readwrite, assign) BBTumblrAvatarSize avatarSize;

// --- Default Post Parameters
@property (nonatomic, readwrite, assign) BBTumblrPostType type;
@property (nonatomic, readwrite, retain) NSArray *tags;
@property (nonatomic, readwrite, copy) NSString *tweet;
@property (nonatomic, readwrite, assign, getter=isMarkdown) BOOL markdown;

// --- Post Parameters
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSString *body;
@property (nonatomic, readwrite, copy) NSString *caption;
@property (nonatomic, readwrite, copy) NSString *link;
@property (nonatomic, readwrite, copy) NSString *source;
@property (nonatomic, readwrite, retain) NSArray *photoData;
@property (nonatomic, readwrite, copy) NSString *quote;
@property (nonatomic, readwrite, copy) NSString *URL;
@property (nonatomic, readwrite, copy) NSString *description;
@property (nonatomic, readwrite, copy) NSString *conversation;
@property (nonatomic, readwrite, copy) NSString *externalURL;
@property (nonatomic, readwrite, retain) NSData *data;
@property (nonatomic, readwrite, copy) NSString *embed;

// --- Reblog Parameters
@property (nonatomic, readwrite, assign) NSInteger id;
@property (nonatomic, readwrite, copy) NSString *reblogKey;
@property (nonatomic, readwrite, copy) NSString *comment;

// Functions
- (id)initWithConsumer:(OAConsumer *)consumer token:(OAToken *)token baseHostName:(NSString *)hostName;

- (void)prepareFor:(BBTumblrRequestType)type;

- (NSString *)retrieveBlogInfo;

// --- Avatar
- (void)retrieveAvatar;
- (NSImage *)avatarImage;

- (OAMutableURLRequest *)generateRequest:(OAConsumer *)consumer token:(OAToken *)token;

@end
