//
//  IGFormController.m
//  IGFormViewController
//
//  Created by Ishaan Gulrajani on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IGFormController.h"

@interface IGFormController ()
-(void)saveButtonPressed;
@end

@implementation IGFormController

#pragma mark -
#pragma mark Init and dealloc

-(void)dealloc {
	[form release];
	[sectionTitles release];
	[dataTitles release];
	[dataContainers release];
	[super dealloc];
}

-(id)init {
	if(self = [super initWithStyle:UITableViewStyleGrouped]) {
		form = [[NSMutableArray alloc] init];
		sectionTitles = [[NSMutableArray alloc] init];
		dataTitles = [[NSMutableArray alloc] init];
		dataContainers = [[NSMutableArray alloc] init];
		
		UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
		self.navigationItem.rightBarButtonItem = save;
		[save release];
		
		[self configureForm];
	}
	return self;
}


#pragma mark -
#pragma mark Override these methods

-(void)configureForm {
}

-(NSString *)validateData:(NSDictionary *)formData {
	return nil;
}

-(void)saveData:(NSDictionary *)formData {
}


#pragma mark -
#pragma mark Form configuration support

-(void)addSection:(NSString *)title {
	NSMutableArray *section = [[NSMutableArray alloc] init];
	[form addObject:section];
	[section release];
	
	// if title is nil, add a blank string
	[sectionTitles addObject:(title ? [[title copy] autorelease] : @"")];
}

-(void)addTextField:(NSString *)title options:(NSDictionary *)options {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(12, 0, 286, 44)];
	textField.tag = 0xDEADBEEF;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.placeholder = title;
	
	if([options objectForKey:@"autocorrectionType"])
		textField.autocorrectionType = [[options objectForKey:@"autocorrectionType"] intValue];
	
	if([options objectForKey:@"autocapitalizationType"])
		textField.autocapitalizationType = [[options objectForKey:@"autocapitalizationType"] intValue];
	
	
	[dataTitles addObject:[[title copy] autorelease]]; 
	[dataContainers addObject:textField];
	
	[cell.contentView addSubview:textField];
	[textField release];
	
	NSMutableArray *section = [form lastObject];
	[section addObject:cell];
	[cell release];
}

#pragma mark -
#pragma mark Validation and saving

-(void)saveButtonPressed {
	// make a dictionary...
	int count = [dataContainers count];
	NSMutableDictionary *formData = [[NSMutableDictionary alloc] initWithCapacity:count];
	for(int i=0;i<count;i++) {
		NSString *data = [(UITextField *)[dataContainers objectAtIndex:i] text];
		[formData setObject:(data ? data : @"")  
					 forKey:[dataTitles objectAtIndex:i]];
	}
	
	// validate it...
	NSString *error = [self validateData:formData];
	if(error) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:error 
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		// save the data!
		[self saveData:formData];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [form count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[form objectAtIndex:section] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [sectionTitles objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[form objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

#pragma mark -
#pragma mark Miscellaneous

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end

