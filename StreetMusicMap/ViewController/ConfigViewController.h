//
//  ConfigViewController.h
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/26/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"
#import "AsyncImageView.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface ConfigViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnLogoff;
@property (nonatomic) BOOL isLogged;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activetyIndicator;

-(void) setupView;

@end
