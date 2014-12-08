//
//  Screenshot.h
//  CATRunner
//
//  Created by Ran Snir on 12/8/14.
//  Copyright (c) 2014 Nadav Vanunu. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Screenshot : NSObject {
    
}

- (void)sendPostWithScreenshot:(UIImage*)thisImage
                      forScrap:(NSString*)scrapName
                   forDeviceId:(NSString*)deviceId
                  forServerUrl:(NSString*)baseUrl;

- (UIImage *)getScreenshot;

@end
