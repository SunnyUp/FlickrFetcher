//
//  PhotoTableViewController.m
//  FlickrFetcher
//
//  Created by SunnyUp on 13-3-10.
//  Copyright (c) 2013年 SunnyUp. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoDisplayViewController.h"

@interface PhotoTableViewController ()

@end

@implementation PhotoTableViewController

@synthesize photos = _photos;
@synthesize place = _place;

- (void)refresh
{
    [self.refreshControl beginRefreshing];
    NSLog(@"%@", self.refreshControl);
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr photo downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:50];
//        NSLog(@"%@", photos);
        NSArray *vPhotos = [photos sortedArrayUsingComparator:^(id obj1, id obj2){
            NSString *str1 = [obj1 objectForKey:FLICKR_PHOTO_TITLE];
            NSString *str2 = [obj2 objectForKey:FLICKR_PHOTO_TITLE];
            if(str1 == nil || str1.length == 0)
                return NSOrderedDescending;
            else if(str2 == nil || str2.length == 0)
                return NSOrderedAscending;
            
            return [str1 compare:str2];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = vPhotos;
            [self.refreshControl endRefreshing];
        });
    });
//    dispatch_release(downloadQueue);
}

- (void)setPlace:(NSDictionary *)place
{
    if(_place != place)
    {
        _place = place;
//        if(self.tableView.window) [self.tableView reloadData];
        
        [self refresh];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)setPhotos:(NSArray *)photos
{
    if(_photos != photos)
    {
        _photos = photos;
        if(self.tableView.window) [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    NSString *title, *description, *auther;
    title = [photo objectForKey:FLICKR_PHOTO_TITLE];
    description = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
//    NSLog(@"%@", description);
    auther = [photo objectForKey:FLICKR_PHOTO_OWNER];
    if(title && title.length)
        cell.textLabel.text = title;
    else if(description && description.length)
        cell.textLabel.text = description;
    else
        cell.textLabel.text = @"Unknown";
    
    if(!title || !title.length || !description || !description.length)
        cell.detailTextLabel.text = auther;
    else
        cell.detailTextLabel.text = description;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)record:(NSDictionary *)photo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentPhotos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if (!recentPhotos)
        recentPhotos = [NSMutableArray array];
    else
    {
        for (id aPhoto in recentPhotos) {
            if ([[aPhoto objectForKey:FLICKR_PHOTO_ID] isEqualToString:[photo objectForKey:FLICKR_PHOTO_ID]])
                return;
        }
    }
    [recentPhotos addObject:photo];
    [defaults setObject:recentPhotos forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    PhotoDisplayViewController *detailVC = [self.splitViewController.viewControllers lastObject];
//    detailVC.imageURL = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
    detailVC.photo = photo;
    [self record:photo];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Photo Display Segue"])
    {
        PhotoDisplayViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
//        vc.imageURL = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge];
        vc.photo = photo;
        [self record:photo];
    }
}

@end
