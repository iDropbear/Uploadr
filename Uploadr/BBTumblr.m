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

- (BOOL)_generateNewPostRequest:(NSMutableArray *)parameters Post:(BBTumblrPost *)post;
- (BOOL)_generateReblogPostRequest:(NSMutableArray *)parameters Post:(BBTumblrPost *)post;

- (void)retrieveAvatarThread:(id)object;
@end

#pragma mark -
#pragma mark Main Methods
@implementation BBTumblr

@synthesize delegate=_delegate, consumer=_consumer, token=_token, hostname=_hostname, transactions=_transactions;

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

- (void)dealloc
{
    __RELEASE(_consumer);
    __RELEASE(_token);
    __RELEASE(_hostname);
    __RELEASE(_transactions);
    
    [super dealloc];
}

- (BOOL)isReadyFor:(BBTumblrRequestType)type
{
    BOOL ready = NO;
    
    if (type == BBTumblrAvatar)
    {
        ready = (self.hostname != nil)?YES:NO;
    }else
    if (type == BBTumblrBlogInfo)
    {
        ready = (self.hostname != nil)?YES:NO;
    }else
    if (type == BBTumblrRequestToken)
    {
        ready = (self.consumer != nil)?YES:NO;
    }else
    if (type == BBTumblrNewPost)
    {
        ready = ((self.consumer != nil) && (self.token != nil) && (self.hostname != nil))?YES:NO;
    }else
    if (type == BBTumblrReblog)
    {
        ready = ((self.consumer != nil) && (self.token != nil) && (self.hostname != nil))?YES:NO;
    }
        
    return ready;
}

#pragma mark -
#pragma mark Request Auth Token
- (NSString *)requestTokenWithEmail:(NSString *)email Password:(NSString *)password
{
    if ((email == nil) || ([email length] <= 0) || (password == nil) || ([password length] <= 0))
    {
        NSLog( @"Email and/or Password Not Entered" );
        return nil;
    }
    if (![self isReadyFor:BBTumblrRequestToken])
    {
        NSLog( @"No Consumer Key" );
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:@"https://www.tumblr.com/oauth/access_token"];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:self.consumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    [request setHTTPMethod:@"POST"];
    
    [request setParameters:[NSArray arrayWithObjects:
                            [OARequestParameter requestParameter:@"x_auth_mode" value:@"client_auth"],
                            [OARequestParameter requestParameter:@"x_auth_username" value:email],
                            [OARequestParameter requestParameter:@"x_auth_password" value:password],
                            nil]];
    
    [request prepare];
    
    BBTumblrConnection *conn = [BBTumblrConnection tumblrConnection];
    
    conn.request = request;
    conn.requestType = BBTumblrRequestToken;
    conn.identifier = [NSString uniqueString];
    
    return [self _createAndStartConnectionForTransaction:conn];
}

#pragma mark -
#pragma mark Blog Avatar
- (NSString *)requestBlogAvatar:(NSString *)blog withSize:(BBTumblrAvatarSize)size
{
    if (![self isReadyFor:BBTumblrAvatar])
    {
        NSLog( @"Avatar Request Error" );
        return nil;
    }
    
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
    if (![self isReadyFor:BBTumblrBlogInfo])
    {
        NSLog( @"Blog Request Error" );
        return nil;
    }
    
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
- (NSString *)createPost:(BBTumblrPost *)post
{
    if ((![self isReadyFor:post.requestType]) || (![post isReady]) )
    {
        NSLog( @"Request\\Post Not Ready" );
        return nil;
    }
    
    OAMutableURLRequest *request;
    BBTumblrConnection *conn = [BBTumblrConnection tumblrConnection];
    
    if (post.requestType == BBTumblrNewPost)
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:URL_POST,self.hostname]];
        
        request = [[OAMutableURLRequest alloc] initWithURL:url 
                                                  consumer:self.consumer 
                                                     token:self.token 
                                                     realm:nil 
                                         signatureProvider:nil];
        
        [request setHTTPMethod:@"POST"];
        
        NSMutableArray *param = [NSMutableArray new];
        // --- Type
        [param addObject:[OARequestParameter requestParameter:@"type" value:[BBTumblrVars postTypeToString:post.type]]];
        
        // --- Tags
        NSMutableString *strTags = [NSMutableString stringWithString:@"Uploadr"];
        if (post.tags)
            [strTags appendFormat:@",%@",[post.tags componentsJoinedByString:@","]];
        [param addObject:[OARequestParameter requestParameter:@"tags" value:strTags]];
        
        // --- Date
        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
        [param addObject:[OARequestParameter requestParameter:@"date" value:[dateFormat stringFromDate:[NSDate date]]]];
        
        [self _generateNewPostRequest:param Post:post];
        
        [request setParameters:param];
        
        conn.requestType = BBTumblrNewPost;
    }
    
    [request prepare];
    
    conn.request = request;
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
    [self _transactionForConnection:connection].wasSuccessful = NO;
    [self _transactionForConnection:connection].error = [error retain];
    
    if ([self.delegate respondsToSelector:@selector(tumblrRequest:didFailWithError:)])
    {        
        [self.delegate tumblrRequest:[self _transactionForConnection:connection].identifier didFailWithError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self _transactionForConnection:connection].response = [response retain];
    [self _transactionForConnection:connection].wasSuccessful = ([(NSHTTPURLResponse *)response statusCode]< 400)?YES:NO;
    
    if ([self.delegate respondsToSelector:@selector(tumblrRequest:receivedResponse:)])
    {
        [self.delegate tumblrRequest:[self _transactionForConnection:connection].identifier receivedResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([self.delegate respondsToSelector:@selector(tumblrRequest:percentageSent:)])
    {
        CGFloat percent = (totalBytesExpectedToWrite/totalBytesWritten);
        [self.delegate tumblrRequest:[self _transactionForConnection:connection].identifier percentageSent:percent];
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
        
        NSArray *array = [NSArray arrayWithObjects:url,conn.identifier,nil];
        
        [NSThread detachNewThreadSelector:@selector(retrieveAvatarThread:) toTarget:self withObject:array];
        return;
    }else
    if (conn.requestType == BBTumblrBlogInfo)
    {
        NSString *string = [NSString stringWithData:conn.receivedData encoding:NSUTF8StringEncoding];
        
        NSDictionary *dict = [string JSONValue];
        
        if ([self.delegate respondsToSelector:@selector(tumblrRequest:receivedBlogInfo:)])
        {
            [self.delegate tumblrRequest:conn.identifier receivedBlogInfo:dict];
        }
    }else
    if (conn.requestType == BBTumblrNewPost)
    {
        NSString *string = [NSString stringWithData:conn.receivedData encoding:NSUTF8StringEncoding];
        
        NSDictionary *dict = [string JSONValue];
        
        NSLog( @"DICT: %@", dict );
        
        if ([self.delegate respondsToSelector:@selector(tumblrRequest:newPostCreated:)])
        {
            NSInteger postID = [[[dict valueForKey:@"response"] valueForKey:@"id"] integerValue];
                        
            [self.delegate tumblrRequest:conn.identifier newPostCreated:postID];
        }
    }else
    if (conn.requestType == BBTumblrRequestToken)
    {
        NSString *string = [NSString stringWithData:conn.receivedData encoding:NSUTF8StringEncoding];
        
        OAToken *token = [[OAToken alloc] initWithHTTPResponseBody:string];
        
        [self setToken:token];
        
        [token release];
        
        if ([self.delegate respondsToSelector:@selector(tumblrRequestUserAuthenticated:)])
        {
            [self.delegate tumblrRequestUserAuthenticated:conn.identifier];
        }
    }
    
}

- (NSURLRequest *)connection:(NSURLConnection *)connection 
             willSendRequest:(NSURLRequest *)request 
            redirectResponse:(NSURLResponse *)response
{        
    BBTumblrConnection *conn = [self _transactionForConnection:connection];
        
    NSURLRequest *req = request;
        
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

- (BOOL)_generateNewPostRequest:(NSMutableArray *)parameters Post:(BBTumblrPost *)post
{
    if (post.type == BBTumblrPostText)
    {        
        if (post.title)
            [parameters addObject:[OARequestParameter requestParameter:@"title" value:post.title]];
        
        [parameters addObject:[OARequestParameter requestParameter:@"body" value:post.body]];
    }
    
    if (post.type == BBTumblrPostPhoto)
    {
        if (post.caption)
            [parameters addObject:[OARequestParameter requestParameter:@"caption" value:post.caption]];
        
        if (post.link)
            [parameters addObject:[OARequestParameter requestParameter:@"link" value:post.link]];
        
        if (post.source)
            [parameters addObject:[OARequestParameter requestParameter:@"source" value:post.source]];
        else
        {
            NSString *dateString = [NSString stringWithData:post.data encoding:NSUTF8StringEncoding];
            [parameters addObject:[OARequestParameter requestParameter:@"data" value:dateString]];
        }
    }
    
    if (post.type == BBTumblrPostQuote)
    {
        [parameters addObject:[OARequestParameter requestParameter:@"quote" value:post.quote]];
        
        if (post.source)
            [parameters addObject:[OARequestParameter requestParameter:@"source" value:post.source]];
    }
    
    if (post.type == BBTumblrPostLink)
    {
        if (post.title)
            [parameters addObject:[OARequestParameter requestParameter:@"title" value:post.title]];
        
        [parameters addObject:[OARequestParameter requestParameter:@"url" value:post.URL]];
        
        if (post.description)
            [parameters addObject:[OARequestParameter requestParameter:@"description" value:post.description]];
    }
    
    if (post.type == BBTumblrPostChat)
    {
        if (post.title)
            [parameters addObject:[OARequestParameter requestParameter:@"title" value:post.title]];
        
        [parameters addObject:[OARequestParameter requestParameter:@"conversation" value:post.conversation]];
    }
    
    if (post.type == BBTumblrPostAudio)
    {
        if (post.caption)
            [parameters addObject:[OARequestParameter requestParameter:@"caption" value:post.caption]];
        
        if (post.externalURL)
            [parameters addObject:[OARequestParameter requestParameter:@"external_url" value:post.externalURL]];
        else
        {
            NSString *dateString = [NSString stringWithData:post.data encoding:NSUTF8StringEncoding];
            [parameters addObject:[OARequestParameter requestParameter:@"data" value:dateString]];
        }
    }
    
    if (post.type == BBTumblrPostVideo)
    {
        if (post.caption)
            [parameters addObject:[OARequestParameter requestParameter:@"caption" value:post.caption]];
        
        if (post.embed)
            [parameters addObject:[OARequestParameter requestParameter:@"embed" value:post.externalURL]];
        else
        {
            NSString *dateString = [NSString stringWithData:post.data encoding:NSUTF8StringEncoding];
            [parameters addObject:[OARequestParameter requestParameter:@"data" value:dateString]];
        }
    }
    
    return YES;
}

- (BOOL)_generateReblogPostRequest:(NSMutableArray *)parameters Post:(BBTumblrPost *)post
{
    [parameters addObject:[OARequestParameter requestParameter:@"reblog_key" value:post.reblogKey]];
    
    if (post.postID)
        [parameters addObject:[OARequestParameter requestParameter:@"id" value:[NSString stringWithFormat:@"%lu",post.postID]]];
    
    if (post.comment)
        [parameters addObject:[OARequestParameter requestParameter:@"comment" value:post.comment]];
    
    return YES;
}


- (void)retrieveAvatarThread:(id)object
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSData *data = [[[NSData alloc] initWithContentsOfURL:[object objectAtIndex:0]] autorelease];
    
    NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];
    
    if ([self.delegate respondsToSelector:@selector(tumblrRequest:receivedAvatar:)])
    {
        [self.delegate tumblrRequest:[object objectAtIndex:1] receivedAvatar:image];
    }
    
    [pool drain];
}

@end
