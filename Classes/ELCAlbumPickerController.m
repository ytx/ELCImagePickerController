//
//  AlbumPickerController.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "ELCAssetTablePicker.h"
#import "ELCAsset.h"

@implementation ELCAlbumPickerController

@synthesize parent, assetGroups, selectedAssets, selected, type, selectAll, count;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.navigationItem setTitle:@"Loading..."];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
	[self.navigationItem setRightBarButtonItem:cancelButton];
	[cancelButton release];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
	[self.navigationItem setLeftBarButtonItem:doneButton];
	[doneButton release];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;
    [tempArray release];
    
    if(self.selectedAssets == nil){
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        self.selectedAssets = tempDict;
        [tempDict release];
    }
    
    library = [[ALAssetsLibrary alloc] init];
    count = 0;

    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // Group enumerator Block
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
        {
            if (group == nil) 
            {
                return;
            }
            
            [self.assetGroups addObject:group];
            if(self.type == 0){
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            }else{
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
            }
            count += [group numberOfAssets];
            
            NSMutableDictionary *tempDict = [self.selectedAssets objectForKey:[group valueForProperty:ALAssetsGroupPropertyURL]];
            if(tempDict == nil){
                tempDict = [[[NSMutableDictionary alloc] init] autorelease];
                [self.selectedAssets setObject:tempDict forKey:[group valueForProperty:ALAssetsGroupPropertyURL]];
            }

            if(selectAll){
                for(ALAssetsGroup *group in self.assetGroups){
                    NSMutableDictionary *tempDict = [self.selectedAssets objectForKey:[group valueForProperty:ALAssetsGroupPropertyURL]];
                    if(tempDict.count == 0){
                        if(self.type == 0){
                            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                        }else{
                            [group setAssetsFilter:[ALAssetsFilter allVideos]];
                        }
                        [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
                         {
                             if(asset == nil)
                             {
                                 return;
                             }
                             NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
                             [workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
                             [workingDictionary setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
                             [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
                             //NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
                             NSURL *url = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]];
                             NSLog(@"selectAll:%@", url);
                             [tempDict setObject:workingDictionary forKey:url];
                             [workingDictionary release];
                         }];
                    }
                }
            }
            
            // Reload albums
            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
        };
        
        // Group Enumerator Failure Block
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            NSLog(@"A problem occured %@", [error description]);	                                 
        };	
                
        // Enumerate Albums
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:assetGroupEnumerator 
                             failureBlock:assetGroupEnumberatorFailure];
        
        [pool release];
        

        
    });
}

-(void)reloadTableView {
	
	[self.tableView reloadData];
	[self.navigationItem setTitle:@"Select an Album"];
}

-(void)selectedAssets:(NSMutableDictionary*)_assets {
    [self.selectedAssets setObject:_assets forKey:self.selected];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.tableView reloadData];
}

-(void)doneAction {
//    NSMutableArray *assets = [[NSMutableArray alloc] init];
//    for(NSMutableDictionary *ma in self.selectedAssets){
//        NSEnumerator *e = [ma keyEnumerator];
//        id key;
//        while (key = [e nextObject]) {
//            [assets addObjectsFromArray:[ma objectForKey:key]];
//        }
//    }
    [(ELCImagePickerController*)parent selectedAssets:[NSMutableDictionary dictionaryWithDictionary:self.selectedAssets] totalCount:self.count];
//    [assets release];
	//[(ELCImagePickerController*)parent selectedAssets:_assets];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [assetGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)[assetGroups objectAtIndex:indexPath.row];
    if(self.type == 0){
        [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    }else{
        [g setAssetsFilter:[ALAssetsFilter allVideos]];
    }
    NSInteger gCount = [g numberOfAssets];
    NSMutableArray *a = [self.selectedAssets objectForKey:[g valueForProperty:ALAssetsGroupPropertyURL]];
    NSInteger aCount = a.count;
//    if(aCount == 0 && selectAll){
//        aCount = gCount;
//    }
        
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d/%d)",[g valueForProperty:ALAssetsGroupPropertyName], aCount, gCount];
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[assetGroups objectAtIndex:indexPath.row] posterImage]]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName:@"ELCAssetTablePicker" bundle:[NSBundle mainBundle]];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"Back";
    self.navigationItem.backBarButtonItem = back;
    [back release];
	picker.parent = self;

    // Move me    
    picker.assetGroup = [assetGroups objectAtIndex:indexPath.row];
    self.selected = [picker.assetGroup valueForProperty:ALAssetsGroupPropertyURL];
    NSMutableDictionary *preselected = [self.selectedAssets objectForKey:self.selected];
    picker.preselected = preselected;
    if(self.type == 0){
        [picker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    }else{
        [picker.assetGroup setAssetsFilter:[ALAssetsFilter allVideos]];
    }
    
    //self.navigationItem.title = [picker.assetGroup valueForProperty:ALAssetsGroupPropertyName];
	[self.navigationController pushViewController:picker animated:YES];
	[picker release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 57;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc 
{	
    [assetGroups release];
    [library release];
    [super dealloc];
}

@end

