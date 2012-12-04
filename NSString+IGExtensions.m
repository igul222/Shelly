//
//  NSString+IGExtensions.m
//  Programming
//
//  Created by Ishaan Gulrajani on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+IGExtensions.h"


@implementation NSString (IGExtensions)

-(BOOL)isBlank {
	return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""];
}

@end
