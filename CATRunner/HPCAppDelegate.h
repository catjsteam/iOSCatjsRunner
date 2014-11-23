//
//  HPCAppDelegate.h
//  CATRunner
//
//  Created by Nadav Vanunu on 1/27/14.
//  Copyright (c) 2014 Nadav Vanunu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HTTPServer;

@interface HPCAppDelegate : UIResponder <UIApplicationDelegate>
{
    UIBackgroundTaskIdentifier m_bgTask;
}

@property (strong, nonatomic) UIWindow *window;
//HTTP server
@property (nonatomic, strong) HTTPServer *httpServer;
- (void)startServer;
- (void)stopServer;

@end
