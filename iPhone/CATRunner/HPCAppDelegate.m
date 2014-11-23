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
    
//    
//    int mib[2U] = { CTL_HW, HW_NCPU };
//    size_t sizeOfNumCPUs = sizeof(numCPUs);
//    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
//    if(status)
//        numCPUs = 1;
//    
//    CPUUsageLock = [[NSLock alloc] init];
//    
//    updateTimer = [NSTimer scheduledTimerWithTimeInterval:4
//                                                   target:self
//                                                 selector:@selector(updateInfo:)
//                                                 userInfo:nil
//                                                  repeats:YES];
    
    return YES;
}

//
//- (NSInteger)totalMemory {
//    int nearest = 256;
//    natural_t temp = [[NSProcessInfo processInfo] physicalMemory];
//    int totalMemory = [self transformeToMB:temp];
//    
//    int rem = (int)totalMemory % nearest;
//    int tot = 0;
//    if (rem >= nearest/2) {
//        tot = ((int)totalMemory - rem)+256;
//    } else {
//        tot = ((int)totalMemory - rem);
//    }
//    
//    return tot;
//}
//
//- (CGFloat)freeMemory {
//    double totalMemory = 0.00;
//    vm_statistics_data_t vmStats;
//    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
//    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
//    if(kernReturn != KERN_SUCCESS) {
//        return -1;
//    }
//    totalMemory = [self transformeToMB:(vm_page_size * vmStats.free_count)];
//    
//    return totalMemory;
//}
//
//- (CGFloat)usedMemory {
//    double usedMemory = 0.00;
//    vm_statistics_data_t vmStats;
//    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
//    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
//    if(kernReturn != KERN_SUCCESS) {
//        return -1;
//    }
//    usedMemory = [self transformeToMB:(vm_page_size * (vmStats.active_count + vmStats.inactive_count + vmStats.wire_count))];
//    
//    return usedMemory;
//}
//
//- (CGFloat)activeMemory {
//    double activeMemory = 0.00;
//    vm_statistics_data_t vmStats;
//    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
//    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
//    if(kernReturn != KERN_SUCCESS) {
//        return -1;
//    }
//    activeMemory = [self transformeToMB:(vm_page_size * vmStats.active_count)];
//    
//    return activeMemory;
//}
//
//- (CGFloat)wiredMemory {
//    double wiredMemory = 0.00;
//    vm_statistics_data_t vmStats;
//    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
//    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
//    if(kernReturn != KERN_SUCCESS) {
//        return -1;
//    }
//    wiredMemory = [self transformeToMB:(vm_page_size * vmStats.wire_count)];
//    
//    return wiredMemory;
//}
//
//- (CGFloat)inactiveMemory {
//    double inactiveMemory = 0.00;
//    vm_statistics_data_t vmStats;
//    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
//    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
//    if(kernReturn != KERN_SUCCESS) {
//        return -1;
//    }
//    inactiveMemory = [self transformeToMB:(vm_page_size * vmStats.inactive_count)];
//    
//    return inactiveMemory;
//}
//
//-(NSArray *)getCPU
//{
//    
//    NSMutableArray *cpuArgs = [[NSMutableArray alloc] initWithCapacity:0];
//
//    natural_t numCPUsU = 0U;
//    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
//    
//    // get cpu usage
//    if(err == KERN_SUCCESS) {
//        [CPUUsageLock lock];
//        
//        for(unsigned i = 0U; i < numCPUs; ++i) {
//            float inUse, total;
//            if(prevCpuInfo) {
//                inUse = (
//                         (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
//                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
//                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
//                         );
//                total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
//            } else {
//                inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
//                total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
//            }
//            [cpuArgs addObject:[NSNumber numberWithDouble:inUse]];
//            [cpuArgs addObject:[NSNumber numberWithDouble:total]];
//        }
//        [CPUUsageLock unlock];
//        
//        if(prevCpuInfo) {
//            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
//            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
//        }
//        
//        prevCpuInfo = cpuInfo;
//        numPrevCpuInfo = numCpuInfo;
//        
//        cpuInfo = NULL;
//        numCpuInfo = 0U;
//    } else {
//        NSLog(@"Error!");
//    }
//    return cpuArgs;
//}
//



- (void)updateInfo:(NSTimer *)timer
{
    NSLog(@"============================================");
//    NSInteger totalMe = [self totalMemory];
//    NSLog(@"total memorey : %d", totalMe);
//    
//    NSInteger freeMe = [self freeMemory];
//    NSLog(@"freeMe memorey : %d", freeMe);
//    
//    
//    CGFloat usedMemory = [self usedMemory];
//    NSLog(@"usedMemory memorey : %f", usedMemory);
//    
//    CGFloat activeMemory = [self activeMemory];
//    NSLog(@"activeMemory memorey : %f", activeMemory);
//    
//    CGFloat wiredMemory = [self wiredMemory];
//    NSLog(@"wiredMemory memorey : %f", wiredMemory);
//
//    CGFloat inactiveMemory = [self inactiveMemory];
//    NSLog(@"inactiveMemory memorey : %f", inactiveMemory);
//    
//    NSLog(@"ram usage : %f", [self appRamUsage]);
//    
//  
//    
//    NSArray *cpuArg = [self getCPU];
//
//    double temp00 = [[cpuArg objectAtIndex:0] doubleValue];
//    double temp01 = [[cpuArg objectAtIndex:1] doubleValue];
//
//    double temp10 = [[cpuArg objectAtIndex:2] doubleValue];
//    double temp11 = [[cpuArg objectAtIndex:3] doubleValue];
//
//    NSLog(@"Core 1 Percentage : %f, Usage : %f, TotalCore : %f", (temp00 / temp01), temp00, temp01);
//    NSLog(@"Core 0 Percentage : %f, Usage : %f, TotalCore : %f", (temp10 / temp11), temp10, temp11);
//    
//    NSLog(@"batteryLevel : %f", [self batteryLevel]);
    
    NSLog(@"============================================");
    
}
//
//- (double)appRamUsage
//{
//    struct task_basic_info info;
//    mach_msg_type_number_t size = sizeof(info);
//    kern_return_t kerr = task_info(mach_task_self(),
//                                   TASK_BASIC_INFO,
//                                   (task_info_t)&info,
//                                   &size);
//    if( kerr == KERN_SUCCESS ) {
//        return [self transformeToMB:info.resident_size];
//    } else {
//        return -1;
//    }
//}
//
//- (double)transformeToMB:(natural_t)value
//{
//    double convertedValue = value;
//    if (convertedValue > (1024 * 1024)) {
//        convertedValue /= (1024 * 1024);
//    }
//    return convertedValue;
//}
//
//
//
//- (CGFloat)batteryLevel {
//    
//    UIDevice *device = [UIDevice currentDevice];
//    [device setBatteryMonitoringEnabled:YES];
//    CGFloat batteryLevel = 0.0f;
//    CGFloat batteryCharge = device.batteryLevel;
//    if (batteryCharge > 0.0f)
//        batteryLevel = batteryCharge * 100;
//    else
//        // Unable to find battery level
//        return -1;
//    
//    return batteryLevel;
//}
//

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
