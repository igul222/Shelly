//
//  LoginAlert.h
//  Shelly
//
//  Created by Ishaan Gulrajani on 5/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoginAlert : NSObject {

}

+(NSDictionary *)requestLoginCredentialsForAddress:(NSString *)address;

@end
