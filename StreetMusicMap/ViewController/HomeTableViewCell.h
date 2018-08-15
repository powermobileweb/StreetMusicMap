//
//  HomeTableViewCell.h
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/23/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"
#import "AsyncImageView.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


@protocol HomeTableViewCellDelegate;


@interface HomeTableViewCell : UITableViewCell {
    
    id <HomeTableViewCellDelegate> __unsafe_unretained delegate;
    
}
@property (unsafe_unretained) id <HomeTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblLikes;
@property (weak, nonatomic) IBOutlet UILabel *lblEpisode;
@property (weak, nonatomic) IBOutlet UILabel *lblComments;
@property (weak, nonatomic) IBOutlet AsyncImageView *imgPhoto;
@property (strong, nonatomic) InstagramMedia *media;


@end


@protocol HomeTableViewCellDelegate <NSObject>

@optional

- (void)homeTableViewCell:(HomeTableViewCell *)controller media:(InstagramMedia *)media;

@end
