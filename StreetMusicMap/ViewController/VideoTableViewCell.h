//
//  VideoTableViewCell.h
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/25/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@import AVFoundation;
#import "InstagramKit.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


@interface VideoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet AsyncImageView *imgPostImage;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayArrow;
@property (weak, nonatomic) IBOutlet UIView *viewVideoContent;
@property (weak, nonatomic) IBOutlet UIImageView *loader;

@property (weak, nonatomic) IBOutlet UILabel *lblLocation;

@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) InstagramMedia *currentMedia;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isVideoLoaded;

@property (weak, nonatomic) IBOutlet UILabel *lblLikesCount;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentsCount;
@property (weak, nonatomic) IBOutlet UILabel *lblEpisode;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;


@end
