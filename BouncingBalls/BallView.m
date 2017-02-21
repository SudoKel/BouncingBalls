//
//  BallView.m
//  BouncingBalls
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
    // Get the original center point of the ball upon initial
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
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    // Determine the slope of the path to take
    self.slope = (self.center.y - self.originPoint.y) / (self.center.x - self.originPoint.x);
    
    // Determine the y-intercept of the path to take
    self.yIntercept = self.center.y - (self.slope * self.center.x);
    
    // Set the initial velocity of the ball
    self.velocity = 50.0;
    
    // Set timer to refresh screen for updates on ball movement
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveBall:) userInfo:nil repeats:YES];
    
    // Store reference to timer
    self.repeatingTimer = timer;
}

- (void)moveBall:(void *)nothing
{
    CGFloat nextX = 0.0;
    
    // Determine if path is moving left or right and set the next x coord accordingly
    if (self.originPoint.x - self.center.x > 0)
        nextX = self.center.x - 2;
    else
        nextX = self.center.x + 2;
    
    // Determine the corresponding y coord using the slope and y-intercept of the path
    CGFloat nextY = (self.slope * nextX) + self.yIntercept;
    
    if (self.velocity > 0.0)
    {
        // Update the ball's center as long as it still has some velocity
        self.center = CGPointMake(nextX, nextY);
        
        // Reduce the ball's velocity by 1 so it eventually stops
        self.velocity -= 1.0;
    }
    else
    {
        // Otherwise stop the ball
        [self.repeatingTimer invalidate];
    }
}
@end
