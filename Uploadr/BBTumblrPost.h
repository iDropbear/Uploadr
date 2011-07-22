//
//  BBTumblrPost.h
//  Uploadr
//
//  Created by Callum Sulivan on 18/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBTumblrVars.h"

@interface BBTumblrPost : NSObject {
@private
    BBTumblrRequestType _requestType;
    
    // ---Reblog Paramerters
    NSString *_reblogKey;
    NSInteger _postID;
    NSString *_comment;
    
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

@property (nonatomic, readwrite, assign) BBTumblrRequestType requestType;

// ---Reblog Parameters
@property (nonatomic, readwrite, copy) NSString *reblogKey;
@property (nonatomic, readwrite, assign) NSInteger postID;
@property (nonatomic, readwrite, copy) NSString *comment;

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

- (id)initWithType:(BBTumblrRequestType)type;

+ (BBTumblrPost *)newPostWithType:(BBTumblrPostType)type;
+ (BBTumblrPost *)reblogPostWithKey:(NSString *)key;

- (BOOL)isReady;

@end
