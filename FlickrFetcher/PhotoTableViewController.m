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

- (IBAction)refresh:(id)sender
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr photo downloader", NULL);
    dispatch_async(downloadQueue , ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:50];
//        NSLog(@"%@", photos);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
            self.photos = photos;
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
        
        id sender = self.navigationItem.rightBarButtonItem;
        [self refresh:sender];
    }
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
    UINavigationController *NVC = [self.splitViewController.viewControllers lastObject];
    PhotoDisplayViewController *detailVC = NVC.topViewController;
    detailVC.photo = photo;
    [detailVC refresh];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Photo Display Segue"])
    {
        PhotoDisplayViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
        vc.photo = photo;
    }
}

@end
