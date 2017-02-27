//
//  ViewController.m
//  BouncingBalls
//
//  This class controls the movement of all balls
//  within the arena and handles all collisions.
//
//  Created by Kelwin Joanes on 2017-02-18.
//  Copyright © 2017 com.kelel. All rights reserved.
//

#import "ViewController.h"
#import "BallView.h"
#import "Math.h"

@interface ViewController ()
// Properties
@property (nonatomic,strong) UILongPressGestureRecognizer *longPress;      // For adding balls to arena
@property (nonatomic, weak) NSTimer *repeatingTimer;                       // For moving balls and detecting collisions at intervals
@property CGFloat arenaFriction;                                           // For slowing down balls when they hit either of the ends
@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Remove any subviews before adding ball views
    for (UIView *view in self.view.subviews)
        [view removeFromSuperview];
    
    // Set the friction value of arena
    self.arenaFriction = 0.1;

    // Handle long press event on root view or arena
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addNewBall:)];
    self.longPress.minimumPressDuration = 0.5f;
    self.longPress.allowableMovement = 50.0f;
    [self.view addGestureRecognizer:self.longPress];
    
    // Set timer to refresh screen for updates on ball movement
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(checkCollisions) userInfo:nil repeats:YES];
    self.repeatingTimer = timer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** 
 This method adds new balls to the root view or arena.
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
 This method is used to move balls within the arena.
 */
- (void)moveBall:(BallView *)ball
{
    // Only move ball if it has some speed
    if (ball.speed > 0.0)
    {
        CGFloat nextX = 0.0;
        
        // Determine the next x coordinate
        if (ball.leftToRight && !ball.stationary)
        {
            // Move ball slower for steep slopes
            if (ball.slope >= 1000) ball.speed = 0.0001;
            if (ball.slope >= 100)  ball.speed = 0.001;
            if (ball.slope >= 10)   ball.speed = 0.01;
            
            nextX = ball.center.x + ball.speed;
        }
        else if (!ball.leftToRight && !ball.stationary)
        {
            if (ball.slope >= 1000) ball.speed = 0.0001;
            if (ball.slope >= 100)  ball.speed = 0.001;
            if (ball.slope >= 10)   ball.speed = 0.01;
            
            nextX = ball.center.x - ball.speed;
        }
        else
        {
            nextX = ball.center.x;
        }
        
        // Determine the corresponding y coordinate using the slope and y-intercept of the path
        CGFloat nextY = (ball.slope * nextX) + ball.yIntercept;
        
        /* Prevent ball from going out of bounds of parent view */
        // Get x coord of midpoint of the ball
        float midPointX = CGRectGetMidX(ball.bounds);
        
        // Keep within bounds if moved too far right
        if (nextX > self.view.bounds.size.width - midPointX)
        {
            nextX = self.view.bounds.size.width - midPointX;
            ball.slope *= -1;
            ball.yIntercept = ball.center.y - (ball.slope * ball.center.x);
            ball.leftToRight = !ball.leftToRight;
            
            // Modify friction depending on ball speed
            if (ball.speed == 0.0001) self.arenaFriction = 0.00001;
            else if (ball.speed == 0.001) self.arenaFriction = 0.0001;
            else if (ball.speed == 0.01) self.arenaFriction = 0.001;
            else self.arenaFriction = 0.1;
            
            ball.speed -= self.arenaFriction;
        }
        // Or too far left
        else if (nextX < midPointX)
        {
            nextX = midPointX;
            ball.slope *= -1;
            ball.yIntercept = ball.center.y - (ball.slope * ball.center.x);
            ball.leftToRight = !ball.leftToRight;
            
            if (ball.speed == 0.001) self.arenaFriction = 0.00001;
            else if (ball.speed == 0.001) self.arenaFriction = 0.0001;
            else if (ball.speed == 0.01) self.arenaFriction = 0.001;
            else self.arenaFriction = 0.1;
            
            ball.speed -= self.arenaFriction;
        }
        
        // Get y coord of midpoint of the ball
        float midPointY = CGRectGetMidY(ball.bounds);
        
        // Keep within bounds if move too far down
        if (nextY > self.view.bounds.size.height - midPointY)
        {
            nextY = self.view.bounds.size.height - midPointY;
            ball.slope *= -1;
            ball.yIntercept = ball.center.y - (ball.slope * ball.center.x);
            ball.speed -= self.arenaFriction;
        }
        // Or too far up
        else if (nextY < midPointY)
        {
            nextY = midPointY;
            ball.slope *= -1;
            ball.yIntercept = ball.center.y - (ball.slope * ball.center.x);
            ball.speed -= self.arenaFriction;
        }
        
        // Update the center point of the ball
        ball.center = CGPointMake(nextX, nextY);
    }
}

/**
 This method moves balls in the arena when flicked and
 also checks for and handles all collisions.
 */
- (void)checkCollisions
{
    // Update movement of each ball within arena
    for (BallView *ball in self.view.subviews)
    {
        [self moveBall:ball];
        
        for (BallView *otherBall in self.view.subviews)
        {
            // Check the current ball for collision with other balls in arena
            if (![otherBall isDescendantOfView:ball])
            {
                // Calculate distance between the two balls using Pythagoras' Theorem
                CGFloat distance = sqrtf((powf(ball.center.x - otherBall.center.x, 2)) + (powf(ball.center.y - otherBall.center.y, 2)));
                
                // Handle any collisions detected
                if (distance <= ball.radius + otherBall.radius)
                {
                    CGFloat newX = ball.center.x;
                    CGFloat newY = 0.0;
                    
                    // Resolve any overlap before calculating new paths of the balls
                    while (distance < ball.radius + otherBall.radius)
                    {
                        // Determine next x coordinate to move ball back
                        if (ball.leftToRight)
                            newX -= 0.1;
                        else
                            newX += 0.1;
                        
                        // Calculate corresponding y coordinate
                        newY = (ball.slope * newX) + ball.yIntercept;
                        
                        // Recalculate the distance
                        distance = sqrtf((powf(newX - otherBall.center.x, 2)) + (powf(newY - otherBall.center.y, 2)));
                    
                        // Set the ball's new center as soon as overlap has been resolved
                        if (distance >= ball.radius + otherBall.radius)
                            ball.center = CGPointMake(newX, newY);
                    }
                    
                    // Calculate and set the new paths for the two balls
                    [self calculateNewPathsForBall:ball otherBall:otherBall];
                }
            }
        }
    }
}

/**
 This method calculates the new paths for the balls
 that have collided.
 */
- (void) calculateNewPathsForBall:(BallView *)ball otherBall:(BallView *)otherBall
{
    // For the following calculations we will represent vectors as 2D points
    // Calculate the normal vector
    CGPoint normVector = CGPointMake(otherBall.center.x - ball.center.x, otherBall.center.y - ball.center.y);
    
    // Calculate magnitude of the normal vector
    CGFloat normVectorMagnitude = sqrtf(powf(normVector.x, 2) + powf(normVector.y, 2));
    
    // Calculate unit normal vector
    CGPoint unitNormVector = CGPointMake((1 / normVectorMagnitude) * normVector.x, (1 / normVectorMagnitude) * normVector.y);
    
    // Calculate the unit tangent vector
    CGPoint unitTanVector = CGPointMake(unitNormVector.y * -1, unitNormVector.x);
    
    // Calculate the initial velocity vectors for each ball
    CGPoint ballInitVelocityVector = CGPointMake(ball.originPoint.x - ball.center.x, ball.originPoint.y - ball.center.y);
    CGPoint otherBallInitVelocityVector = CGPointMake(otherBall.originPoint.x - otherBall.center.x, otherBall.originPoint.y - otherBall.center.y);
    
    // Calculate scalar velocity of each ball in the normal direction (before collision)
    CGFloat ballNormVelocity = (unitNormVector.x * ballInitVelocityVector.x) + (unitNormVector.y * ballInitVelocityVector.y);
    CGFloat otherBallNormVelocity = (unitNormVector.x * otherBallInitVelocityVector.x) + (unitNormVector.y * otherBallInitVelocityVector.y);
    
    // Calculate scalar velocity of each ball in the tangential direction (before collision)
    CGFloat ballTanVelocity = (unitTanVector.x * ballInitVelocityVector.x) + (unitTanVector.y * ballInitVelocityVector.y);
    CGFloat otherBallTanVelocity = (unitTanVector.x * otherBallInitVelocityVector.x) + (unitTanVector.y * otherBallInitVelocityVector.y);
    
    /*
     The scalar velocity of the first ball in the normal direction (after collision) will be equal
     to the initial velocity of the second ball (before collision) and vice versa, as both balls are
     of equal mass. Hence, the two balls will have 'traded' velocities.
     */
    
    CGFloat ballNormFinalVelocity = otherBallNormVelocity;
    CGFloat otherBallNormFinalVelocity = ballNormVelocity;
    
    /*
     The scalar velocity of each ball in the tangential direction (after collision) will always equal its
     velocity in the tangential direction (before collision), as there is no force acting upon it in that
     direction. Hence, we will just refer to the initial tan velocities as the final tan velocities as well.
     */
    
    // Calculate the normal velocity vectors of each ball (after collision)
    CGPoint ballNormVelocityVector = CGPointMake(ballNormFinalVelocity * unitNormVector.x, ballNormFinalVelocity * unitNormVector.y);
    CGPoint otherBallNormVelocityVector = CGPointMake(otherBallNormFinalVelocity * unitNormVector.x, otherBallNormFinalVelocity * unitNormVector.y);

    // Calculate the tangent velocity vectors of each ball (after collision)
    CGPoint ballTanVelocityVector = CGPointMake(ballTanVelocity * unitTanVector.x, ballTanVelocity * unitTanVector.y);
    CGPoint otherBallTanVelocityVector = CGPointMake(otherBallTanVelocity * unitTanVector.x, otherBallTanVelocity * unitTanVector.y);
    
    // Finally, calculate the final velocity vectors of each ball
    CGPoint ballFinalVelocityVector = CGPointMake(ballNormVelocityVector.x + ballTanVelocityVector.x, ballNormVelocityVector.y + ballTanVelocityVector.y);
    CGPoint otherBallFinalVelocityVector = CGPointMake(otherBallNormVelocityVector.x + otherBallTanVelocityVector.x, otherBallNormVelocityVector.y + otherBallTanVelocityVector.y);

    // Adjust each ball's path accordingly
    if (ballFinalVelocityVector.x != 0)     // Avoid division by zero
    {
        ball.slope = ballFinalVelocityVector.y / ballFinalVelocityVector.x;
        ball.yIntercept = ball.center.y - (ball.slope * ball.center.x);
    }
    
    if (otherBallFinalVelocityVector.x != 0)
    {
        otherBall.slope = otherBallFinalVelocityVector.y / otherBallFinalVelocityVector.x;
        otherBall.yIntercept = otherBall.center.y - (otherBall.slope * otherBall.center.x);
    }
    
    // Set the direction for the balls after collision
    if (otherBall.stationary)                           // Handle the case where one of the balls is stationary before collision
    {
        otherBall.stationary = NO;
        otherBall.speed = 1.0;
        otherBall.leftToRight = ball.leftToRight;
        ball.leftToRight = !ball.leftToRight;
        
        // If centres are aligned then exchange of velocity will result in ball becoming stationary
        if (ball.center.x == otherBall.center.x || ball.center.y == otherBall.center.y)
            ball.stationary = YES;
    }
    else                                                // Otherwise handle the case where two balls collide while moving
        ball.leftToRight = !ball.leftToRight;
    
    // Reset speeds of both balls to initial value
    ball.speed = 1.0;
    otherBall.speed = 1.0;
}
@end
