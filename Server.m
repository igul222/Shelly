//
//  Server.m
//  Shelly
//
//  Created by Ishaan Gulrajani on 4/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Server.h"
#import <CFNetwork/CFNetwork.h>
#import "HostKeyAlert.h"
#import "LoginAlert.h"

#include "libssh2_config.h"
#include "libssh2.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <arpa/inet.h>

#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <ctype.h>

@interface Server ()

-(void)connect;
-(void)disconnect:(BOOL)updateStatus;
-(void)closeSessionAndSocket:(BOOL)updateStatus;
-(void)updateConnectionStatus:(NSString *)newStatus;

@end


@implementation Server
@synthesize delegate;

#pragma mark -
#pragma mark Memory management

-(void)dealloc {
	[self disconnect:NO];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Connecting

-(void)startConnecting {
	[self performSelectorInBackground:@selector(connect) withObject:nil];
}

-(void)connect {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@synchronized(self) {
	
		// get the IP address
		[self updateConnectionStatus:[NSString stringWithFormat:@"Looking up %@",self.address]];
		CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, (CFStringRef)self.address);
		

		CFStreamError error;
		CFHostStartInfoResolution(host, kCFHostAddresses, &error);
		

		Boolean hasBeenResolved = NO;
		CFArrayRef addresses = CFHostGetAddressing(host, &hasBeenResolved);
		if(!hasBeenResolved) {
			[self updateConnectionStatus:@"Lookup failed."];
			goto shutdown;
		}
		
		if(CFArrayGetCount(addresses)<1) {
			[self updateConnectionStatus:@"Lookup failed."];
			goto shutdown;
		}
		
		CFDataRef addressData = CFArrayGetValueAtIndex(addresses, 0);
		struct sockaddr host_sockaddr;
		CFIndex len = CFDataGetLength(addressData);
		CFDataGetBytes(addressData, CFRangeMake(0, len), (void *)&host_sockaddr);
		

		struct sockaddr *host_sockaddr_ptr = &host_sockaddr;
		struct sockaddr_in *ipv4 = (struct sockaddr_in *)host_sockaddr_ptr;
		struct in_addr host_in_addr = ipv4->sin_addr;
		const char *host_ip_string = inet_ntoa(host_in_addr);
		unsigned long hostaddr = inet_addr(host_ip_string);
		

		CFRelease(host);
		
		// connect to server
		[self updateConnectionStatus:@"Connecting to server..."];
		int rc = libssh2_init(0);
		if (rc != 0) {
			[self updateConnectionStatus:@"Connection failed."];
			goto shutdown;
		}
		

		// create the socket
		sock = socket(AF_INET, SOCK_STREAM, 0);
		struct sockaddr_in sin;
		sin.sin_family = AF_INET;
		sin.sin_port = htons(22);
		sin.sin_addr.s_addr = hostaddr;
		

		// connect the socket
		int connect_result = connect(sock, (struct sockaddr *)(&sin),sizeof(struct sockaddr_in)); 
		if (connect_result != 0) {
			[self updateConnectionStatus:@"Connection failed."];
			goto shutdown;
		}	

		
		// establish a session
		session = libssh2_session_init();
		if (libssh2_session_startup(session, sock)) {
			[self updateConnectionStatus:@"Connection failed."];
			goto shutdown;
		}	

		
		// verify remote host key
		const char *fingerprint_bytes = libssh2_hostkey_hash(session, LIBSSH2_HOSTKEY_HASH_SHA1);
		
		NSMutableString *fingerprint = [[NSMutableString alloc] init];
		for(int i=0;i<20;i++) {
			[fingerprint appendFormat:@"%02X",(unsigned char)fingerprint_bytes[i]];
			if(i<19)
				[fingerprint appendString:@":"];
		}	

		
		if(![fingerprint isEqual:self.known_host_fingerprint]) {
			BOOL trusted = [HostKeyAlert trustsHostWithFingerprint:fingerprint firstTime:!self.known_host_fingerprint];
			if(trusted) {
				self.known_host_fingerprint = fingerprint;
			} else {
				[self updateConnectionStatus:@"Connection failed."];
				goto shutdown;
			}
		}
		

		// authenticate
		[self updateConnectionStatus:@"Logging in..."];
		
		NSDictionary *credentials = [LoginAlert requestLoginCredentialsForAddress:self.address];
		if(!credentials) {
			NSLog(@"Credentials not found");
			[self updateConnectionStatus:@"Login failed."];
			goto shutdown;
		}
		
		const char *username_cstr = [[credentials objectForKey:@"username"] cStringUsingEncoding:NSUTF8StringEncoding];
		const char *password_cstr = [[credentials objectForKey:@"password"] cStringUsingEncoding:NSUTF8StringEncoding];
		
		
		char *userauthlist = libssh2_userauth_list(session, username_cstr, strlen(username_cstr));
		if(strstr(userauthlist, "password") == NULL) {
			// password auth not supported :(
			NSLog(@"Password auth unsupported: %s",userauthlist);
			[self updateConnectionStatus:@"Login failed."];
			goto shutdown;
		}
		
		if(libssh2_userauth_password(session,username_cstr,password_cstr)) {
			NSLog(@"Invalid: %s %s",username_cstr,password_cstr);
			[self updateConnectionStatus:@"Login failed."];
			[self closeSessionAndSocket:NO];
			goto shutdown;
		}
		
		// request a shell
		[self updateConnectionStatus:@"Configuring session..."];
		
		if(!(channel = libssh2_channel_open_session(session))) {
			[self updateConnectionStatus:@"Session configuration failed."];
			[self closeSessionAndSocket:NO];
			goto shutdown;
		}
			
		if (libssh2_channel_request_pty(channel, "vt102")) {
			[self updateConnectionStatus:@"Session configuration failed."];
			[self disconnect:NO];
			goto shutdown;
		}
		
		if (libssh2_channel_shell(channel)) {
			[self updateConnectionStatus:@"Session configuration failed."];
			[self disconnect:NO];
			goto shutdown;
		}
		
		[self updateConnectionStatus:@"Connected!"];
		
	}
	
shutdown:
	[pool release];
}


-(void)updateConnectionStatus:(NSString *)newStatus {
	[delegate performSelectorOnMainThread:@selector(connectionStatusDidChange:) withObject:newStatus waitUntilDone:YES];
}

#pragma mark -
#pragma mark Disconnecting

-(void)startDisconnecting {
	[self performSelectorInBackground:@selector(disconnect:) withObject:(id)YES];
}

-(void)disconnect:(BOOL)updateStatus {
	@synchronized(self) {
		if(updateStatus)
			[self updateConnectionStatus:@"Disconnecting..."];
				
		if (channel) {
			libssh2_channel_close(channel);
			libssh2_channel_free(channel);
			channel = NULL;
		}
		
		[self closeSessionAndSocket:updateStatus];
	}
}

-(void)closeSessionAndSocket:(BOOL)updateStatus {
	@synchronized(self) {
		if(session) {
			libssh2_session_disconnect(session, "Normal Shutdown, Thank you for playing");
			libssh2_session_free(session);
			session = NULL;
		}
		close(sock);	
		libssh2_exit();
		
		if(updateStatus)
			[self updateConnectionStatus:@"Disconnected."];
	}
}

#pragma mark -
#pragma mark Stream I/O

-(NSData *)readFromStream {
	@synchronized(self) {
		static int buffer_len = 100;

		libssh2_channel_set_blocking(channel, 0);

		NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
		int rc = 1;
		do {
			char buffer[buffer_len+1];
			rc = libssh2_channel_read(channel,buffer,sizeof(buffer)-sizeof(char));
			
			if(rc>0) {
				[data appendBytes:(const void *)buffer length:rc];
			} else if(rc<0 && rc!=LIBSSH2_ERROR_EAGAIN) {
				DLog(@"libssh2_channel_read returned error: %i",rc);
			}
			
		} while(rc>0);

		
		libssh2_channel_set_blocking(channel, 1);
		return ([data length]==0 ? nil : data);
	}
}

-(void)writeToStream:(NSString *)text {
	@synchronized(self) {
		libssh2_channel_set_blocking(channel, 0);
		
		const char *buf = [text cStringUsingEncoding:NSUTF8StringEncoding];
		
		libssh2_channel_write(channel, buf, strlen(buf));
		DLog(@"SENT: '%s' (starts with %i)",buf,*buf);
		
		libssh2_channel_set_blocking(channel, 1);
	}
}

#pragma mark -
#pragma mark Miscellaneous

-(void)updateTerminalHeight:(int)height width:(int)width {
	libssh2_channel_request_pty_size_ex(channel, width, height, 20, 20);
}

@end
