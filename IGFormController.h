//
//  IGFormController.h
//  IGFormViewController
//
//  Created by Ishaan Gulrajani on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IGFormController : UITableViewController {
	NSMutableArray *form;
	NSMutableArray *sectionTitles;
	NSMutableArray *dataTitles;
	NSMutableArray *dataContainers;
}

// your IGFormController subclass should override these methods:
-(void)configureForm; // use the methods below to set up your form
-(NSString *)validateData:(NSDictionary *)formData; // if formData is valid, return nil. Otherwise return an error message.
-(void)saveData:(NSDictionary *)formData; // save the contents of formData, which you can assume to be valid.

// use these methods in configureForm
-(void)addSection:(NSString *)title;
-(void)addTextField:(NSString *)title options:(NSDictionary *)options;

@end
