//
//  ConsoleViewController.h
//  Console
//
//  Created by Ishaan Gulrajani on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Server, VT100TextView;
@interface ConsoleViewController : UIViewController <UITextViewDelegate> {
	UIActivityIndicatorView *spinner;
	UILabel *connectingLabel;
	UITextView *inputTextView;
	Server *server;
	
	VT100TextView *vt100;
}
@property(nonatomic,retain) IBOutlet UILabel *connectingLabel;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic,retain) IBOutlet UITextView *inputTextView;

@property(nonatomic,retain) Server *server;

-(void)serversButtonPressed;

@end
