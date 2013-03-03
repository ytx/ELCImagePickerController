//
//  AlbumPickerController.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ELCAlbumPickerController : UITableViewController {
	
	NSMutableArray *assetGroups;
	NSOperationQueue *queue;
	id parent;
    NSMutableDictionary *selectedAssets;
    id selected;
    int type; // 0:photo, 1:video
    BOOL selectAll;
    ALAssetsLibrary *library;
}

@property (nonatomic, assign) id parent;
@property (nonatomic, retain) NSMutableArray *assetGroups;
@property (nonatomic, retain) NSMutableDictionary *selectedAssets;
@property (nonatomic, assign) id selected;
@property (nonatomic) int type;
@property (nonatomic) BOOL selectAll;

-(void)selectedAssets:(NSMutableDictionary*)_assets;
-(void)doneAction;

@end

