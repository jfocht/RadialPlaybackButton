//
//  MiniPlaybackButton.h
//  RadialPlayback
//
//  Created by Jordan Focht on 3/5/15.
//  Copyright (c) 2015 Jordan Focht. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MiniPlaybackButton : UIButton

@property (atomic) BOOL loading;
@property (atomic) CGFloat value;
@property (atomic) CGFloat minimumValue;
@property (atomic) CGFloat maximumValue;
@end
