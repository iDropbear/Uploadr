//
//  BBTumblrConnection.h
//  BBScopeBar
//
//  Created by Callum Sulivan on 8/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBTumblrVars.h"

@interface BBTumblrConnection : NSObject {
@private
    NSURLConnection *_connection;
    NSHTTPURLResponse *_response;
    NSMutableURLRequest *_request;
    NSMutableData *_receivedData;
    
    NSString *_identifier;
    
    BBTumblrRequestType _requestType;
}

@property (nonatomic, readwrite, retain) NSURLConnection *connection;
@property (nonatomic, readwrite, retain) NSHTTPURLResponse *response;
@property (nonatomic, readwrite, retain) NSMutableURLRequest *request;
@property (nonatomic, readwrite, retain) NSMutableData *receivedData;
@property (nonatomic, readwrite, copy) NSString *identifier;
@property (nonatomic, readwrite, assign) BBTumblrRequestType requestType;


+ (id)tumblrConnection;

@end
