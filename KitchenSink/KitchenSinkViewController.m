//
//  KitchenSinkViewController.m
//  KitchenSink
//
//  Created by Marin Fischer on 11/11/13.
//  Copyright (c) 2013 Marin Fischer. All rights reserved.
//

#import "KitchenSinkViewController.h"
#import "AskerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CMMotionManager+Shared.h"

@interface KitchenSinkViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *kitchenSink;
@property (weak, nonatomic) NSTimer *drainTimer; //make this weak b/c it will have a strong pointer to it by the system
@property (weak, nonatomic) UIActionSheet *sinkComtrolActionSheet;
@property (strong, nonatomic) UIPopoverController *imagePickerPopover;

@end

@implementation KitchenSinkViewController

#define MOVE_DURATION 3.0
#define DRAIN_DELAY 0.0
#define DISH_CLEAN_INTERVAL 2.0
#define BLUE_FOOD @"Jello"
#define YELLOW_FOOD @"French Fries"
#define GREEN_FOOD @"Broccoli"
#define ORANGE_FOOD @"Carrot"
#define RED_FOOD @"Beet"
#define PURPLE_FOOD @"Eggplant"
#define BROWN_FOOD @"Potato Peels"
#define SINK_CONTROL @"Sink Controls"
#define SINK_CONTROL_STOP_DRAIN @"Stopper Drain"
#define SINK_CONTROL_UNSTOP_DRAIN @"Unstopper Drain"
#define SINK_CONTROL_CANCEL @"Cancel"
#define SINK_CONTROL_EMPTY @"Empty Sink"
- (IBAction)addFoodPhoto:(UIBarButtonItem *)sender
{
    [self presentImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum sender:sender];
}

- (IBAction)takeFoodPhoto:(UIBarButtonItem *)sender
{
    [self presentImagePicker:UIImagePickerControllerSourceTypeCamera sender:sender];

}
- (void)presentImagePicker: (UIImagePickerControllerSourceType)sourceType sender:(UIBarButtonItem *)sender
{
    if (!self.imagePickerPopover && [UIImagePickerController isSourceTypeAvailable:sourceType]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = sourceType;
            picker.mediaTypes = @[(NSString *)kUTTypeImage];
            picker.allowsEditing = YES;
            picker.delegate = self;
            //present the picker
            if ((sourceType != UIImagePickerControllerSourceTypeCamera) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
                //present popover
                self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:picker];
                [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                self.imagePickerPopover.delegate = self;
                
            } else {
                //modal
            [self presentViewController:picker animated:YES completion:nil];
            }
        }
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePickerPopover = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#define MAX_IMAGE_WIDTH 200
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
        if (image) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            //scale image down by making the frame no bigger than 20 points wide
            CGRect frame = imageView.frame;
            if (frame.size.width > MAX_IMAGE_WIDTH) {
                frame.size.height = (frame.size.height / frame.size.width) * MAX_IMAGE_WIDTH;
            }
            imageView.frame = frame;
            [self setRandomLocationForView:imageView];
            [self.kitchenSink addSubview:imageView];
        }
        if (self.imagePickerPopover) {
            [self.imagePickerPopover dismissPopoverAnimated:YES];
            self.imagePickerPopover = nil;
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)cleanDish
{
    if (self.kitchenSink.window) {
        [self addFood:nil];
        [self performSelector:@selector(cleanDish) withObject:nil afterDelay:DISH_CLEAN_INTERVAL];
    }
}

- (IBAction)controlSink:(UIBarButtonItem *)sender
{
    //keep a pointer to the action sheet
    if (!self.sinkComtrolActionSheet) {
    NSString *drainButton = self.drainTimer ? SINK_CONTROL_STOP_DRAIN : SINK_CONTROL_UNSTOP_DRAIN;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:SINK_CONTROL delegate:self cancelButtonTitle:SINK_CONTROL_CANCEL destructiveButtonTitle:SINK_CONTROL_EMPTY otherButtonTitles:drainButton, nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
        self.sinkComtrolActionSheet = actionSheet;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self.kitchenSink.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    } else {
        NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([choice isEqualToString:SINK_CONTROL_STOP_DRAIN]) {
            [self stopDrainTimer];
        } else if ([choice isEqualToString:SINK_CONTROL_UNSTOP_DRAIN]) {
            [self startDrainTimer];
        }
    }
}

- (void)startDrainTimer
{
    self.drainTimer = [NSTimer scheduledTimerWithTimeInterval:MOVE_DURATION/3 target:self  selector:@selector(drain:) userInfo:nil repeats:YES];
}

- (void)drain:(NSTimer *)timer
{
    [self drain];
}

- (void)stopDrainTimer
{
    [self.drainTimer invalidate];
    self.drainTimer = nil;
}

//just after we appear, start draining, drifting, and cleaning dishes
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startDrainTimer];
    [self cleanDish];
    [self startDrift];
}

//whenever we disappear, stop draining and drifting
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopDrainTimer];
    [self stopDrift];
}

#pragma mark - Drift

#define DRIFT_HZ 10
#define DRIFT_RATE 10
-(void)startDrift
{
    CMMotionManager *motionManager = [CMMotionManager sharedMotionManager];
    if ([motionManager isAccelerometerAvailable]) {
        [motionManager setAccelerometerUpdateInterval:1/DRIFT_HZ]; //how fast
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *data, NSError *error) {
            for (UIView *view in self.kitchenSink.subviews) {
                CGPoint center = view.center;
                center.x += data.acceleration.x * DRIFT_RATE;
                center.y -= data.acceleration.y * DRIFT_RATE;
                view.center = center;
                if (!CGRectContainsRect(self.kitchenSink.bounds, view.frame) && !CGRectIntersectsRect(self.kitchenSink.bounds, view.frame)) {
                    [view removeFromSuperview];
                }  //once its drifted off the screen, remove it from the superview
            }
        }];
    }
}

- (void)stopDrift
{
    [[CMMotionManager sharedMotionManager] stopAccelerometerUpdates];
}

//animate food swirling down the drain. rotates and shrinks
//Make the food drain down the sink in 3rds
- (void)drain
{
    for (UIView *view in self.kitchenSink.subviews) {
        CGAffineTransform transform = view.transform;
        //first 1/3
        if (CGAffineTransformIsIdentity(transform)) {
            [UIView animateWithDuration:MOVE_DURATION/3 delay:DRAIN_DELAY options:UIViewAnimationOptionCurveLinear animations:^{
                view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.7, 0.7), 2 * M_PI/3);
            }completion:^(BOOL finished) {
                //second 1/3
                if (finished) [UIView animateWithDuration:MOVE_DURATION/3 delay:DRAIN_DELAY options:UIViewAnimationOptionCurveLinear animations:^{
                    view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.4, 0.4), -2*M_PI/3);
                }completion:^(BOOL finished) {
                    //last 1/3
                    if (finished) [UIView animateWithDuration:MOVE_DURATION/3 delay:DRAIN_DELAY options:UIViewAnimationOptionCurveLinear animations:^{
                        view.transform = CGAffineTransformScale(transform, 0.1, 0.1);
                    }completion:^(BOOL finished) {
                        if (finished) [view removeFromSuperview];
                    }];
                }];
            }];
        }
    }
}

- (IBAction)tap:(UITapGestureRecognizer *)sender
{
    //find where the tap is located on kitchen sink
    CGPoint tapLocation = [sender locationInView:self.kitchenSink];
    for (UIView *view in self.kitchenSink.subviews) {
        if (CGRectContainsPoint(view.frame, tapLocation)) {
            [UIView animateWithDuration:MOVE_DURATION delay: 0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [self setRandomLocationForView:view];
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.99, 0.99); //while we are intercepting this animation, we will unrotate and cause it so get larger again. we dont want drain to grab it again.
            } completion:^(BOOL finished) {
                //make it elligible to go back down the drain again
                view.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

- (void)addFood:(NSString *)food
{
    //this init calls initWithFrame of 0,0,0,0. So you will need to set the size at some point
    UILabel *foodLabel = [[UILabel alloc] init];
    
    static NSDictionary *foods = nil;
    if (!foods) foods = @{BLUE_FOOD : [UIColor blueColor],
                          GREEN_FOOD : [UIColor greenColor],
                          ORANGE_FOOD : [UIColor orangeColor],
                          RED_FOOD : [UIColor redColor],
                          PURPLE_FOOD : [UIColor purpleColor],
                          YELLOW_FOOD : [UIColor yellowColor],
                          BROWN_FOOD : [UIColor brownColor]};
    if (![food length]) {
        //get the food and pick a random one
        food = [[foods allKeys] objectAtIndex:arc4random()%[foods count]];
        foodLabel.textColor = [foods objectForKey:food];
    }
    

    foodLabel.text = food;
    foodLabel.font = [UIFont systemFontOfSize:46];
    foodLabel.backgroundColor = [UIColor clearColor];
    [foodLabel sizeToFit];  //views that have an intrinsic size can do size to fit. ex.. label or button.

    [self setRandomLocationForView:foodLabel];
    [self.kitchenSink addSubview:foodLabel];
}

//moves the given view to a random location in teh kitchen sink's bounds. Also sizes it to fit
- (void)setRandomLocationForView:(UIView *)view
{
    CGRect sinkBounds = CGRectInset(self.kitchenSink.bounds, view.frame.size.width/2, view.frame.size.height/2);
    CGFloat x = arc4random() % (int)sinkBounds.size.width + view.frame.size.width/2;
    CGFloat y = arc4random() % (int)sinkBounds.size.height + view.frame.size.height/2;
    view.center = CGPointMake(x, y);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Ask"]) {
        AskerViewController *asker = segue.destinationViewController;
        asker.question = @"What food do you want i the sink?";
    }
}

- (IBAction)cancelAsking:(UIStoryboardSegue *)segue
{
    //do nothing
}

-(IBAction)doneAsking:(UIStoryboardSegue *)segue
{
    AskerViewController *asker = segue.sourceViewController;
    [self addFood:asker.answer];
}

@end
