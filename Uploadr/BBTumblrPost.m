//
//  BBTumblrPost.m
//  Uploadr
//
//  Created by Callum Sulivan on 18/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BBTumblrPost.h"

#define __RELEASE(v) if (v) \
[v release], v = nil;


@implementation BBTumblrPost
@synthesize requestType=_requestType;
@synthesize reblogKey=_reblogKey, postID=_postID, comment=_comment;
@synthesize type=_type, tags=_tags, tweet=_tweet, markdown=_markdown, title=_title, body=_body, caption=_caption, link=_link, source=_source, data=_data, quote=_quote, URL=_URL, description=_description, conversation=_conversation, externalURL=_externalURL, embed=_embed;

- (id)initWithType:(BBTumblrRequestType)type
{
    if ((self = [super init]))
    {
        [self setRequestType:type];
    }
    
    return self;
}

+ (BBTumblrPost *)newPostWithType:(BBTumblrPostType)type
{
    BBTumblrPost *post = [[[[self class] alloc] initWithType:BBTumblrNewPost] autorelease];
    [post setType:type];
    return post;
}

+ (BBTumblrPost *)reblogPostWithKey:(NSString *)key
{
    BBTumblrPost *post = [[[[self class] alloc] initWithType:BBTumblrReblog] autorelease];
    [post setReblogKey:key];
    return post;
}

- (void)dealloc
{
    __RELEASE( _reblogKey );
    __RELEASE( _comment );
    __RELEASE( _tags );
    __RELEASE( _tweet );
    __RELEASE( _title );
    __RELEASE( _caption );
    __RELEASE( _link );
    __RELEASE( _source );
    __RELEASE( _data );
    __RELEASE( _quote );
    __RELEASE( _URL );
    __RELEASE( _description );
    __RELEASE( _conversation );
    __RELEASE( _externalURL );
    __RELEASE( _embed );
    
    [super dealloc];
}


- (BOOL)isReady
{
    BOOL ready = NO;
    
    if (self.requestType == BBTumblrNewPost)
    {
        if (self.type == BBTumblrPostText)
            ready = (self.body != nil)?YES:NO;
        else if (self.type == BBTumblrPostPhoto)
            ready = ((self.source != nil) || (self.data != nil))?YES:NO;
        else if (self.type == BBTumblrPostQuote)
            ready = (self.quote != nil)?YES:NO;
        else if (self.type == BBTumblrPostLink)
            ready = (self.URL != nil)?YES:NO;
        else if (self.type == BBTumblrPostChat)
            ready = (self.conversation != nil)?YES:NO;
        else if (self.type == BBTumblrPostAudio)
            ready = ((self.externalURL != nil) || (self.data != nil))?YES:NO;
        else if (self.type == BBTumblrPostVideo)
            ready = ((self.embed != nil) || (self.data != nil))?YES:NO;
    
    }else
    if (self.requestType == BBTumblrReblog)
    {
        ready = (self.reblogKey != nil)?YES:NO;
    }
    
    return ready;
}

@end
