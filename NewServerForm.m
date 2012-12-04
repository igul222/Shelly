//
//  NewServerForm.m
//  Console
//
//  Created by Ishaan Gulrajani on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewServerForm.h"

#import "IGPopoverManager.h"

#import "NSString+IGExtensions.h"
#import "ConsoleAppDelegate.h"
#import <CoreData/CoreData.h>

@implementation NewServerForm

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView layoutIfNeeded];
	self.contentSizeForViewInPopover = CGSizeMake(320, self.tableView.contentSize.height);
	[[IGPopoverManager currentPopoverController] setPopoverContentSize:CGSizeMake(320, self.tableView.contentSize.height+35)];
}

-(void)configureForm {
	self.navigationItem.title = @"Add Server";
	
	[self addSection:nil];
	
	[self addTextField:@"Name" options:[NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithInt:UITextAutocapitalizationTypeWords],@"autocapitalizationType",nil]];
	
	[self addTextField:@"Address" options:[NSDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithInt:UITextAutocapitalizationTypeNone],@"autocapitalizationType",
										   [NSNumber numberWithInt:UITextAutocorrectionTypeNo],@"autocorrectionType",nil]];
}

-(NSString *)validateData:(NSDictionary *)formData {
	if([[formData objectForKey:@"Name"] isBlank])
		return @"Name can't be blank";
	
	if([[formData objectForKey:@"Address"] isBlank])
		return @"Address can't be blank";
	
	return nil;
}

-(void)saveData:(NSDictionary *)formData {
	ConsoleAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObject *server = [NSEntityDescription insertNewObjectForEntityForName:@"Server" inManagedObjectContext:delegate.managedObjectContext];
	
	[server setValue:[formData objectForKey:@"Name"] forKey:@"title"];
	[server setValue:[formData objectForKey:@"Address"] forKey:@"address"];
}

@end
