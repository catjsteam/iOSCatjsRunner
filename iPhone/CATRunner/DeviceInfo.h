
#import <Foundation/Foundation.h>


@interface DeviceInfo : NSObject {
    
}

- (double)transformeToMB:(natural_t)value;
- (CGFloat)freeMemory;
- (NSInteger)totalMemory;
- (CGFloat)usedMemory;
- (CGFloat)activeMemory;
- (CGFloat)wiredMemory;
- (CGFloat)inactiveMemory;
- (NSArray *)getCPU;
- (double)appRamUsage;
- (CGFloat)batteryLevel;
- (NSDictionary *)getFullData;


@end
