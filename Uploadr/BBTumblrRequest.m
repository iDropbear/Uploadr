//
//  BBTumblrRequest.m
//  Uploadr
//
//  Created by Callum Sulivan on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BBTumblrRequest.h"
#import "NSString+Tumblr.h"
#import "BBError.h"
#import "BBTumblrConnection.h"

#define __RELEASE(v) if (v) \
[v release], v = nil;

// URLS
#define URL_POST @"http://api.tumblr.com/v2/blog/%@/post"
#define URL_REBLOG @"http://api.tumblr.com/v2/blog/%@/post/reblog"
#define URL_AVATAR @"http://api.tumblr.com/v2/blog/%@/avatar/%@"
#define URL_BLOGINFO @"http://api.tumblr.com/v2/blog/%@/info"


#pragma mark Private Methods Declarations
@interface BBTumblrRequest()
- (BOOL)_generateNewPostRequest:(NSMutableArray *)parameters;
- (BOOL)_generateReblogPostRequest:(NSMutableArray *)parameters;
- (void)_generateThreadImage:(id)object;

- (NSString *)_createAndStartConnectionForTransaction:(BBTumblrConnection *)transaction;
- (BBTumblrConnection *)_transactionForConnection:(NSURLConnection *)connection;
- (BBTumblrConnection *)_transactionForConnectionIdentifier:(NSString *)connectionIdentifier;
@end

#pragma mark -
#pragma mark Main Methods
@implementation BBTumblrRequest

@synthesize consumer=_consumer, token=_token, transactions=_transactions;

@synthesize avatarSize=_avatarSize, blog=_blog, delegate=_delegate, type=_type, tags=_tags, tweet=_tweet, markdown=_markdown, title=_title, body=_body, caption=_caption, link=_link, source=_source, photoData=_photoData, quote=_quote, URL=_URL, description=_description, conversation=_conversation, externalURL=_externalURL, data=_data, embed=_embed, id=_id, reblogKey=_reblogKey, comment=_comment;


- (id)initWithConsumer:(OAConsumer *)consumer token:(OAToken *)token baseHostName:(NSString *)hostName
{
    if ((self = [super init]))
    {
        [self setConsumer:consumer];
        [self setToken:token];
        [self setBlog:hostName];
    }
    return self;
}

- (void)prepareFor:(BBTumblrRequestType)type
{
    __type = type;
    
    __RELEASE( __URL );
    
    if (type == BBTumblrNewPost)
        __URL = [NSURL URLWithString:[NSString stringWithFormat:URL_POST,self.blog]];
    else if (type == BBTumblrReblog)
        __URL = [NSURL URLWithString:[NSString stringWithFormat:URL_REBLOG,self.blog]];
    else if (type == BBTumblrAvatar)
        __URL = [NSURL URLWithString:[NSString stringWithFormat:URL_AVATAR,self.blog,(!self.avatarSize)?@"64":[NSString stringWithFormat:@"%lu",self.avatarSize]]];
    else if (type == BBTumblrBlogInfo)
        __URL = [NSURL URLWithString:[NSString stringWithFormat:URL_BLOGINFO,self.blog]];
    
    [__URL retain];
}

- (NSString *)retrieveBlogInfo
{
    if (__type != BBTumblrBlogInfo)
    {
        NSLog( @"New prepared for retriving blog info." );
        return;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:__URL];
    [request setHTTPMethod:@"GET"];
    
    NSString *data = [NSString stringWithFormat:@"api_key=%@",
                      [self.consumer.key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    BBTumblrConnection *connection = [BBTumblrConnection tumblrConnection];
    connection.request = request;
    connection.identifier = [NSString uniqueString];
    connection.requestType = BBTumblrBlogInfo;
    
    return [self _createAndStartConnectionForTransaction:connection];
}

#pragma mark -
#pragma mark Avatar Retriver
- (void)retrieveAvatar
{
    if (!self.blog)
    {
        NSLog( @"No Blog Name." );
        return;
    }
    
    _avatarLoaded = NO;
    [NSThread detachNewThreadSelector:@selector(_generateThreadImage:) 
                             toTarget:self 
                           withObject:nil];
}

- (NSImage *)avatarImage
{
    if (!_avatarLoaded)
        return nil;
    
    return _avatar;
}


#pragma mark -
#pragma mark Default Call Defaults
- (void)dealloc
{
    __RELEASE( self.blog );
    __RELEASE( self.tags );
    __RELEASE( self.tweet );
    __RELEASE( self.title );
    __RELEASE( self.body );
    __RELEASE( self.caption );
    __RELEASE( self.link );
    __RELEASE( self.source );
    __RELEASE( self.photoData );
    __RELEASE( self.quote );
    __RELEASE( self.URL );
    __RELEASE( self.description );
    __RELEASE( self.conversation );
    __RELEASE( self.externalURL );
    __RELEASE( self.data );
    __RELEASE( self.embed );
    __RELEASE( self.reblogKey );
    __RELEASE( self.comment );
    __RELEASE( _avatar );
    __RELEASE( __URL );
    
    [super dealloc];
}

- (NSString *)description
{
    NSString *str = [NSString stringWithFormat:@"<BBTumblrPost: %p>", self ];
    return str;
}

#pragma mark -
#pragma mark OAMutableRequest Generaters
- (OAMutableURLRequest *)generateRequest:(OAConsumer *)consumer token:(OAToken *)token
{    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:__URL 
                                                                   consumer:consumer 
                                                                      token:token 
                                                                      realm:nil 
                                                          signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    
    NSMutableArray *param = [NSMutableArray new];
    // --- Type
    [param addObject:[OARequestParameter requestParameter:@"type" value:[BBTumblrVars postTypeToString:self.type]]];
    
    // --- Tags
    NSMutableString *strTags = [NSMutableString stringWithString:@"Uploadr"];
    if (self.tags)
        [strTags appendFormat:@",%@",[self.tags componentsJoinedByString:@","]];
    [param addObject:[OARequestParameter requestParameter:@"tags" value:strTags]];
    
    // --- Date
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [param addObject:[OARequestParameter requestParameter:@"date" value:[dateFormat stringFromDate:[NSDate date]]]];
    
    // --- Tweet
    if (self.tweet)
        [param addObject:[OARequestParameter requestParameter:@"tweet" value:self.tweet]];
    
    // --- markdown
    [param addObject:[OARequestParameter requestParameter:@"markdown" value:(self.markdown?@"1":@"0")]];
    
    if (__type == BBTumblrNewPost)
    {
        if (![self _generateNewPostRequest:param])
        {
            [request release];
            return nil;
        }
    }else
    if (__type == BBTumblrReblog)
    {
        if (![self _generateReblogPostRequest:param])
        {
            [request release];
            return nil;
        }
    }
    
    [request setParameters:param];
    
    return request;
}

#pragma mark -
#pragma mark Connection delegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(tumblrRequest:didFailWithError:)])
    {
        BBError *bbError = [BBError errorWithDescription:[error domain]
                                                 andCode:[error code]
                                                andClass:[self class]];
        [self.delegate tumblrRequest:self didFailWithError:bbError];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([self.delegate respondsToSelector:@selector(tumblrRequest:receivedResponse:)])
    {
        [self.delegate tumblrRequest:self receivedResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
}

#pragma mark -
#pragma mark Private Methods
- (BOOL)_generateNewPostRequest:(NSMutableArray *)parameters
{
    if (self.type == BBTumblrPostText)
    {        
        if (!self.body)
        {
            NSLog( @"No Body?" );
            return NO;
        }
        
        NSLog( @"Title - %@", self.title );
        NSLog( @"Body - %@", self.body );
        
        if (self.title)
            [parameters addObject:[OARequestParameter requestParameter:@"title" value:self.title]];
        
        [parameters addObject:[OARequestParameter requestParameter:@"body" value:self.body]];
    }
    
    if (self.type == BBTumblrPostPhoto)
    {
        if (!self.source || !self.photoData)
        {
            NSLog( @"No Source or Data" );
            return NO;
        }
        
        if (self.caption)
            [parameters addObject:[OARequestParameter requestParameter:@"caption" value:self.caption]];
        
        if (self.link)
            [parameters addObject:[OARequestParameter requestParameter:@"link" value:self.link]];
        
        if (self.source)
            [parameters addObject:[OARequestParameter requestParameter:@"source" value:self.source]];
        else
        {
            NSData *data = [self.photoData objectAtIndex:0];
            NSString *dateString = [NSString stringWithData:data encoding:NSUTF8StringEncoding];
            
            [parameters addObject:[OARequestParameter requestParameter:@"data" value:dateString]];
        }
    }
    
    if (self.type == BBTumblrPostQuote)
    {
        if (!self.quote)
        {
            NSLog( @"No Quote" );
            return NO;
        }
        
        [parameters addObject:[OARequestParameter requestParameter:@"quote" value:self.quote]];
        
        if (self.source)
            [parameters addObject:[OARequestParameter requestParameter:@"source" value:self.source]];
    }
    
    if (self.type == BBTumblrPostLink)
    {
        if (!self.URL)
        {
            NSLog( @"No URL" );
            return NO;
        }
        
        if (self.title)
            [parameters addObject:[OARequestParameter requestParameter:@"title" value:self.title]];
        
        [parameters addObject:[OARequestParameter requestParameter:@"url" value:self.URL]];
        
        if (self.description)
            [parameters addObject:[OARequestParameter requestParameter:@"description" value:self.description]];
    }
    
    if (self.type == BBTumblrPostChat)
    {
        if (!self.conversation)
        {
            NSLog( @"No Conversation" );
            return NO;
        }
        
        if (self.title)
            [parameters addObject:[OARequestParameter requestParameter:@"title" value:self.title]];
        
        [parameters addObject:[OARequestParameter requestParameter:@"conversation" value:self.conversation]];
    }
    
    if (self.type == BBTumblrPostAudio)
    {
        if (!self.externalURL || !self.data)
        {
            NSLog( @"No External URL or Data" );
            return NO;
        }
        
        if (self.caption)
            [parameters addObject:[OARequestParameter requestParameter:@"caption" value:self.caption]];
        
        if (self.externalURL)
            [parameters addObject:[OARequestParameter requestParameter:@"external_url" value:self.externalURL]];
        else
        {
            NSString *dateString = [NSString stringWithData:self.data encoding:NSUTF8StringEncoding];
            
            [parameters addObject:[OARequestParameter requestParameter:@"data" value:dateString]];
        }
    }
    
    if (self.type == BBTumblrPostVideo)
    {
        if (!self.embed || !self.data)
        {
            NSLog( @"No Embed String or Data" );
            return NO;
        }
        
        if (self.caption)
            [parameters addObject:[OARequestParameter requestParameter:@"caption" value:self.caption]];
        
        if (self.embed)
            [parameters addObject:[OARequestParameter requestParameter:@"embed" value:self.externalURL]];
        else
        {
            NSString *dateString = [NSString stringWithData:self.data encoding:NSUTF8StringEncoding];
            
            [parameters addObject:[OARequestParameter requestParameter:@"data" value:dateString]];
        }
    }
    
    return YES;
}

- (BOOL)_generateReblogPostRequest:(NSMutableArray *)parameters
{
    if (!self.reblogKey)
    {
        NSLog( @"No Reblog Key" );
        return NO;
    }
    
    [parameters addObject:[OARequestParameter requestParameter:@"reblog_key" value:self.reblogKey]];
    
    if (self.id)
        [parameters addObject:[OARequestParameter requestParameter:@"id" value:[NSString stringWithFormat:@"%lu",self.id]]];
    
    if (self.comment)
        [parameters addObject:[OARequestParameter requestParameter:@"comment" value:self.comment]];
    
    return YES;
}

- (void)_generateThreadImage:(id)object
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:__URL];
    
    _avatar = [[NSImage alloc] initWithData:data];
    
    if (_avatar != nil)
        _avatarLoaded = YES;
    
    if ([self.delegate respondsToSelector:@selector(tumblrRequestAvatarLoaded:)])
    {
        [self.delegate tumblrRequestAvatarLoaded:self];
    }
    
    [data release];
    
    [pool drain];
}

- (NSString *)_createAndStartConnectionForTransaction:(BBTumblrConnection *)transaction
{
    // Create & start connection
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:transaction.request
                                                                  delegate:self
                                                          startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    transaction.connection = connection;
    [self.transactions addObject:transaction];
    [connection start];
    [connection release];
    
    return transaction.identifier;
}

- (BBTumblrConnection *)_transactionForConnection:(NSURLConnection *)connection
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"connection = %@", connection];
    NSSet *resultSet = [self.transactions filteredSetUsingPredicate:predicate];
    return [resultSet anyObject];
}

- (BBTumblrConnection *)_transactionForConnectionIdentifier:(NSString *)connectionIdentifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier = %@", connectionIdentifier];
    NSSet *resultSet = [self.transactions filteredSetUsingPredicate:predicate];
    return [resultSet anyObject];
}

@end
