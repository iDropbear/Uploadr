//
//  UploadrAppDelegate.h
//  Uploadr
//
//  Created by Callum Sulivan on 13/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OAuthConsumer/OAuthConsumer.h"
#import "BBTumblrDelegate.h"

@interface UploadrAppDelegate : NSObject <NSApplicationDelegate,BBTumblrDelegate> {
@private
    NSWindow *window;
    
    NSMutableData *receivedData;
}

@property (assign) IBOutlet NSWindow *window;

@end
