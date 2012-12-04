//
//  LoginAlert.m
//  Shelly
//
//  Created by Ishaan Gulrajani on 5/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginAlert.h"


@implementation LoginAlert

+(NSDictionary *)requestLoginCredentialsForAddress:(NSString *)address {
	return [NSDictionary dictionaryWithObjectsAndKeys:@"ishaan",@"username",@"k0nnichiwa",@"password",nil];
}

@end
