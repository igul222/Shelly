//
//  ConsoleViewController.m
//  Console
//
//  Created by Ishaan Gulrajani on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ConsoleViewController.h"

#import "Server.h"
#import "VT100TextView.h"

// Servers popover
#import "ServersViewController.h"
#import "IGPopoverManager.h"

@interface ConsoleViewController ()
-(void)keyboardButtonPressed;
-(void)configureView;

-(void)connect;
-(void)connectionStatusDidChange:(NSString *)newConnectionStatus;

-(void)updateText;
-(void)updateTerminalSize;
@end

@implementation ConsoleViewController
@synthesize spinner, connectingLabel, inputTextView;
@synthesize server;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	server.delegate = nil;
	self.server = nil;
	
	self.spinner = nil;
	self.inputTextView = nil;
	
	[vt100 release];
	[super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

-(void)viewDidLoad {
	[super viewDidLoad];

	UIBarButtonItem *serversButton = [[UIBarButtonItem alloc] initWithTitle:@"Servers" 
																	  style:UIBarButtonItemStyleBordered 
																	 target:self 
																	 action:@selector(serversButtonPressed)];
	self.navigationItem.leftBarButtonItem = serversButton;
	[serversButton release];
	
	[self configureView];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	vt100 = [[VT100TextView alloc] init];
	
	[vt100 setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 200)];
	vt100.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[vt100 setFont:[UIFont fontWithName:@"Inconsolata" size:14.0]];
	[vt100 setAlpha:0.0f];
	[self.view addSubview:vt100];
}

#pragma mark -
#pragma mark Customizing the view

-(void)setServer:(Server *)newServer {
	if(server != newServer) {
		server.delegate = nil;
		[server startDisconnecting];
		[server release];
		server = [newServer retain];
		server.delegate = self;
	}
	[self configureView];
}

-(void)configureView {
	if(server) {
		self.navigationItem.title = server.title;
		[self connect];
	} else {
		self.navigationItem.title = nil;
	}
}

#pragma mark -
#pragma mark Managing the keyboard

-(void)keyboardButtonPressed {
	if([inputTextView isFirstResponder]) {
		[inputTextView resignFirstResponder];
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
	} else {
		[inputTextView becomeFirstResponder];
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
	}
}

#pragma mark -
#pragma mark Connecting and Disconnecting

-(void)connect {
	[connectingLabel setHidden:NO];
	[spinner startAnimating];
	
	[server startConnecting];
}

-(void)disconnect {
	[connectingLabel setHidden:NO];
	[spinner startAnimating];
	
	[server startDisconnecting];
}

-(void)connectionStatusDidChange:(NSString *)newConnectionStatus {
	[connectingLabel setText:newConnectionStatus];
	if([newConnectionStatus hasSuffix:@"failed."])
		[spinner stopAnimating];
	else if([newConnectionStatus isEqualToString:@"Connected!"]) {
		
		[spinner stopAnimating];
		
		// animations
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0f];
		[vt100 setAlpha:1.0f];
		[connectingLabel setAlpha:0.0f];
		[UIView commitAnimations];
		
		// keyboard button
		UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Keyboard" style:UIBarButtonItemStyleBordered target:self action:@selector(keyboardButtonPressed)];
		self.navigationItem.rightBarButtonItem = button;
		[button release];
		[self keyboardButtonPressed];
		
		// update timer
		[NSTimer scheduledTimerWithTimeInterval:0.1f
										 target:self 
									   selector:@selector(updateText) 
									   userInfo:nil 
										repeats:YES];
		
	} else if([newConnectionStatus isEqualToString:@"Disconnected."]) {
		[spinner stopAnimating];
	}
}

#pragma mark -
#pragma mark Communicating with the server

-(void)updateTerminalSize {
	[server updateTerminalHeight:[vt100 height] width:[vt100 width]];
}

-(void)updateText {
	NSData *readData = [self.server readFromStream];
	if(readData)
		[vt100 readInputStream:readData];
}

// capture keyboard input
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if([text isEqualToString:@""]) {
		// backspace
		char backspace_ascii[1];
		backspace_ascii[0] = 8;
		NSString *backspace = [NSString stringWithFormat:@"%s",backspace_ascii];
		[self.server writeToStream:backspace];
	} else {
		[self.server writeToStream:text];
	}
	return YES;
}

#pragma mark -
#pragma mark Servers popover

-(void)serversButtonPressed {
	ServersViewController *serversVC = [[ServersViewController alloc] initWithStyle:UITableViewStylePlain];
	serversVC.consoleViewController = self;
	UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:serversVC];
	UIPopoverController *serversPopoverController = [[UIPopoverController alloc] initWithContentViewController:navC];
	[serversVC release];
	[navC release];
	
	[IGPopoverManager registerPopoverController:serversPopoverController];
	[serversPopoverController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem 
									 permittedArrowDirections:UIPopoverArrowDirectionAny 
													 animated:YES];
}

#pragma mark -
#pragma mark Rotation

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[[IGPopoverManager currentPopoverController] dismissPopoverAnimated:NO];
}

@end
