//
//  HPCViewController.h
//  CATRunner
//
//  Created by Nadav Vanunu on 1/27/14.
//  Copyright (c) 2014 Nadav Vanunu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPCViewController : UIViewController <UIWebViewDelegate>
{
    //IBOutlet UIWebView *webView;
}

@property (nonatomic,retain) IBOutlet UIWebView *webView;

- (void)navigateToUrl:(NSURL *)url;

@end
