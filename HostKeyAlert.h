//
//  HostKeyAlert.h
//  Shelly
//
//  Created by Ishaan Gulrajani on 5/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HostKeyAlert : NSObject <UIAlertViewDelegate> {
	NSString *fingerprint;
	BOOL firstTime;
	
	BOOL alertDismissed;
	BOOL hostTrusted;
}
@property(nonatomic,readonly) BOOL alertDismissed;
@property(nonatomic,readonly) BOOL hostTrusted;

-(id)initWithFingerprint:(NSString *)fingerprint firstTime:(BOOL)firstTime;
+(BOOL)trustsHostWithFingerprint:(NSString *)fingerprint firstTime:(BOOL)firstTime;

@end
