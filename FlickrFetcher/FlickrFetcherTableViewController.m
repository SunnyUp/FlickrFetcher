//
//  FlickrFetcherTableViewController.m
//  FlickrFetcher
//
//  Created by SunnyUp on 13-3-10.
//  Copyright (c) 2013年 SunnyUp. All rights reserved.
//

#import "FlickrFetcherTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoTableViewController.h"

@interface FlickrFetcherTableViewController ()

@end

@implementation FlickrFetcherTableViewController

@synthesize topPlaces = _topPlaces;

- (IBAction)refresh:(id)sender
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue , ^{
        NSArray *topPlaces = [FlickrFetcher topPlaces];
        //    NSLog(@"%@", photos);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
            self.topPlaces = topPlaces;
        });
    });
//    dispatch_release(downloadQueue);
}

- (void)setTopPlaces:(NSArray *)topPlaces
{
    if(_topPlaces != topPlaces)
    {
        _topPlaces = topPlaces;
        if(self.tableView.window) [self.tableView reloadData];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.topPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *place = [self.topPlaces objectAtIndex:indexPath.row];
    NSString *placeName = [place objectForKey:FLICKR_PLACE_NAME];
    NSString *cityName, *countryName;
    NSRange range = [placeName rangeOfString:@","];
    if(range.location != NSNotFound)
    {
        cityName = [placeName substringToIndex:range.location];
        countryName = [placeName substringFromIndex:range.location + 1];
    }
    if(!cityName || !cityName.length)
        cityName = @"Unknown";
    
    cell.textLabel.text = cityName;
    cell.detailTextLabel.text = countryName;
    
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"City Photo Segue"])
    {
        PhotoTableViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *place = [self.topPlaces objectAtIndex:indexPath.row];
        vc.place = place;
    }
}

@end
