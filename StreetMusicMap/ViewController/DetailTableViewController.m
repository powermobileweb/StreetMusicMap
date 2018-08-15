//
//  DetailTableViewController.m
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/25/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import "DetailTableViewController.h"
#import "VideoTableViewCell.h"
#import "CommentsTableViewCell.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>
@import AVFoundation;

@interface DetailTableViewController () 



@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"Default"]];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 56, 0, 3);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoHeader"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_currentMedia.comments count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == 0) {
        VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];
        
        
        [cell.imgPostImage setImageWithURL:_currentMedia.standardResolutionImageURL placeholderImage:[UIImage imageNamed:@"placeholder"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

        
        cell.lblLocation.text = _currentMedia.locationName;
        cell.lblDescription.text = _currentMedia.caption.text;
        cell.currentMedia = _currentMedia;
        
        // self.tableView.separatorInset = UIEdgeInsetsMake(0, 56, 0, 3);
        cell.separatorInset = UIEdgeInsetsMake(0, 500, 0, 500);
        
        
        return cell;
    }
    else {
        
         CommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentsCell" forIndexPath:indexPath];
        
        cell.backgroundColor = cell.contentView.backgroundColor;
        
        InstagramComment *comment = _currentMedia.comments[indexPath.row - 1];
        
        [cell.imgPerfilPhoto setImageWithURL:comment.user.profilePictureURL placeholderImage:[UIImage imageNamed:@"placeholder"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

        
        cell.lblName.text = [NSString stringWithFormat:@"%@ - @%@",comment.user.fullName, comment.user.username];
        cell.lblComment.text = comment.text;
        
        [Util circularProfile:cell.imgPerfilPhoto borderWith:0 ];
        
         return cell;

    }
    
    
}





/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
