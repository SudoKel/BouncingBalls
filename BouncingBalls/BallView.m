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
        
        // Generate a random color
        CGFloat h = (arc4random() % 256 / 256.0); // 0.0 to 1.0
        CGFloat s = (arc4random() % 128 / 256.0) + 0.5; // 0.5 to 1.0
        CGFloat b = (arc4random() % 128 / 256.0) + 0.5; // 0.5 to 1.0
        
        // Set a random fill color
        CGContextSetFillColorWithColor(context, [UIColor colorWithHue:h saturation:s brightness:b alpha:1].CGColor);
        
        // Create CGRect to hold the ball
        CGRect frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
        
        // Create our 2D ball
        CGContextAddEllipseInRect(context, frame);
        
        // Fill it with color
        CGContextFillEllipseInRect(context, frame);
    }

    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
    {
        
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
        
    }

    - (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
    {
        
}
@end
