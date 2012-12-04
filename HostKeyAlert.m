//
//  HostKeyAlert.m
//  Shelly
//
//  Created by Ishaan Gulrajani on 5/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HostKeyAlert.h"

@interface HostKeyAlert () 
-(void)displayAlert;
@end

@implementation HostKeyAlert
@synthesize alertDismissed, hostTrusted;

+(BOOL)trustsHostWithFingerprint:(NSString *)fingerprint firstTime:(BOOL)firstTime {
	HostKeyAlert *alert = [[HostKeyAlert alloc] initWithFingerprint:fingerprint firstTime:firstTime];
	
	while(!alert.alertDismissed)
		[NSThread sleepForTimeInterval:0.25];
	
	BOOL trusts = alert.hostTrusted;
	[alert release];
	return trusts;
}

-(void)dealloc {
	[fingerprint release];
	[super dealloc];
}

-(id)initWithFingerprint:(NSString *)theFingerprint firstTime:(BOOL)theFirstTime {
	if(self = [super init]) {
		fingerprint = [theFingerprint retain];
		firstTime = firstTime;
		[self performSelectorOnMainThread:@selector(displayAlert) withObject:nil waitUntilDone:YES];
	}
	return self;
}

-(void)displayAlert {
	NSString *title;
	NSString *message;
	if(firstTime) {
		title = @"Unknown Host Key";
		message = [NSString stringWithFormat:@"The fingerprint for the server's RSA key is: %@. If you trust this host, press \"Trust\" to continue. Otherwise, press \"Don't Trust\".",fingerprint];
	} else {
		title = @"Invalid Host Key!";
		message = [NSString	stringWithFormat:@"The server's host key has changed since the last connection! The connection's security may have been compromised. The fingerprint for the server's RSA key is: %@. If you have recently changed your server's SSH configuration, this is probably just a harmless warning. To continue connecting, press \"Trust\".",fingerprint];
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:message 
												   delegate:self 
										  cancelButtonTitle:@"Don't Trust" 
										  otherButtonTitles:@"Trust",nil];
	[alert show];
	[alert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex==0) // don't trust
		hostTrusted = NO;
	else // trust
		hostTrusted = YES;
	
	alertDismissed = YES;
}

@end
