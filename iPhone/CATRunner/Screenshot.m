//
//  Screenshot.m
//  CATRunner
//
//  Created by Ran Snir on 12/8/14.
//  Copyright (c) 2014 Nadav Vanunu. All rights reserved.
//

#import "Screenshot.h"
#import "AFNetworking.h"

@implementation Screenshot {
    
}


- (void)sendPostWithScreenshot:(UIImage*)thisImage
                      forScrap:(NSString*)scrapName
                   forDeviceId:(NSString*)deviceId
                    forServerUrl:(NSString*)baseUrl

{
    
    NSString *screenshotUrl = [NSString stringWithFormat:@"%@/screenshot", baseUrl];
    NSLog(@"send post request to: %@", screenshotUrl);
    
    
    UIDevice *deviceInfo = [UIDevice currentDevice];
    NSData *imageData = UIImagePNGRepresentation(thisImage);
    NSString *encodedString = [imageData base64Encoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"scrapName": scrapName,
                             @"deviceName" : deviceInfo.name,
                             @"deviceId" : deviceId,
                             @"deviceType" : @"iOS",
                             @"pic" : encodedString};
    [manager POST:screenshotUrl parameters:params
     
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
    
    return;
}



- (UIImage *)getScreenshot
{
//    NSLog(@"try to take screenshot in new method");
//    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
//    [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage*theImage=UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return theImage;
    return nil;
}

@end
