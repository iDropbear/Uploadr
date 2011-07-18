//
//  BBTumblr.m
//  Uploadr
//
//  Created by Callum Sulivan on 17/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BBTumblr.h"
#import "BBTumblrConnection.h"
#import "NSString+Tumblr.h"
#import "BBError.h"
#import "SBJson.h"

#define __RELEASE(v) if (v) \
[v release], v = nil;

// URLS
#define URL_POST @"http://api.tumblr.com/v2/blog/%@/post"
#define URL_REBLOG @"http://api.tumblr.com/v2/blog/%@/post/reblog"
#define URL_AVATAR @"http://api.tumblr.com/v2/blog/%@/avatar/%@"
#define URL_BLOGINFO @"http://api.tumblr.com/v2/blog/%@/info?api_key=%@"

static BBTumblr *shared = nil;

#pragma mark Private Method Declarations
@interface BBTumblr()
- (NSString *)_createAndStartConnectionForTransaction:(BBTumblrConnection *)transaction;
- (BBTumblrConnection *)_transactionForConnection:(NSURLConnection *)connection;
- (BBTumblrConnection *)_transactionForConnectionIdentifier:(NSString *)connectionIdentifier;

- (BOOL)_generateNewPostRequest:(NSMutableArray *)parameters;
- (BOOL)_generateReblogPostRequest:(NSMutableArray *)parameters;

- (void)retrieveAvatarThread:(id)object;
@end

#pragma mark -
#pragma mark Main Methods
@implementation BBTumblr

@synthesize delegate=_delegate, consumer=_consumer, token=_token, hostname=_hostname, transactions=_transactions;

@synthesize type=_type, tags=_tags, tweet=_tweet, markdown=_markdown, title=_title, body=_body, caption=_caption, link=_link, source=_source, data=_data, quote=_quote, URL=_URL, description=_description, conversation=_conversation, externalURL=_externalURL, embed=_embed;

+ (BBTumblr *)sharedInstance
{
    if (shared == nil)
    {
        shared = [[[self class] alloc] init];
    }
    return shared;
}

- (id)init
{
    if ((self = [super init]))
    {
        _transactions = [[NSMutableSet alloc] init];
    }
    return self;
}

- (BOOL)isReady
{
    BOOL ready = NO;
    
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
    
    ready = (ready && (self.consumer != nil) && (self.token != nil) && (self.hostname != nil));
    
    return ready;
}

#pragma mark -
#pragma mark Blog Avatar
- (NSString *)requestBlogAvatar:(NSString *)blog withSize:(BBTumblrAvatarSize)size
{
    NSString *blogName;
    if (blog == nil)
        blogName = self.hostname;
    else
        blogName = blog;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:URL_AVATAR,blogName,[NSString stringWithFormat:@"%lu",size]]];
        
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    [request setHTTPMethod:@"GET"];
    
    BBTumblrConnection *conn = [BBTumblrConnection tumblrConnection];
    conn.request = request;
    conn.identifier = [NSString uniqueString];
    conn.requestType = BBTumblrAvatar;
    
    return [self _createAndStartConnectionForTransaction:conn];
}

#pragma mark -
#pragma mark Blog Info
- (NSString *)requestBlogInfo:(NSString *)blog
{
    NSString *blogName;
    if (blog == nil)
        blogName = self.hostname;
    else
        blogName = blog;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:URL_BLOGINFO,blogName,self.consumer.key]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    BBTumblrConnection *conn = [BBTumblrConnection tumblrConnection];
    conn.request = request;
    conn.identifier = [NSString uniqueString];
    conn.requestType = BBTumblrBlogInfo;
    
    return [self _createAndStartConnectionForTransaction:conn];
}

#pragma mark -
#pragma mark Create new Post
- (NSString *)createNewPost
{
    if (![self isReady])
    {
        NSLog( @"Not Ready" );
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:URL_POST,self.hostname]];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url 
                                                                   consumer:self.consumer 
                                                                      token:self.token 
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
    
    [self _generateNewPostRequest:param];
    
    [request setParameters:param];
    
    [request prepare];
    
    BBTumblrConnection *conn = [BBTumblrConnection tumblrConnection];
    conn.request = request;
    conn.requestType = BBTumblrNewPost;
    conn.identifier = [NSString uniqueString];
    
    return [self _createAndStartConnectionForTransaction:conn];
}

#pragma mark -
#pragma mark Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self _transactionForConnection:connection].receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{    
    if ([self.delegate respondsToSelector:@selector(tumblrRequest:didFailWithError:)])
    {
        BBError *_error = [BBError errorWithDescription:[error domain] 
                                                andCode:[error code] 
                                               andClass:[self class]];
        [self.delegate tumblrRequest:self didFailWithError:_error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self _transactionForConnection:connection].response = [response retain];
    
    if ([self.delegate respondsToSelector:@selector(tumblrRequest:receivedResponse:)])
    {
        [self.delegate tumblrRequest:self receivedResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([self.delegate respondsToSelector:@selector(tumblrRequest:percentageSent:)])
    {
        CGFloat percent = (totalBytesExpectedToWrite/totalBytesWritten);
        [self.delegate tumblrRequest:self percentageSent:percent];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    BBTumblrConnection *conn = [self _transactionForConnection:connection];
    
    if (conn.requestType == BBTumblrAvatar)
    {
        NSString *string = [NSString stringWithData:conn.receivedData encoding:NSUTF8StringEncoding];
        
        NSDictionary *dict = [string JSONValue];
                
        NSURL *url = [NSURL URLWithString:[[dict valueForKey:@"response"] valueForKey:@"avatar_url"]];
        
        [NSThread detachNewThreadSelector:@selector(retrieveAvatarThread:) toTarget:self withObject:url];
        return;
    }else
    if (conn.requestType == BBTumblrBlogInfo)
    {
        NSString *string = [NSString stringWithData:conn.receivedData encoding:NSUTF8StringEncoding];
        
        NSDictionary *dict = [string JSONValue];
        
        if ([self.delegate respondsToSelector:@selector(tumblrRequest:receivedBlogInfo:)])
        {
            [self.delegate tumblrRequest:self receivedBlogInfo:dict];
        }
    }
    
}

- (NSURLRequest *)connection:(NSURLConnection *)connection 
             willSendRequest:(NSURLRequest *)request 
            redirectResponse:(NSURLResponse *)response
{        
    BBTumblrConnection *conn = [self _transactionForConnection:connection];
        
    NSURLRequest *req = request;
    
    NSLog( @"%@", [req allHTTPHeaderFields] );
    
    if (conn.requestType == BBTumblrAvatar)
    {
        NSLog( @"Reject redirect" );
        
        if (response)
        {
            NSLog( @"Cancel Redirect" );
            req = nil;
        }
    }
    
    return req;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    BBTumblrConnection *conn = [self _transactionForConnection:connection];
    
    if (conn.requestType == BBTumblrAvatar)
    {
        return nil;
    }
    
    return cachedResponse;
}


#pragma mark -
#pragma mark Private Methods
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

- (BOOL)_generateNewPostRequest:(NSMutableArray *)parameters
{
    if (self.type == BBTumblrPostText)
    {        
        if (self.title)
            [parameters addObject:[OARequestParameter requestParameter:@"title" value:self.title]];
        
        [parameters addObject:[OARequestParameter requestParameter:@"body" value:self.body]];
    }
    
    if (self.type == BBTumblrPostPhoto)
    {
        if (self.caption)
            [parameters addObject:[OARequestParameter requestParameter:@"caption" value:self.caption]];
        
        if (self.link)
            [parameters addObject:[OARequestParameter requestParameter:@"link" value:self.link]];
        
        if (self.source)
            [parameters addObject:[OARequestParameter requestParameter:@"source" value:self.source]];
        else
        {
            NSString *dateString = [NSString stringWithData:self.data encoding:NSUTF8StringEncoding];
            [parameters addObject:[OARequestParameter requestParameter:@"data" value:dateString]];
        }
    }
    
    if (self.type == BBTumblrPostQuote)
    {
        [parameters addObject:[OARequestParameter requestParameter:@"quote" value:self.quote]];
        
        if (self.source)
            [parameters addObject:[OARequestParameter requestParameter:@"source" value:self.source]];
    }
    
    if (self.type == BBTumblrPostLink)
    {
        if (self.title)
            [parameters addObject:[OARequestParameter requestParameter:@"title" value:self.title]];
        
        [parameters addObject:[OARequestParameter requestParameter:@"url" value:self.URL]];
        
        if (self.description)
            [parameters addObject:[OARequestParameter requestParameter:@"description" value:self.description]];
    }
    
    if (self.type == BBTumblrPostChat)
    {
        if (self.title)
            [parameters addObject:[OARequestParameter requestParameter:@"title" value:self.title]];
        
        [parameters addObject:[OARequestParameter requestParameter:@"conversation" value:self.conversation]];
    }
    
    if (self.type == BBTumblrPostAudio)
    {
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


- (void)retrieveAvatarThread:(id)object
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSData *data = [[[NSData alloc] initWithContentsOfURL:object] autorelease];
    
    NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];
    
    if ([self.delegate respondsToSelector:@selector(tumblrRequest:receivedAvatar:)])
    {
        [self.delegate tumblrRequest:self receivedAvatar:image];
    }
    
    [pool drain];
}

@end
