//
//  ServersViewController.h
//  Console
//
//  Created by Ishaan Gulrajani on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class ConsoleViewController;
@interface ServersViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	ConsoleViewController *consoleViewController;
	
	NSIndexPath *newRow;
}
@property(nonatomic,readonly) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic,assign) ConsoleViewController *consoleViewController;

@end
