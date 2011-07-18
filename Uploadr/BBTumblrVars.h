//
//  BBTumblrVars.h
//  Uploadr
//
//  Created by Callum Sulivan on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    BBTumblrPostText = 0,
    BBTumblrPostPhoto,
    BBTumblrPostQuote,
    BBTumblrPostLink,
    BBTumblrPostChat,
    BBTumblrPostAudio,
    BBTumblrPostVideo
} BBTumblrPostType;

typedef enum
{
    BBTumblrFormatHTML = 0,
    BBTumblrFormatMarkdown
} BBTumblrPostFormat;

typedef enum
{
    BBTumblrAvatar16 = 16,
    BBTumblrAvatar24 = 24,
    BBTumblrAvatar30 = 30,
    BBTumblrAvatar40 = 40,
    BBTumblrAvatar48 = 48,
    BBTumblrAvatar64 = 64,
    BBTumblrAvatar96 = 96,
    BBTumblrAvatar128 = 128,
    BBTumblrAvatar512 = 512
} BBTumblrAvatarSize;

typedef enum
{
    BBTumblrNewPost = 0,
    BBTumblrReblog,
    BBTumblrAvatar,
    BBTumblrBlogInfo
} BBTumblrRequestType;

@interface BBTumblrVars : NSObject

// Post Type Conversion
+ (NSString *)postTypeToString:(BBTumblrPostType)type;
+ (BBTumblrPostType)postTypeFromString:(NSString *)string;

@end
