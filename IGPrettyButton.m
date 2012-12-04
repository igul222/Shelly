//
//  IGPrettyButton.m
//  IGPrettyButton
//
//  Created by Ishaan Gulrajani on 3/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IGPrettyButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation IGPrettyButton
@synthesize roundedCorners;

-(void)awakeFromNib {
    	
	// configure the base
	CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
	[gradientLayer setBounds:[self bounds]];
	[gradientLayer setPosition:
	 CGPointMake([self bounds].size.width/2,
				 [self bounds].size.height/2)];
    [[self layer] insertSublayer:gradientLayer atIndex:0];
    [[self layer] setMasksToBounds:YES];
	[[self layer] setBorderWidth:1.0f];
	[gradientLayer release];
	
	self.roundedCorners = YES;
	
	// sets the color to the default state
	[self disableHighlight];
		
	// configure the text
	UIColor *normalTextColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	UIColor *normalTextShadow = [UIColor whiteColor];
	
	UIColor *highlightTextColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	UIColor *highlightTextShadow = [UIColor colorWithWhite:1.0 alpha:1.0];
	
	[self.titleLabel setShadowOffset:CGSizeMake(0, 1)];
	
	[self setTitleColor:normalTextColor forState:UIControlStateNormal];
	[self setTitleShadowColor:normalTextShadow forState:UIControlStateNormal];

	[self setTitleColor:highlightTextColor forState:UIControlStateHighlighted];
	[self setTitleShadowColor:highlightTextShadow forState:UIControlStateHighlighted];
	
	[self addTarget:self action:@selector(enableHighlight) forControlEvents:UIControlEventTouchDown];
	[self addTarget:self action:@selector(disableHighlight) forControlEvents:UIControlEventTouchUpInside];
	[self addTarget:self action:@selector(disableHighlight) forControlEvents:UIControlEventTouchDragExit];
}

#pragma mark -
#pragma mark Toggling base highlight

-(void)disableHighlight {
	UIColor *gradientTopColor = [UIColor whiteColor];
	UIColor *gradientBottomColor = [UIColor colorWithWhite:0.8 alpha:1.0];
	UIColor *borderColor = [UIColor colorWithWhite:0.6 alpha:1.0];	
	CAGradientLayer *gradientLayer = [[[self layer] sublayers] objectAtIndex:0];
	[gradientLayer setColors:[NSArray arrayWithObjects:
							  (id)[gradientTopColor CGColor], 
							  (id)[gradientBottomColor CGColor], 
							  nil]];	
	[[self layer] setBorderColor:[borderColor CGColor]];
	
	[gradientLayer removeAllAnimations];
	
	[self setNeedsDisplay];
}

-(void)enableHighlight {
	UIColor *gradientTopColor = [UIColor colorWithWhite:0.8 alpha:1.0];
	UIColor *gradientBottomColor = [UIColor colorWithWhite:0.9 alpha:1.0];
	UIColor *borderColor = [UIColor colorWithWhite:0.45 alpha:1.0];	
	
	CAGradientLayer *gradientLayer = [[[self layer] sublayers] objectAtIndex:0];
	[gradientLayer setColors:[NSArray arrayWithObjects:
							  (id)[gradientTopColor CGColor], 
							  (id)[gradientBottomColor CGColor], 
							  nil]];	
	[[self layer] setBorderColor:[borderColor CGColor]];
		
	[gradientLayer removeAllAnimations];
	
	[self setNeedsDisplay];	
}

#pragma mark -
#pragma mark Rounded corners

-(void)setRoundedCorners:(BOOL)aRoundedCorners {
	roundedCorners = aRoundedCorners;
	if(roundedCorners)
		[[self layer] setCornerRadius:6.0f];
	else
		[[self layer] setCornerRadius:0.0f];
	[self setNeedsDisplay];
}

@end
