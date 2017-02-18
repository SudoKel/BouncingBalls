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
        
        // get the new location of the touch
        CGPoint loc = [touch locationInView:self];
        
        // get the previous location of the touch
        CGPoint prevloc = [touch previousLocationInView:self];
        
        // store current frame of the view as a CGRect
        CGRect myFrame = self.frame;
        
        // calculate the change in x and y coordinates using previous and new location of touch
        float deltaX = loc.x - prevloc.x;
        float deltaY = loc.y - prevloc.y;
        
        // assign the coordinates to the CGRect
        myFrame.origin.x += deltaX;
        myFrame.origin.y += deltaY;
        
        // move the ball to the ball to its new location
        self.frame = myFrame;
    }

    - (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
    {
        
    }

    - (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
    {
        
}
@end
