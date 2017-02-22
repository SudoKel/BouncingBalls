//
//  ViewController.m
//  BouncingBalls
//
//  Created by Kelwin Joanes on 2017-02-18.
//  Copyright © 2017 com.kelel. All rights reserved.
//

#import "ViewController.h"
#import "BallView.h"
#import "Math.h"

@interface ViewController ()
// Properties
@property (nonatomic,strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, weak)NSTimer *repeatingTimer;
@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UIView *view in self.view.subviews)
        [view removeFromSuperview];

    // Handle long press event on root view or arena
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addNewBall:)];
    self.longPress.minimumPressDuration = 0.5f;
    self.longPress.allowableMovement = 50.0f;
    [self.view addGestureRecognizer:self.longPress];
    
    // Set timer to refresh screen for updates on ball movement
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkCollisions:) userInfo:nil repeats:YES];
    
    // Store a reference to the timer
    self.repeatingTimer = timer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** 
 This method adds new balls to the root view or arena 
 */
- (void)addNewBall:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // Get the location of the longpress
        CGPoint touchPoint = [sender locationInView:self.view];
        
        // Create a new ball at that location
        UIView *newBall = [[BallView alloc] initWithFrame:CGRectMake(touchPoint.x, touchPoint.y, 50, 50)];
        [newBall setBackgroundColor:[UIColor clearColor]];
        
        // Add the new ball to the arena
        [self.view addSubview:newBall];
    }
}

/**
 This method moves balls in the arena when flicked and
 also checks for and handles all collisions
 */
- (void)checkCollisions:(void *)nothing
{
    // Update movement of each ball within arena
    for (BallView *ball in self.view.subviews)
    {
        [ball moveBall:nil];
        
        for (BallView *otherBall in self.view.subviews)
        {
            // Check the current ball for collision with other balls in arena
            if (![otherBall isDescendantOfView:ball])
            {
                // Calculate distance between the two balls using Pythagoras' Theorem
                CGFloat distance = sqrtf((powf(ball.center.x - otherBall.center.x, 2)) + (powf(ball.center.y - otherBall.center.y, 2)));

                if (distance <=  ball.radius + otherBall.radius)
                {
                    // Balls have collided
                    NSLog(@"Balls have collided!");
                    
                    CGFloat newSlope = ball.slope;
                    CGPoint newOriginPoint = ball.originPoint;
                    CGFloat newEnergy = ball.energy;
                    
                    ball.slope = otherBall.slope;
                    ball.yIntercept = ball.center.y - (ball.slope * ball.center.x);
                    ball.originPoint = otherBall.originPoint;
                    ball.energy = otherBall.energy;
                    
                    otherBall.slope = newSlope;
                    otherBall.yIntercept = otherBall.center.y - (otherBall.slope * otherBall.center.x);
                    otherBall.originPoint = newOriginPoint;
                    otherBall.energy = newEnergy;
                }
            }
        }
    }
}
@end
