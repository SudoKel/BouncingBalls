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
        // create current context
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // set the fill color
        CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
        
        // create CGRect to hold the ball
        CGRect frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
        
        // create our 2D ball
        CGContextAddEllipseInRect(context, frame);
        
        // fill it with color
        CGContextFillEllipseInRect(context, frame);
    }

    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
    {
        
    }

    - (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
    {
        // save the touch
        UITouch *touch = [touches anyObject];
        
        // get the location before move
        CGPoint prevLoc = [touch previousLocationInView:self];
        
        // get the location upon move
        CGPoint loc = [touch locationInView:self];
        
        // calculate the new location of the ball
        CGPoint nextLoc = CGPointMake(self.center.x + (loc.x - prevLoc.x), self.center.y + (loc.y - prevLoc.y));
        
        /* prevent ball from going out of bounds of parent view */
        // get x coord of midpoint of the ball
        float midPointX = CGRectGetMidX(self.bounds);
        
        // keep within bounds if moved too far right
        if (nextLoc.x > self.superview.bounds.size.width - midPointX)
            nextLoc.x = self.superview.bounds.size.width - midPointX;
        // or too far left
        else if (nextLoc.x < midPointX)
            nextLoc.x = midPointX;
        
        // get y coord of midpoint of the ball
        float midPointY = CGRectGetMidY(self.bounds);
        
        // keep within bounds if move too far down
        if (nextLoc.y > self.superview.bounds.size.height - midPointY)
            nextLoc.y = self.superview.bounds.size.height - midPointY;
        // or too far up
        else if (nextLoc.y < midPointY)
            nextLoc.y = midPointY;
        
        // move ball to its new location
        self.center = nextLoc;
    }

    - (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
    {
        
    }

    - (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
    {
        
}
@end
