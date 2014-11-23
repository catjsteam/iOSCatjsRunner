//
//  HPCViewController.m
//  CATRunner
//
//  Created by Nadav Vanunu on 1/27/14.
//  Copyright (c) 2014 Nadav Vanunu. All rights reserved.
//

#import "HPCViewController.h"
#import "AFNetworking.h"
#import "DeviceInfo.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if_dl.h>
#import <netinet/in.h>
#import <ifaddrs.h>
#import <sys/socket.h>
#import <objc/runtime.h>



NSString*baseUrl = @"";
NSTimer *updateTimer;

//DeviceInfo* deviceInfo = [DeviceInfo new];

@interface HPCViewController ()

@end

@implementation HPCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _webView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self displayWelcomeInWebView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigateToUrl:(NSURL *)url
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    baseUrl = [url absoluteString];
}


- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
    NSLog(@"Error : %@",error);

    // Ignore NSURLErrorDomain error -999.
    if (error.code == NSURLErrorCancelled) return;
    
    // Ignore "Fame Load Interrupted" errors. Seen after app store links.
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) return;
    
}

- (void)displayWelcomeInWebView
{
    NSMutableString *html = [NSMutableString stringWithString: @"<html><head><title>CAT</title></head><body style=\"background:transparent;\">"];
    
    //continue building the string
    [html appendString:@"<H1>Welcome to CAT Runner</H1>\n"];
    NSString *ip = [[self getIp]stringByAppendingString:@":54321\\cat"];
    [html appendString:@"<H2>Server is ON\n"];
    [html appendString:[NSString stringWithFormat:@"<H2>JSON POST path:\n %@</H2>\n",ip]];
    [html appendString:@"<H2>Post JSON with 'ip' & 'port' fields to navigate to the lacation</H2>\n"];
    [html appendString:@"</body></html>"];
    
    //make the background transparent
    [self.webView setBackgroundColor:[UIColor clearColor]];
    
    //pass the string to the webview
    [self.webView loadHTMLString:[html description] baseURL:nil];
    
    

    
}

- (void)mangerDeviceInfo:(NSString *)interval
{
    BOOL boolinterval = [interval boolValue];
    if (boolinterval) {
            updateTimer = [NSTimer scheduledTimerWithTimeInterval:4
                                                           target:self
                                                         selector:@selector(updateDeviceInfo:)
                                                         userInfo:nil
                                                          repeats:YES];
    } else {
        [self getDeviceInfo];
    }
}


- (void)updateDeviceInfo:(NSTimer *)timer {
    [self getDeviceInfo];
}

- (void)getDeviceInfo
{
    @autoreleasepool {
        
        // get
        DeviceInfo *deviceInfoObj  = [[DeviceInfo alloc] init];
        
        NSString *deviceInfoUrl = [NSString stringWithFormat:@"%@/deviceinfo", baseUrl];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        NSDictionary *params = [deviceInfoObj getFullData];
        
        NSLog(@"send device info data back to server");
        
        [manager POST:deviceInfoUrl parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSLog(@"JSON: %@", responseObject);
        }
              failure:
         ^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
        
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"WEBVIEW SHOULD START LOAD WITH REQUEST. %@", [self class]);
    
    BOOL shouldStartLoad = YES;
    
    NSURL *URL = [request URL];
    NSLog(@"try url: %@", URL);
    // The data is in the url, get it
    NSString *urlString = [[request URL] absoluteString];

    
    if ( [[URL scheme] isEqualToString:@"catjsgetscreenshot"]) {
        
        
        NSString *eventJSONStr = [self getParamsFromUrl:urlString forParams:@"scrapName="];
        
        NSLog(@"enter to screenshot");
        UIImage* theImage = [self getScreenshot];
        
        [self sendPostWithScreenshot:theImage forScrap:eventJSONStr];
        
        NSLog(@"send post");
       // [self sendPostRequest];
        shouldStartLoad = NO; // comes from our JS RnR lib so must not be loaded.
    } else if ([[URL scheme] isEqualToString:@"catjsdeviceinfo"]) {

        NSString *eventJSONStr = [self getParamsFromUrl:urlString forParams:@"interval="];
        
        [self mangerDeviceInfo:eventJSONStr];
    }
    return shouldStartLoad;
}


- (NSString *)getParamsFromUrl:(NSString *)urlString
                     forParams:(NSString *)forParam
{
 
    
    NSString *eventJSONStr = @"undefindName";
    
    NSArray *urlParts = [urlString componentsSeparatedByString:forParam];
    if ([urlParts count]==2) {
        eventJSONStr = urlParts[1];
        // unscape
        if (eventJSONStr) {
            eventJSONStr = [eventJSONStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    return eventJSONStr;
    
    
}

- (void)sendPostWithScreenshot:(UIImage*)thisImage
                              forScrap:(NSString*)scrapName{
    
    NSString *screenshotUrl = [NSString stringWithFormat:@"%@/screenshot", baseUrl];
    NSLog(@"send post request to: %@", screenshotUrl);

    
    UIDevice *deviceInfo = [UIDevice currentDevice];

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:screenshotUrl]];
    NSData *imageData = UIImagePNGRepresentation(thisImage);
    NSDictionary *parameters = @{@"scrapName": scrapName, @"deviceName" : deviceInfo.name};
    
    AFHTTPRequestOperation *op = [manager POST:screenshotUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        [formData appendPartWithFileData:imageData name:@"photo" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@ ***** %@", operation.responseString, error);
    }];
    [op start];
    
    return;
}


- (UIImage *)getScreenshot
{
    NSLog(@"try to take screenshot in new method");
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*theImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;
}



- (NSString *)getIp
{
    NSString * ipStr = @"error";
    
    int     result;
    struct ifaddrs  *ifbase, *ifiterator;
    
    result = getifaddrs(&ifbase);
    ifiterator = ifbase;
    while (!result && (ifiterator != NULL))
    {
        NSString* interface_name = [NSString stringWithFormat:@"%s", ifiterator->ifa_name];
        
        // when it has IPv4 info ...
        if ([interface_name isEqualToString:@"en0"] && ifiterator->ifa_addr->sa_family == AF_INET)
        {
            struct  sockaddr *saddr, *netmask, *daddr;
            saddr = ifiterator->ifa_addr;
            netmask = ifiterator->ifa_netmask;
            daddr = ifiterator->ifa_dstaddr;
            
            // we've found an entry for the IP address
            struct sockaddr_in      *iaddr;
            char                            addrstr[64];
            char                            netmaskstr[64];
            char                            broadstr[64];
            iaddr = (struct sockaddr_in *)saddr;
            inet_ntop(saddr->sa_family, &iaddr->sin_addr, addrstr, sizeof(addrstr));
            iaddr = (struct sockaddr_in *)netmask;
            inet_ntop(saddr->sa_family, &iaddr->sin_addr, netmaskstr, sizeof(addrstr));
            iaddr = (struct sockaddr_in *)daddr;
            inet_ntop(saddr->sa_family, &iaddr->sin_addr, broadstr, sizeof(addrstr));
            
            ipStr = [NSString stringWithFormat:@"%s", addrstr];
            break;
        }
        
        ifiterator = ifiterator->ifa_next;
    }
    
    // prevent a leak. Jon.
    if (ifbase) {
        freeifaddrs(ifbase);
    }
    return ipStr;
}


@end
