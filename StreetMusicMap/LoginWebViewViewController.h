//
//  LoginWebViewViewController.h
//  StreetMusicMap
//
//  Created by PowerMobile Team on 4/23/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"

@interface LoginWebViewViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeIndicator;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, assign) IKLoginScope scope;
@end
