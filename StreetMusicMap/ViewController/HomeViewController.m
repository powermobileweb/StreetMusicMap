//
//  HomeViewController.m
//  StreetMusicMap
//
//  Created by PowerMobile Team on 3/23/15.
//  Copyright (c) 2015 TrueTapp. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeTableViewCell.h"
#import "InstagramMedia.h"
#import "DetailTableViewController.h"
#import "Util.h"

@interface HomeViewController ()
{
    NSMutableArray *postArray;
    
    
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    

    
    
    self.navigationController.view.backgroundColor =
    [UIColor colorWithPatternImage: [UIImage imageNamed:@"Default"]];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tabBarItem.imageInsets = UIEdgeInsetsMake(-16, 0, 0, -10);
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor whiteColor]];
    
    
    [refreshControl addTarget:self action:@selector(loadDataRefresh:) forControlEvents:UIControlEventValueChanged];

    
    [self.tableView addSubview:refreshControl];
    
    if(self.tableView.contentOffset.y == 0){
        self.tableView.contentOffset = CGPointMake(0, - refreshControl.frame.size.height);
        [refreshControl beginRefreshing];
    }
    
    
    
    [self loadData:refreshControl];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoHeader"]];
    
    
}

-(void) viewDidAppear:(BOOL)animated {
    [self updateTableView:[[UIRefreshControl alloc] init]];

}

- (void)updateTableView:(UIRefreshControl *)refreshControl {
    if (refreshControl)
        [refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Custom Methods


- (void)loadData:(UIRefreshControl *)refreshControl {
    
    [self loadData:refreshControl refresh:NO];
}

- (void)loadDataRefresh:(UIRefreshControl *)refreshControl {
    
    [self loadData:refreshControl refresh:YES];
}




- (void)loadData:(UIRefreshControl *)refreshControl refresh:(BOOL)refreshValue {
    
    NSString *userID = @"1028760904";
    
    InstagramEngine *sharedEngine = [[InstagramEngine alloc] init];
    
    if (!postArray) {
        postArray = [[NSMutableArray alloc] init];
    }
    
    
    if (refreshValue) {
        
        [sharedEngine getMediaForUser:userID count:4 maxId:nil withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
            
            self.currentPaginationInfo = paginationInfo;
            postArray = [[NSMutableArray alloc] init];
            postArray = [media mutableCopy];
            
            [self performSelectorOnMainThread:@selector(updateTableView:) withObject:refreshControl waitUntilDone:NO];

            
        } failure:^(NSError *error) {
            
            
        }];
        
    } else {
        [sharedEngine getMediaForUser:userID
                                count:4
                                maxId:self.currentPaginationInfo.nextMaxId
                          withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo)
         {
             
             if (paginationInfo) {
                 self.currentPaginationInfo = paginationInfo;
             }
             for (InstagramMedia *item in media) {
                 
                 if (![postArray containsObject:item]) {
                     [postArray addObject:item];
                 }
                 
             }
             
             [self performSelectorOnMainThread:@selector(updateTableView:) withObject:refreshControl waitUntilDone:NO];
             
             //[self.tableView reloadData];
             
         } failure:^(NSError *error) {
             
             
         }];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return postArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellPost" forIndexPath:indexPath];
    
    if (postArray.count >= indexPath.row+1) {
        InstagramMedia *mediaOld = postArray[indexPath.row];
        
        
        
        cell.delegate = self;
        cell.tag = indexPath.section;
        
        cell.lblEpisode.text = [@"Ep. " stringByAppendingString:mediaOld.episode];
        cell.lblLocation.text = mediaOld.locationName;
        
        [cell.imgPhoto setImageWithURL:mediaOld.standardResolutionImageURL placeholderImage:[UIImage imageNamed:@"placeholder"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM yyyy"];
        cell.lblDate.text = [formatter stringFromDate:mediaOld.createdDate];
        
        cell.lblLikes.text = @(mediaOld.likesCount).stringValue;
        cell.lblComments.text = @(mediaOld.commentCount).stringValue;
        
        cell.media = mediaOld;
        
        
        
        
    }
    else
        [cell.imageView setImage:nil];
    return cell;
    return cell;
}






-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.currentPaginationInfo) {
        if ([indexPath isEqual:[NSIndexPath indexPathForRow:[self tableView:self.tableView numberOfRowsInSection:0]-2 inSection:0]]) {
            
            NSLog(@"reload");
            [self loadData:nil];
        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([segue.identifier isEqualToString:@"segueDetail"])
    {
        DetailTableViewController *detailViewController = segue.destinationViewController;
        detailViewController.currentMedia = _currentMedia;
        
    }
    
}

#pragma mark - Methods of HomeTableViewCell (Delegate)


- (void)homeTableViewCell:(HomeTableViewCell *)controller media:(InstagramMedia *)media {
    
    _currentMedia = media;
    [self performSegueWithIdentifier:@"segueDetail" sender:nil];
    
}


@end
