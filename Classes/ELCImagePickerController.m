//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "ELCAlbumPickerController.h"

@implementation ELCImagePickerController

@synthesize delegate;

-(void)cancelImagePicker {
	if([delegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[delegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

-(void)selectedAssets:(NSMutableDictionary*)_assets {

	NSMutableArray *returnArray = [[[NSMutableArray alloc] init] autorelease];
    NSMutableDictionary *returnDict = [[[NSMutableDictionary alloc] init] autorelease];
    NSEnumerator *e = [_assets keyEnumerator];
    NSMutableDictionary *d, *dict;
    id key;
    while(key = [e nextObject]){
        d = [_assets objectForKey:key];
        NSEnumerator *e2 = [d keyEnumerator];
        dict = [[[NSMutableDictionary alloc] init] autorelease];
        id key2;
        while(key2 = [e2 nextObject]){
            id o = [d objectForKey:key2];
            if([o isKindOfClass:[ALAsset class]]){
                ALAsset *asset = o;
                NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
                [workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
                [workingDictionary setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
                [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
                [returnArray addObject:workingDictionary];
                [dict setObject:workingDictionary forKey:key2];
                [workingDictionary release];
            }else{ // NSMutableDictionary
                [returnArray addObject:o];
                [dict setObject:o forKey:key2];
            }
        }
        NSLog(@"%@ : %@", key, dict);
        [returnDict setObject:dict forKey:key];
    }
	
    [self popToRootViewControllerAnimated:NO];
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
    
    if([delegate respondsToSelector:@selector(elcImagePickerController:setOrigInfo:)]) {
        [delegate performSelector:@selector(elcImagePickerController:setOrigInfo:) withObject:self withObject:[NSMutableDictionary dictionaryWithDictionary:returnDict]];
    }
    
	if([delegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[delegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:[NSArray arrayWithArray:returnArray]];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {    
    NSLog(@"ELC Image Picker received memory warning.");
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    NSLog(@"deallocing ELCImagePickerController");
    [super dealloc];
}

@end
