//
//  DetailViewController.m
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/25/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import "DetailViewController.h"
#import "VideoTableViewCell.h"
#import "CommentsTableViewCell.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>
@import AVFoundation;

@interface DetailViewController () {


    CGFloat _initialConstant;
    NSString *linkToInstagram;
}

@end

@implementation DetailViewController

    static CGFloat keyboardHeightOffset = -50;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSRange rangeID = [_currentMedia.Id rangeOfString:@"_"];
    NSString *idParcial = [_currentMedia.Id substringWithRange:NSMakeRange(0, rangeID.location)];
    linkToInstagram = [@"instagram://media?id=" stringByAppendingString:idParcial];
    
    
    _isLogged = [Util userIsLogged];
    
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoHeader"]];
 
    self.navigationController.view.backgroundColor =
    [UIColor colorWithPatternImage: [UIImage imageNamed:@"Default"]];
    self.TableViewDetail.backgroundColor = [UIColor clearColor];
    
    self.TableViewDetail.estimatedRowHeight = 50;
    self.TableViewDetail.rowHeight = UITableViewAutomaticDimension;
    self.TableViewDetail.separatorInset = UIEdgeInsetsMake(0, 56, 0, 3);
    self.TableViewDetail.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoHeader"]];
    
    self.btnLike.layer.cornerRadius = 5;
    self.btnSendComment.layer.cornerRadius = 5;
    
    if (_isLogged) {
        self.viewComments.hidden = NO;
        self.bottonConstraint.constant = 0;
    } else {
        self.viewComments.hidden = YES;
        self.bottonConstraint.constant = -40;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void) viewDidAppear:(BOOL)animated {
    _isLogged = [Util userIsLogged];

    if (_isLogged) {
        self.viewComments.hidden = NO;
        self.bottonConstraint.constant = 0;
    } else {
        self.viewComments.hidden = YES;
        self.bottonConstraint.constant = -40;
    }
    
    
}


- (void) keyboardWillBeHidden:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.TableViewDetail.contentInset.top, 0.0, 0.0, 0);
    
    [UIView animateWithDuration:0.25f animations:^{
        self.TableViewDetail.contentInset = contentInsets;
        self.TableViewDetail.scrollIndicatorInsets = contentInsets;
    }];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    
    // Getting the keyboard frame and animation duration.
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    NSTimeInterval keyboardAnimationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if (!_initialConstant) {
        _initialConstant =  _constraintBottom.constant;
    }
    
    // If screen can fit everything, leave the constant untouched.
    _constraintBottom.constant = MAX(keyboardFrame.size.height + keyboardHeightOffset, _initialConstant);
    [UIView animateWithDuration:keyboardAnimationDuration animations:^{
        // This method will automatically animate all views to satisfy new constants.
        [self.view layoutIfNeeded];
    }];
    
}
- (IBAction)linkToInstagram:(id)sender {
    
   // linkToInstagram
    
    NSString *customURL = linkToInstagram;
    

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:customURL]];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    if(self.TableViewDetail.contentOffset.y<=0){
    
        _constraintBottom.constant = _initialConstant;
        [self.view  endEditing:YES];
        
        return;
    }
    
}
- (IBAction)addLikeAction:(UIButton *)sender {
    
     [[InstagramEngine sharedEngine] likeMedia:_currentMedia.Id withSuccess:^{
        
         NSLog(@"Success like");
         
     } failure:^(NSError *error) {
         
         NSLog(@"Error like: %@", error);

     }];
}

- (IBAction)sendCommentAction:(UIButton *)sender {
    
    
    [[InstagramEngine sharedEngine] createComment:self.txtComment.text onMedia:_currentMedia.Id withSuccess:^{
        
         NSLog(@"Success comment");
        
        
        
    } failure:^(NSError *error) {
        
        NSLog(@"Error comment: %@", error);
        
    }];
    
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
