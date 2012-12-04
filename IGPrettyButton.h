//
//  IGPrettyButton.h
//  IGPrettyButton
//
//  Created by Ishaan Gulrajani on 3/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IGPrettyButton : UIButton {
	BOOL roundedCorners;
}
@property(nonatomic) BOOL roundedCorners;

-(void)enableHighlight;
-(void)disableHighlight;

@end
