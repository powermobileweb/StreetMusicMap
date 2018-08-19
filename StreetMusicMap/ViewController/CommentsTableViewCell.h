//
//  CommentsTableViewCell.h
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/25/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


@interface CommentsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *imgPerfilPhoto;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblComment;


@end
