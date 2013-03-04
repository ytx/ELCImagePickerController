//
//  ELCImagePickerController.h
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELCImagePickerController : UINavigationController {

	id delegate;
    int count;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic) int count;

-(void)selectedAssets:(NSMutableDictionary *)_assets totalCount:(int)_count;
-(void)cancelImagePicker;
-(int)totalCount;

@end

@protocol ELCImagePickerControllerDelegate

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker;

@optional
- (void)elcImagePickerController:(ELCImagePickerController *)picker setOrigInfo:(NSMutableDictionary *)info;

@end

