//
//  DeviceInfo.m
//  CATRunner
//
//  Created by Ran Snir on 11/13/14.
//  Copyright (c) 2014 Nadav Vanunu. All rights reserved.
//

#import "DeviceInfo.h"

#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>


@implementation DeviceInfo {
    
    processor_info_array_t cpuInfo, prevCpuInfo;
    mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
    unsigned numCPUs;
    NSTimer *updateTimer;
    NSLock *CPUUsageLock;
    
    
    
    

}

- (double)transformeToMB:(natural_t)value
{
    double convertedValue = value;
    if (convertedValue > (1024 * 1024)) {
        convertedValue /= (1024 * 1024);
    }
    return convertedValue;
}


- (CGFloat)freeMemory {
    double totalMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    totalMemory = [self transformeToMB:(vm_page_size * vmStats.free_count)];

    return totalMemory;
}

- (NSInteger)totalMemory {
    int nearest = 256;
    natural_t temp = [[NSProcessInfo processInfo] physicalMemory];
    int totalMemory = [self transformeToMB:temp];
    
    int rem = (int)totalMemory % nearest;
    int tot = 0;
    if (rem >= nearest/2) {
        tot = ((int)totalMemory - rem)+256;
    } else {
        tot = ((int)totalMemory - rem);
    }
    
    return tot;
}


- (CGFloat)usedMemory {
    double usedMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    usedMemory = [self transformeToMB:(vm_page_size * (vmStats.active_count + vmStats.inactive_count + vmStats.wire_count))];
    
    return usedMemory;
}

- (CGFloat)activeMemory {
    double activeMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    activeMemory = [self transformeToMB:(vm_page_size * vmStats.active_count)];
    
    return activeMemory;
}

- (CGFloat)wiredMemory {
    double wiredMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    wiredMemory = [self transformeToMB:(vm_page_size * vmStats.wire_count)];
    
    return wiredMemory;
}

- (CGFloat)inactiveMemory {
    double inactiveMemory = 0.00;
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return -1;
    }
    inactiveMemory = [self transformeToMB:(vm_page_size * vmStats.inactive_count)];
    
    return inactiveMemory;
}

- (NSArray *)getCPU
{
    int mib[2U] = { CTL_HW, HW_NCPU };
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
    if(status)
        numCPUs = 1;
    
    CPUUsageLock = [[NSLock alloc] init];
    
    
    NSMutableArray *cpuArgs = [[NSMutableArray alloc] initWithCapacity:0];
    
    natural_t numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    
    // get cpu usage
    if(err == KERN_SUCCESS) {
        [CPUUsageLock lock];
        
        for(unsigned i = 0U; i < numCPUs; ++i) {
            float inUse, total;
            if(prevCpuInfo) {
                inUse = (
                         (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                         );
                total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
             
            NSString *usageStr = [NSString stringWithFormat: @"%@", [NSNumber numberWithDouble:inUse]];
            NSString *totalStr = [NSString stringWithFormat: @"%@", [NSNumber numberWithDouble:total]];
            NSString *coreStr = [NSString stringWithFormat: @"%@", [NSNumber numberWithDouble:i]];
            
            NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                            coreStr, @"core",
                                            usageStr, @"usage",
                                            totalStr, @"total",
                                            nil];
            
            
            [cpuArgs addObject:jsonDictionary];
        }
        [CPUUsageLock unlock];
        
        if(prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        
        cpuInfo = NULL;
        numCpuInfo = 0U;
    } else {
        NSLog(@"Error!");
    }
    return cpuArgs;
}


- (double)appRamUsage
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        return [self transformeToMB:info.resident_size];
    } else {
        return -1;
    }
}


- (CGFloat)batteryLevel {
    
    UIDevice *device = [UIDevice currentDevice];
    [device setBatteryMonitoringEnabled:YES];
    CGFloat batteryLevel = 0.0f;
    CGFloat batteryCharge = device.batteryLevel;
    if (batteryCharge > 0.0f)
        batteryLevel = batteryCharge * 100;
    else
        // Unable to find battery level
        return -1;
    
    return batteryLevel;
}

-(NSDictionary *)getFullData
{
    
    NSInteger freeMemory = [self freeMemory];
    NSString *freeMemoryStr = [NSString stringWithFormat: @"%ld", (long)freeMemory];
    
    NSInteger totalMemory = [self totalMemory];
    NSString *totalMemoryStr = [NSString stringWithFormat: @"%ld", (long)totalMemory];
    
    CGFloat usedMemory = [self usedMemory];
    NSString *usedMemoryStr = [NSString stringWithFormat: @"%f", usedMemory];

    CGFloat activeMemory = [self activeMemory];
    NSString *activeMemoryStr = [NSString stringWithFormat: @"%f", activeMemory];
    
    CGFloat wiredMemory = [self wiredMemory];
    NSString *wiredMemoryStr = [NSString stringWithFormat: @"%f", wiredMemory];
    
    CGFloat inactiveMemory = [self inactiveMemory];
    NSString *inactiveMemoryStr = [NSString stringWithFormat: @"%f", inactiveMemory];
    
    CGFloat appRamUsage = [self appRamUsage];
    NSString *appRamUsageStr = [NSString stringWithFormat: @"%f", appRamUsage];
    
    CGFloat batteryLevel = [self batteryLevel];
    NSString *batteryLevelStr = [NSString stringWithFormat: @"%f", batteryLevel];

    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    NSString *timeStampObjStr = [NSString stringWithFormat: @"%@", timeStampObj];
    UIDevice *deviceInfo = [UIDevice currentDevice];
    NSArray *cpuArg = [self getCPU];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    timeStampObjStr, @"time",
                                    freeMemoryStr, @"freeMemory",
                                    totalMemoryStr, @"totalMemory",
                                    usedMemoryStr, @"usedMemory",
                                    activeMemoryStr, @"activeMemory",
                                    wiredMemoryStr, @"wiredMemory",
                                    inactiveMemoryStr, @"inactiveMemory",
                                    appRamUsageStr, @"appRamUsageStr",
                                    batteryLevelStr, @"batteryLevel",
                                    cpuArg, @"cpu",
                                    nil];
    
    return jsonDictionary;
}



@end
