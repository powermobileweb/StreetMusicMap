//
//  ConfigViewController.m
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/26/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import "ConfigViewController.h"
#import "InstagramKit.h"
#import "Util.h"

@interface ConfigViewController () {
    
    
    
}

@end



@implementation ConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isLogged = [Util userIsLogged];
    _activetyIndicator.hidden = YES;
    
    [self setupView];
    
}

-(void) setupView {
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    
    if (_isLogged) {
        self.btnLogoff.enabled = YES;
        self.btnLogoff.title = @"Logoff";
        self.imgUser.hidden = NO;
        self.lblName.hidden = NO;
        self.btnLogin.hidden = YES;
        self.activetyIndicator.hidesWhenStopped = YES;

        
        NSString *fullName = [prefs stringForKey:@"fullName"];
        NSString *profilePictureURL = [prefs stringForKey:@"profilePictureURL"];
        
        if ([fullName isEqualToString:@""] || fullName == nil) {
            
            [self.activetyIndicator startAnimating];
            [[InstagramEngine sharedEngine] getSelfUserDetailsWithSuccess:^(InstagramUser *userDetail) {
                
                [_imgUser setImageWithURL:userDetail.profilePictureURL placeholderImage:[UIImage imageNamed:@"placeholder"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                _lblName.text = userDetail.fullName;
                
                
                 [prefs setObject:userDetail.fullName forKey:@"fullName"];
                 [prefs setObject:userDetail.profilePictureURL.absoluteString forKey:@"profilePictureURL"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                     [self.activetyIndicator stopAnimating];
                     [self setupView];
                });
                
               
                
            } failure:^(NSError *error) {
               
                 NSLog(@"Eror: %@", error);
                
            }];
        }
        else
        {
            [_imgUser setImageWithURL: [NSURL URLWithString: profilePictureURL] placeholderImage:[UIImage imageNamed:@"placeholder"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            _lblName.text = fullName;
        
        }
        
    }
    else {
        
        self.lblName.hidden = YES;
        self.imgUser.hidden = YES;
        self.btnLogoff.enabled = YES;
        self.btnLogoff.title = @"";
        self.btnLogin.hidden = NO;
    }
    
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    _isLogged = [Util userIsLogged];
    [self setupView];
    
}


- (IBAction)loginAction:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"segueToLogin" sender:nil];
    
}
- (IBAction)logoffAction:(id)sender {
    
    [[InstagramEngine sharedEngine] logout];
    [Util userIsLogged:NO];
    _isLogged = NO;
    
    [self setupView];
    
}





@end
