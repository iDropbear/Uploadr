//
//  BBTumblrConnection.m
//  BBScopeBar
//
//  Created by Callum Sulivan on 8/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BBTumblrConnection.h"


@implementation BBTumblrConnection

@synthesize connection=_connection, 
request=_request, 
response=_response, 
receivedData=_receivedData, 
identifier=_identifier, 
requestType=_requestType;

+ (id)tumblrConnection
{
    return [[[[self class] alloc] init] autorelease];
}

- (id)init
{
    if ((self = [super init])) 
    {
        _receivedData = [[NSMutableData alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_connection release], _connection = nil;
    [_request release], _request = nil;
    [_response release], _response = nil;
    [_receivedData release], _receivedData = nil;
    [_identifier release], _identifier = nil;
    
    [super dealloc];
}

@end
