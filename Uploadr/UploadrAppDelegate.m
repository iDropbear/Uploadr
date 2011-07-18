//
//  UploadrAppDelegate.m
//  Uploadr
//
//  Created by Callum Sulivan on 13/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UploadrAppDelegate.h"
#import "AuthCodes.h"
#import "NSString+Tumblr.h"
#import "BBTumblrRequest.h"
#import "BBTumblr.h"
#import "BBError.h"

#import "SBJson.h"

@implementation UploadrAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib
{
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"aITAmWfUm6AYvOtv7egIJ3G7oEjdvBNLEebfoRfppk8U6dFTAZ" 
                                                     secret:@"ctNO0ChdvC3o089OVYAjrpQqSEFYSOFm959KTIbAiVGuyTaYQw"] autorelease];
    
    /*
    receivedData = [[NSMutableData alloc] init];
    
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"aITAmWfUm6AYvOtv7egIJ3G7oEjdvBNLEebfoRfppk8U6dFTAZ" 
                                                     secret:@"ctNO0ChdvC3o089OVYAjrpQqSEFYSOFm959KTIbAiVGuyTaYQw"] autorelease];
    
    NSURL *url = [NSURL URLWithString:@"https://www.tumblr.com/oauth/access_token"];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    [request setHTTPMethod:@"POST"];
    
    [request setParameters:[NSArray arrayWithObjects:
                            [OARequestParameter requestParameter:@"x_auth_mode" value:@"client_auth"],
                            [OARequestParameter requestParameter:@"x_auth_username" value:@"callum.james@live.com.au"],
                            [OARequestParameter requestParameter:@"x_auth_password" value:@"nom@d2906"],
                            nil]];
        
    
    
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request 
                         delegate:self 
                didFinishSelector:@selector(_setAccessToken:withData:) 
                  didFailSelector:@selector(_fail:data:)];
     */
        
    BBTumblr *tumblr = [BBTumblr sharedInstance];
    [tumblr setConsumer:consumer];
    [tumblr setDelegate:self];
    [tumblr setHostname:@"fourdoublefiveone.tumblr.com"];
    //[tumblr requestBlogAvatar:nil withSize:BBTumblrAvatar128];
    [tumblr requestBlogInfo:nil];
}

- (void)tumblrRequest:(BBTumblr *)tumblr receivedAvatar:(NSImage *)avatar
{
    NSImageView *img = [[NSImageView alloc] initWithFrame:(NSRect){{10,128},{128,128}}];
    [img setImage:avatar];
    
    [[window contentView] addSubview:img];
}

- (void)tumblrRequest:(BBTumblr *)tumblr receivedResponse:(NSURLResponse *)response
{
    NSLog( @"%lu", [(NSHTTPURLResponse *)response statusCode] );
}

- (void)tumblrRequest:(BBTumblr *)tumblr didFailWithError:(BBError *)error
{
    NSLog( @"%@", [error description] );
}

- (void)tumblrRequest:(BBTumblr *)tumblr receivedBlogInfo:(NSDictionary *)dictionary
{
    NSLog( @"%@", dictionary );
}

- (void)fail:(OAServiceTicket *)ticket data:(NSData *)data
{
    NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog( @"FAIL - %@", dataString );
}

- (void)_setAccessToken:(OAServiceTicket *)ticket withData:(NSData *)data
{
    NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    OAToken *token = [[OAToken alloc] initWithHTTPResponseBody:dataString];
    
    NSLog( @"SUCCESS - token: %@ \n token_secret: %@", token.key, token.secret );
    
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"aITAmWfUm6AYvOtv7egIJ3G7oEjdvBNLEebfoRfppk8U6dFTAZ" 
                                                     secret:@"ctNO0ChdvC3o089OVYAjrpQqSEFYSOFm959KTIbAiVGuyTaYQw"] autorelease];
    
    BBTumblrRequest *post = [[BBTumblrRequest alloc] initNewPostWithBlog:@"cokebongsandsingalongs.tumblr.com" Type:BBTumblrPostText];
    [post setTitle:@"I am the title, hear me roaw"];
    [post setBody:@"I not a body, i'm the booooody"];
    OAMutableURLRequest *request = [post generateRequest:consumer token:token];
    
    
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request 
                         delegate:self 
                didFinishSelector:@selector(_postSent:withData:) 
                  didFailSelector:@selector(_fail:data:)];
    
}

- (void)_postSent:(OAServiceTicket *)ticket withData:(NSData *)data
{
    NSString *dataString = [NSString stringWithData:data encoding:NSUTF8StringEncoding];
    
    id value = [dataString JSONValue];
    
    NSLog( @"POSTED - %@", [value allKeys] );
}

@end
