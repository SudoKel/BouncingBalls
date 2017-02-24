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
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(checkCollisions:) userInfo:nil repeats:YES];
    
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

                if (distance <= ball.radius + otherBall.radius)
                {
                    // Balls have collided
                    NSLog(@"Balls have collided!");
                    NSLog(@"Center of ball: %@", NSStringFromCGPoint(ball.center));
                    NSLog(@"Origin of ball: %@", NSStringFromCGPoint(ball.originPoint));
                    NSLog(@"Center of other ball: %@", NSStringFromCGPoint(otherBall.center));
                    NSLog(@"Origin of other ball: %@", NSStringFromCGPoint(otherBall.originPoint));
                    
                    if (distance < ball.radius + otherBall.radius)
                    {
                        NSLog(@"Distance before: %f", distance);
                        NSLog(@"Difference before: %f", (ball.radius + otherBall.radius) - distance);
                        
                        CGFloat difference = (ball.radius + otherBall.radius) - distance;
                        CGFloat angle = atanf((ball.center.y - otherBall.center.y) / (ball.center.x - otherBall.center.x));
                        NSLog(@"Arctan of %f / %f: %f", ball.center.y - otherBall.center.y, ball.center.x - otherBall.center.x, angle);
                        CGFloat x = difference * cosf(angle);
                        CGFloat y = difference * sinf(angle);
                        NSLog(@"X and Y: (%f, %f)", x, y);
                        
                        ball.center = CGPointMake(ball.center.x + x, ball.center.y + y);
                        otherBall.center = CGPointMake(otherBall.center.x + x, otherBall.center.y + y);
                        
                        distance = sqrtf((powf(ball.center.x - otherBall.center.x, 2)) + (powf(ball.center.y - otherBall.center.y, 2)));
                        
                        NSLog(@"Difference after: %f", (ball.radius + otherBall.radius) - distance);
                    }
                    
                    
                    /* 
                     For the following calculations, we will deal with vectors by breaking them down
                     into their respective X and Y components
                     */
                    // Calculate the normal vector
                    CGFloat normalVectorX = otherBall.center.x - ball.center.x;
                    CGFloat normalVectorY = otherBall.center.y - ball.center.y;
                    
                    NSLog(@"Normal vector: (%f, %f)", normalVectorX, normalVectorY);
                    
                    // Calculate magnitude of the normal vector
                    CGFloat normalVectorMagnitude = sqrtf(powf(normalVectorX, 2) + powf(normalVectorY, 2));
                    
                    NSLog(@"Normal vector magnitude: %f", normalVectorMagnitude);
                    
                    // Calculate unit normal vector
                    CGFloat unitNormalVectorX = (1 / normalVectorMagnitude) * normalVectorX;
                    CGFloat unitNormalVectorY = (1 / normalVectorMagnitude) * normalVectorY;
                    
                    NSLog(@"Unit normal vector: (%f, %f)", unitNormalVectorX, unitNormalVectorY);
                    
                    // Calculate the unit tangent vector
                    CGFloat unitTangentVectorX = unitNormalVectorY * -1;
                    CGFloat unitTangentVectorY = unitNormalVectorX;
                    
                    NSLog(@"Unit tangent vector: (%f, %f)", unitTangentVectorX, unitTangentVectorY);
                    
                    // Calculate the initial velocity vectors for each ball
                    CGFloat ballInitialVelocityVectorX = ball.originPoint.x - ball.center.x;
                    CGFloat ballInitialVelocityVectorY = ball.originPoint.y - ball.center.y;
                    
                    NSLog(@"Ball velocity vector: (%f, %f)", ballInitialVelocityVectorX, ballInitialVelocityVectorY);
                    
                    CGFloat otherBallInitialVelocityVectorX = otherBall.originPoint.x - otherBall.center.x;
                    CGFloat otherBallInitialVelocityVectorY = otherBall.originPoint.y - otherBall.center.y;
                    
                    NSLog(@"Other ball velocity vector: (%f, %f)", otherBallInitialVelocityVectorX, otherBallInitialVelocityVectorY);
                    
                    // Calculate scalar velocity of each ball in the normal direction (before collision)
                    CGFloat ballNormalVelocity = (unitNormalVectorX * ballInitialVelocityVectorX) +
                                                 (unitNormalVectorY * ballInitialVelocityVectorY);
                    CGFloat otherBallNormalVelocity = (unitNormalVectorX * otherBallInitialVelocityVectorX) +
                                                      (unitNormalVectorY * otherBallInitialVelocityVectorY);
                    
                    NSLog(@"Ball normal velocity: %f", ballNormalVelocity);
                    NSLog(@"Other ball normal velocity: %f", otherBallNormalVelocity);
                    
                    // Calculate scalar velocity of each ball in the tangential direction (before collision)
                    CGFloat ballTangentVelocity = (unitTangentVectorX * ballInitialVelocityVectorX) +
                                                  (unitTangentVectorY * ballInitialVelocityVectorY);
                    CGFloat otherBallTangentVelocity = (unitTangentVectorX * otherBallInitialVelocityVectorX) +
                                                       (unitTangentVectorY * otherBallInitialVelocityVectorY);
                    
                    NSLog(@"Ball tangent velocity: %f", ballTangentVelocity);
                    NSLog(@"Other ball tangent velocity: %f", otherBallTangentVelocity);
                    
                    /*
                     NOTE:
                     The scalar velocity of the first ball in the normal direction (after collision) will be equal
                     to the initial velocity of the second ball (before collision) and vice versa, as both balls are 
                     of equal mass. Hence, the two balls will have 'traded' velocities.
                     */
                    CGFloat ballNormalFinalVelocity = otherBallNormalVelocity;
                    CGFloat otherBallNormalFinalVelocity = ballNormalVelocity;
                    
                    NSLog(@"Ball final normal velocity: %f", ballNormalFinalVelocity);
                    NSLog(@"Other ball final normal velocity: %f", otherBallNormalFinalVelocity);
                    
                    /*
                     NOTE:
                     The scalar velocity of each ball in the tangential direction (after collision) will always equal its 
                     velocity in the tangential direction (before collision), as there is no force acting upon it in that
                     direction. Hence, we will just refer to the initial velocities as the final velocities as well.
                     */
                    
                    // Calculate the normal velocity vectors of each ball (after collision)
                    CGFloat ballNormalVelocityVectorX = ballNormalFinalVelocity * unitNormalVectorX;
                    CGFloat ballNormalVelocityVectorY = ballNormalFinalVelocity * unitNormalVectorY;
                    
                    NSLog(@"Ball normal velocity vector: (%f, %f)", ballNormalVelocityVectorX, ballNormalVelocityVectorY);
                    
                    CGFloat otherBallNormalVelocityVectorX = otherBallNormalFinalVelocity * unitNormalVectorX;
                    CGFloat otherBallNormalVelocityVectorY = otherBallNormalFinalVelocity * unitNormalVectorY;
                    
                    NSLog(@"Other ball normal velocity vector: (%f, %f)", otherBallNormalVelocityVectorX, otherBallNormalVelocityVectorY);
                    
                    // Calculate the tangent velocity vectors of each ball (after collision)
                    CGFloat ballTangentVelocityVectorX = ballTangentVelocity * unitTangentVectorX;
                    CGFloat ballTangentVelocityVectorY = ballTangentVelocity * unitTangentVectorY;
                    
                    NSLog(@"Ball tangent velocity vector: (%f, %f)", ballTangentVelocityVectorX, ballTangentVelocityVectorY);
                    
                    CGFloat otherBallTangentVelocityVectorX = otherBallTangentVelocity * unitTangentVectorX;
                    CGFloat otherBallTangentVelocityVectorY = otherBallTangentVelocity * unitTangentVectorY;
                    
                    NSLog(@"Other ball tangent velocity vector: (%f, %f)", otherBallTangentVelocityVectorX, otherBallTangentVelocityVectorY);
                    
                    // Finally, calculate the final velocity vectors of each ball
                    CGFloat ballFinalVelocityVectorX = ballNormalVelocityVectorX + ballTangentVelocityVectorX;
                    CGFloat ballFinalVelocityVectorY = ballNormalVelocityVectorY + ballTangentVelocityVectorY;
                    
                    NSLog(@"Ball final velocity vector: (%f, %f)", ballFinalVelocityVectorX, ballFinalVelocityVectorY);
                    
                    CGFloat otherBallFinalVelocityVectorX = otherBallNormalVelocityVectorX + otherBallTangentVelocityVectorX;
                    CGFloat otherBallFinalVelocityVectorY = otherBallNormalVelocityVectorY + otherBallTangentVelocityVectorY;
                    
                    NSLog(@"Other ball final velocity vector: (%f, %f)", otherBallFinalVelocityVectorX, otherBallFinalVelocityVectorY);
                    
                    NSLog(@"Old slope of ball: %f", ball.slope);
                    NSLog(@"Old slope of other ball: %f", otherBall.slope);
                    
                    // Adjust each ball's path accordingly
                    ball.slope = ballFinalVelocityVectorY / ballFinalVelocityVectorX;
                    ball.yIntercept = ball.center.y - (ball.slope * ball.center.x);
                    
                    NSLog(@"New slope of ball: %f", ball.slope);
                    
                    otherBall.slope = otherBallFinalVelocityVectorY / otherBallFinalVelocityVectorX;
                    otherBall.yIntercept = otherBall.center.y - (otherBall.slope * otherBall.center.x);
                    
                    NSLog(@"New slope of other ball: %f", otherBall.slope);

                    if (otherBall.stationary)
                    {
                        otherBall.stationary = NO;
                        otherBall.momentum = 50;
                        otherBall.leftToRight = ball.leftToRight;
                        NSLog(@"check 1");
                    }
                    else if (ball.leftToRight && !otherBall.leftToRight)
                    {
                        ball.leftToRight = NO;
                        otherBall.leftToRight = YES;
                        NSLog(@"check 2");
                    }
                    else if (!ball.leftToRight && otherBall.leftToRight)
                    {
                        ball.leftToRight = YES;
                        otherBall.leftToRight = NO;
                        NSLog(@"check 3");
                    }
                    else if (ball.leftToRight && otherBall.leftToRight)
                    {
                        //otherBall.leftToRight = NO;
                        NSLog(@"check 4");
                    }
                    
//                    else if (ballFinalVelocityVectorX > 0 && otherBallFinalVelocityVectorX > 0)
//                    {
//                        ball.leftToRight = YES;
//                        otherBall.leftToRight = YES;
//                    }
//                    else if (ballFinalVelocityVectorX < 0 && otherBallFinalVelocityVectorX < 0)
//                    {
//                        ball.leftToRight = NO;
//                        otherBall.leftToRight = NO;
//                    }
//                    else if (ballFinalVelocityVectorX > 0 && otherBallFinalVelocityVectorX < 0)
//                    {
//                        ball.leftToRight = YES;
//                        otherBall.leftToRight = NO;
//                    }
//                    else if (ballFinalVelocityVectorX < 0 && otherBallFinalVelocityVectorX > 0)
//                    {
//                        ball.leftToRight = NO;
//                        otherBall.leftToRight = YES;
//                    }
//                    
                }
            }
        }
    }
}
@end
