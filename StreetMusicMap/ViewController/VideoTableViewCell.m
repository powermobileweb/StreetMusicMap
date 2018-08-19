//
//  VideoTableViewCell.m
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/25/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import "VideoTableViewCell.h"
@import AVFoundation;
#import "Util.h"

@implementation VideoTableViewCell

- (void)awakeFromNib {
    
    self.viewVideoContent.hidden = YES;
     self.loader.hidden = YES;
    self.activityIndicator.hidden = YES;
    
    // Initialization code
    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playMediaFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failToPlay:) name:AVPlayerItemPlaybackStalledNotification object:_player];

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)playVideo:(id)sender {
    
    if (!_isPlaying && !_isVideoLoaded) {
        
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        self.activityIndicator.hidesWhenStopped = YES;
        
        self.loader.animationImages = [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"loader00"],
                                       [UIImage imageNamed:@"loader01"],
                                       [UIImage imageNamed:@"loader02"],
                                       [UIImage imageNamed:@"loader03"],
                                       [UIImage imageNamed:@"loader04"],
                                       [UIImage imageNamed:@"loader05"],
                                       [UIImage imageNamed:@"loader06"],
                                       [UIImage imageNamed:@"loader07"],
                                       [UIImage imageNamed:@"loader08"],
                                       [UIImage imageNamed:@"loader09"],
                                       [UIImage imageNamed:@"loader10"],
                                       [UIImage imageNamed:@"loader11"],
                                       [UIImage imageNamed:@"loader12"],
                                       [UIImage imageNamed:@"loader13"],
                                       [UIImage imageNamed:@"loader14"],
                                       [UIImage imageNamed:@"loader15"],
                                       [UIImage imageNamed:@"loader16"],
                                       [UIImage imageNamed:@"loader17"],
                                       [UIImage imageNamed:@"loader18"],
                                       [UIImage imageNamed:@"loader19"],
                                       [UIImage imageNamed:@"loader20"],
                                       [UIImage imageNamed:@"loader21"],
                                       [UIImage imageNamed:@"loader22"],
                                       [UIImage imageNamed:@"loader23.gif"], nil];
        self.loader.animationDuration = 1.0f;
        self.loader.animationRepeatCount = 0;
        self.loader.alpha = 0.6f;
        [self.loader startAnimating];
        
        self.loader.hidden = YES;
        
        
        //self.viewVideoContent.hidden = NO;
        [self.btnPlayArrow setImage:nil forState:UIControlStateNormal];
        
        
        
        _player = [AVPlayer playerWithURL:self.currentMedia.standardResolutionVideoURL];
        AVPlayerLayer *layer = [AVPlayerLayer layer];
        
        [layer setPlayer:_player];
        [layer setFrame:self.viewVideoContent.layer.frame];
        [layer setPosition: CGPointMake(layer.frame.size.width/2, layer.frame.size.width/2)];
        
        [layer setVideoGravity:AVLayerVideoGravityResize];
        
        [self.viewVideoContent.layer addSublayer:layer];
        
        [_player play];
        
        _isVideoLoaded = YES;
        _isPlaying = YES;
        
        [_player addObserver:self forKeyPath:@"status" options:0 context:nil];

        
        
    }
    else if (!_isPlaying) {
        [_player play];
        _isPlaying = YES;
        [self.btnPlayArrow setImage:nil forState:UIControlStateNormal];
    }
    else {
        [_player pause];
        [self.btnPlayArrow setImage:[UIImage imageNamed:@"playArrow"] forState:UIControlStateNormal];
        _isPlaying = NO;
        
        
    }
    
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == _player && [keyPath isEqualToString:@"status"]) {
        if (_player.status == AVPlayerStatusReadyToPlay) {
            self.viewVideoContent.hidden = NO;
            
            
            self.activityIndicator.hidden = YES;
            [self.activityIndicator stopAnimating];

            
            [_player removeObserver:self forKeyPath:@"status" context:nil];
        } else if (_player.status == AVPlayerStatusFailed) {
            
            self.activityIndicator.hidden = YES;
            [self.activityIndicator stopAnimating];
            [self performSelector:@selector(playVideo:) withObject:nil];
        }

    }
}


-(void)playMediaFinished:(NSNotification*)theNotification
{
    //  self.viewVideoContent.hidden = YES;
    [self.btnPlayArrow setImage:[UIImage imageNamed:@"rePlay"] forState:UIControlStateNormal];
    AVPlayerItem *p = [_player currentItem];
    [p seekToTime:kCMTimeZero];
    _isVideoLoaded = YES;
    _isPlaying = NO;
}

-(void)failToPlay:(NSNotification*)theNotification
{
    
    NSLog(@"failToPlay");

    [self performSelector:@selector(playVideo:) withObject:nil];
    
}





@end
