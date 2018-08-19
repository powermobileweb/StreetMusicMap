//
//  LoginWebViewViewController.m
//  StreetMusicMap
//
//  Created by PowerMobile Team on 4/23/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import "LoginWebViewViewController.h"
#import "Util.h"
#import "ConfigViewController.h"

@interface LoginWebViewViewController ()

@end

@implementation LoginWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoHeader"]];
    
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
    self.webView.delegate = self;
    
    self.scope = IKLoginScopeRelationships | IKLoginScopeComments | IKLoginScopeLikes;
    
    NSDictionary *configuration = [InstagramEngine sharedEngineConfiguration];
    NSString *scopeString = [InstagramEngine stringForScope:self.scope];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey], scopeString]];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *URLString = [request.URL absoluteString];
    if ([URLString hasPrefix:@"streetmusicmap:"]) {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
        if (components.count > 1) {
            NSString *accessToken = [components lastObject];
            NSLog(@"ACCESS TOKEN = %@",accessToken);
            [[InstagramEngine sharedEngine] setAccessToken:accessToken];
            
            
            
                        [self dismissViewControllerAnimated:YES completion:^{
                            

                        }];
            
            ConfigViewController * configView = (ConfigViewController*)self.parentViewController;
            configView.isLogged = YES;
            [Util userIsLogged:YES];
            [configView setupView];
            
        }
        return NO;
    }
    return YES;
}
- (IBAction)cancelAction:(id)sender {
    [[InstagramEngine sharedEngine] cancelLogin];
    
    [self dismissViewControllerAnimated:YES completion:^{
        //                [self.collectionViewController reloadMedia];
    }];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self.activeIndicator startAnimating];
    self.activeIndicator.hidesWhenStopped = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activeIndicator stopAnimating];
    
}



@end
