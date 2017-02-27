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
@property CGFloat radius;           // Radius of ball
@property CGPoint originPoint;      // Point in arena where ball was created
@property CGFloat speed;            // Speed of ball
@property CGFloat slope;            // The slope of the path the ball takes
@property CGFloat yIntercept;       // The y-intercept of the path the ball takes
@property BOOL leftToRight;         // The direcition the ball is going, either L or R
@property BOOL stationary;          // Indicates whether ball is stationary
@end
