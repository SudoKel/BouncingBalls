//
//  ViewController.m
//  BouncingBalls
//
//  Created by Kelwin Joanes on 2017-02-18.
//  Copyright © 2017 com.kelel. All rights reserved.
//

#import "ViewController.h"
#import "BallView.h"

@interface ViewController ()
@property (nonatomic,strong) UILongPressGestureRecognizer *longPress;
@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Handle long press event on root view or arena
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addNewBall:)];
    self.longPress.minimumPressDuration = 0.5f;
    self.longPress.allowableMovement = 50.0f;
    [self.view addGestureRecognizer:self.longPress];
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
@end
