//
//  IGPopoverManager.h
//  FormViewController
//
//  Created by Ishaan Gulrajani on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IGPopoverManager : NSObject {
	UIPopoverController *currentPopoverController;
}
@property(nonatomic,readonly) UIPopoverController *currentPopoverController;

+(IGPopoverManager *)manager;

-(BOOL)inPopover:(UIViewController *)viewC;
-(void)registerPopoverController:(UIPopoverController *)popoverController;


// syntax sugar
+(void)registerPopoverController:(UIPopoverController *)popoverController;
+(BOOL)inPopover:(UIViewController *)viewC;
+(UIPopoverController *)currentPopoverController;

@end
