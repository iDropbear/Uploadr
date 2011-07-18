//
//  BBTumblrVars.m
//  Uploadr
//
//  Created by Callum Sulivan on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BBTumblrVars.h"


@implementation BBTumblrVars

+ (NSString *)postTypeToString:(BBTumblrPostType)type
{
    switch( type )
    {
        case BBTumblrPostText:
            return @"text";
        case BBTumblrPostPhoto:
            return @"photo";
        case BBTumblrPostQuote:
            return @"quote";
        case BBTumblrPostLink:
            return @"link";
        case BBTumblrPostChat:
            return @"chat";
        case BBTumblrPostAudio:
            return @"audio";
        case BBTumblrPostVideo:
            return @"video";
    }
    return @"";
}

+ (BBTumblrPostType)postTypeFromString:(NSString *)string
{
    if ([string isEqualToString:@"text"])
        return BBTumblrPostText;
    
    if ([string isEqualToString:@"photo"])
        return BBTumblrPostPhoto;
    
    if ([string isEqualToString:@"quote"])
        return BBTumblrPostQuote;
    
    if ([string isEqualToString:@"link"])
        return BBTumblrPostLink;
    
    if ([string isEqualToString:@"chat"])
        return BBTumblrPostChat;
    
    if ([string isEqualToString:@"audio"])
        return BBTumblrPostAudio;
    
    if ([string isEqualToString:@"video"])
        return BBTumblrPostVideo;
    
    return -1;
}

@end
