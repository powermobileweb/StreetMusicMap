//
//  HomeTableViewCell.m
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/23/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import "HomeTableViewCell.h"


@implementation HomeTableViewCell 

@synthesize delegate;


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
   // [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)goToDetail:(UIButton *)sender {
    
    
    if ([self.delegate respondsToSelector:@selector(homeTableViewCell:media:)]) {
        
        [self.delegate homeTableViewCell:self media:_media];
        
    }
       
}




@end


