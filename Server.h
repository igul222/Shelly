//
//  Server.h
//  Shelly
//
//  Created by Ishaan Gulrajani on 4/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "libssh2.h"

@interface Server : NSManagedObject {
	LIBSSH2_SESSION *session;
	LIBSSH2_CHANNEL *channel;
	int sock;	
	
	id delegate;
}
@property(assign) id delegate;

-(void)startConnecting;
-(void)startDisconnecting;

-(NSData *)readFromStream;
-(void)writeToStream:(NSString *)text;

-(void)updateTerminalHeight:(int)height width:(int)width;

@end



@interface Server (CoreDataGeneratedAccessors)

@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *known_host_fingerprint;

@end