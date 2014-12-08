//
//  HPCAppDelegate.m
//  CATRunner
//
//  Created by Nadav Vanunu on 1/27/14.
//  Copyright (c) 2014 Nadav Vanunu. All rights reserved.
//

#import "HPCAppDelegate.h"
#import "HTTPServer.h"
#import "HTTPConnection.h"
#import "CATHTTPConnection.h"


#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>


@implementation HPCAppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create server using our custom MyHTTPServer class
	self.httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[_httpServer setType:@"_http._tcp."];
	
    [_httpServer setConnectionClass:[CATHTTPConnection class]];
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
    // TODO: Decide the port number HP wants to work with.
	[_httpServer setPort:54321];
    
    // Serve files from our embedded Web folder
	NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
	NSLog(@"Setting document root: %@", webPath);
	
    [_httpServer setDocumentRoot:webPath];
    [self startServer];
    

    return YES;
}


- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (void)startServer
{
    // Start the server (and check for problems)
    m_bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
        [[UIApplication sharedApplication] endBackgroundTask:m_bgTask];
        m_bgTask = UIBackgroundTaskInvalid;
    }];
	// Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSError *error;
                       if([_httpServer start:&error])
                       {
                           NSLog(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
                           
                           // Now is the moment to update UI
                           [[NSNotificationCenter defaultCenter] postNotificationName:@"ServerHttpStarted" object:self];
                       }
                       else
                       {
                           NSLog(@"Error starting HTTP Server: %@", error);
                       }
                   });
    
}

- (void)stopServer
{
    [_httpServer stop];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
