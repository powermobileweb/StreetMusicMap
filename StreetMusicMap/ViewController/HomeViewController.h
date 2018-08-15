//
//  HomeViewController.h
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/23/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"
#import "HomeTableViewCell.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface HomeViewController : UITableViewController <HomeTableViewCellDelegate>

@property (strong, nonatomic) InstagramPaginationInfo *currentPaginationInfo;
@property (strong, nonatomic) InstagramMedia *currentMedia;


@end
