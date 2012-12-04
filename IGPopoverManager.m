//
//  IGPopoverManager.m
//  FormViewController
//
//  Created by Ishaan Gulrajani on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IGPopoverManager.h"

static IGPopoverManager *sharedInstance = nil;

@implementation IGPopoverManager
@synthesize currentPopoverController;

#pragma mark -
#pragma mark Syntax sugar

+(void)registerPopoverController:(UIPopoverController *)popoverController {
	[[IGPopoverManager manager] registerPopoverController:popoverController];
}

+(BOOL)inPopover:(UIViewController *)viewC {
	return [[IGPopoverManager manager] inPopover:viewC];
}

+(UIPopoverController *)currentPopoverController {
	return [[IGPopoverManager manager] currentPopoverController];
}

#pragma mark -
#pragma mark The real functionality

-(void)registerPopoverController:(UIPopoverController *)popoverController {
	[currentPopoverController dismissPopoverAnimated:YES];
	
	if(popoverController != currentPopoverController) {
		[currentPopoverController release];
		currentPopoverController = [popoverController retain];
	}
}

-(BOOL)inPopover:(UIViewController *)viewC {
	return 
	(currentPopoverController && 
	 ((currentPopoverController.contentViewController == viewC) ||
	  (currentPopoverController.contentViewController == viewC.navigationController)));
}

#pragma mark -
#pragma mark Singleton methods

+ (IGPopoverManager *)manager {
    @synchronized(self) {
        if (sharedInstance == nil)
			sharedInstance = [[IGPopoverManager alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end