//
//  BallView.h
//  BouncingBalls
//
//  Created by Kelwin Joanes on 2017-02-18.
//  Copyright © 2017 com.kelel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BallView : UIView
// Properties
@property CGPoint originPoint;
@property CGFloat velocity;
@property CGFloat slope;
@property CGFloat yIntercept;
@property (nonatomic, weak)NSTimer *repeatingTimer;
@end
