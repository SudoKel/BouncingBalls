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
@property CGFloat radius;
@property CGPoint originPoint;
@property BOOL leftToRight;
@property BOOL stationary;
@property CGFloat momentum;
@property CGFloat slope;
@property CGFloat yIntercept;

// Public methods
- (void)moveBall:(void *)nothing;
@end
