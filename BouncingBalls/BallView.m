//
//  BallView.m
//  BouncingBalls
//
//  This class is used to create a ball object,
//  that can be flicked and moved within the arena.
//
//  Created by Kelwin Joanes on 2017-02-18.
//  Copyright © 2017 com.kelel. All rights reserved.
//

#import "BallView.h"

@implementation BallView
- (void)drawRect:(CGRect)rect
{
    // Create current context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Generate a random color - credit to Kyle Fox
    CGFloat h = (arc4random() % 256 / 256.0); // 0.0 to 1.0
    CGFloat s = (arc4random() % 128 / 256.0) + 0.5; // 0.5 to 1.0, away from white
    CGFloat b = (arc4random() % 128 / 256.0) + 0.5; // 0.5 to 1.0, away from black
    
    // Set a random fill color
    CGContextSetFillColorWithColor(context, [UIColor colorWithHue:h saturation:s brightness:b alpha:1].CGColor);
    
    // Create CGRect to hold the ball
    CGRect frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
    
    // Create our 2D ball
    CGContextAddEllipseInRect(context, frame);
    
    // Fill it with color
    CGContextFillEllipseInRect(context, frame);
    
    // Set the radius and origin point of the ball
    self.radius = self.frame.size.height/2.0;
    self.originPoint = self.center;
    
    // The ball is at rest initially
    self.speed = 0;
    self.stationary = YES;
    
    // Set the slope and y-intercept of path to reflect ball at rest
    self.slope = 0;
    self.yIntercept = 0;
    
    // Handle double tap event
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeBall:)];
    tapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tapGesture];
}

/**
 This method removes a ball from the arena
 */
- (void)removeBall:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        [self removeFromSuperview];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    // Stop the ball
    self.speed = 0;
    self.stationary = YES;
    self.originPoint = self.center;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    // Save the touch
    UITouch *touch = [touches anyObject];
    
    // Get the location before move
    CGPoint prevLoc = [touch previousLocationInView:self];
    
    // Get the location upon move
    CGPoint loc = [touch locationInView:self];
    
    // Calculate the new location of the ball
    CGPoint nextLoc = CGPointMake(self.center.x + (loc.x - prevLoc.x), self.center.y + (loc.y - prevLoc.y));
    
    /* Prevent ball from going out of bounds of parent view */
    // Get x coord of midpoint of the ball
    float midPointX = CGRectGetMidX(self.bounds);
    
    // Keep within bounds if moved too far right
    if (nextLoc.x > self.superview.bounds.size.width - midPointX)
        nextLoc.x = self.superview.bounds.size.width - midPointX;
    // Or too far left
    else if (nextLoc.x < midPointX)
        nextLoc.x = midPointX;
    
    // Get y coord of midpoint of the ball
    float midPointY = CGRectGetMidY(self.bounds);
    
    // Keep within bounds if move too far down
    if (nextLoc.y > self.superview.bounds.size.height - midPointY)
        nextLoc.y = self.superview.bounds.size.height - midPointY;
    // Or too far up
    else if (nextLoc.y < midPointY)
        nextLoc.y = midPointY;
    
    // Move ball to its new location
    self.center = nextLoc;
    
    // Ball should move after flick
    self.stationary = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.stationary)
    {
        // Determine the slope of the path to take
        self.slope = (self.originPoint.y - self.center.y) / (self.originPoint.x - self.center.x);
        
        // Determine the y-intercept of the path to take
        self.yIntercept = self.center.y - (self.slope * self.center.x);
        
        // Set the initial speed of the ball
        self.speed = 1.0;
        
        // Determine if ball is moving left or right
        if (self.originPoint.x - self.center.x > 0)
        {
            // Ball moving left
            self.leftToRight = NO;
            self.stationary = NO;
        }
        else if (self.originPoint.x - self.center.x < 0)
        {
            // Ball moving right
            self.leftToRight = YES;
            self.stationary = NO;
        }
    }
}
@end
