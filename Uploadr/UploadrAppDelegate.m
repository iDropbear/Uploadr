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
    [tumblr requestTokenWithEmail:@"callum.james@live.com.au" Password:@"nom@d2906"];
}

- (void)tumblrRequest:(NSString *)tumblr receivedAvatar:(NSImage *)avatar
{
    NSImageView *img = [[NSImageView alloc] initWithFrame:(NSRect){{10,128},{128,128}}];
    [img setImage:avatar];
    
    [[window contentView] addSubview:img];
}

- (void)tumblrRequest:(NSString *)identifier receivedResponse:(NSURLResponse *)response
{
    NSLog( @"%lu", [(NSHTTPURLResponse *)response statusCode] );
}

- (void)tumblrRequest:(NSString *)identifier didFailWithError:(NSError *)error
{
    NSLog( @"%@", error );
}

- (void)tumblrRequest:(NSString *)identifier receivedBlogInfo:(NSDictionary *)dictionary
{
    NSLog( @"%@", dictionary );
}

- (void)tumblrRequestUserAuthenticated:(NSString *)identifier
{
    NSLog( @"User authenticated" );
    
    BBTumblr *tumblr = [BBTumblr sharedInstance];
    
    BBTumblrPost *post = [BBTumblrPost newPostWithType:BBTumblrPostText];
    [post setType:BBTumblrPostText];
    [post setTitle:@"This is not a title..."];
    [post setBody:@"I am a fat body full of body'ness....."];
    
    [tumblr createPost:post];
}

- (void)tumblrRequest:(NSString *)identifier newPostCreated:(NSInteger)postID
{
    NSLog( @"New Post Created: %lu", postID );
}

@end
