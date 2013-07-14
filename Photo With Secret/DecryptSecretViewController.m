//
//  DecryptSecretViewController.m
//  Photo With Secret
//
//  Created by Sihao Lu on 7/1/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "DecryptSecretViewController.h"
#import "UIImage+ImageEffects.h"

@interface DecryptSecretViewController ()

@end

@implementation DecryptSecretViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self configureViewSpecialEffect:self.secretMessageLabel cornerRadius:4.0];
    self.secretMessageContentLabel.text = self.secretMessage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applyBackgroundToView:(UIView *)view sourceBlurFromView:(UIView *)backgroundView {
    CGRect buttonRectInBGViewCoords = [view convertRect:view.bounds toView:backgroundView];
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[[[self view] window] screen] scale]);
    /*
     Note that in seed 1, drawViewHierarchyInRect: does not function correctly. This has been fixed in seed 2. Seed 1 users will have empty images returned to them.
     */
    [backgroundView drawViewHierarchyInRect:CGRectMake(-buttonRectInBGViewCoords.origin.x, -buttonRectInBGViewCoords.origin.y, CGRectGetWidth(backgroundView.frame), CGRectGetHeight(backgroundView.frame))];
    UIImage *newBGImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    newBGImage = [newBGImage applyBlurWithRadius:5 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
    
    if ([view isKindOfClass:[UIButton class]]) {
        [(UIButton *)view setBackgroundImage:newBGImage forState:UIControlStateNormal];
    } else {
        [view setBackgroundColor:[UIColor colorWithPatternImage:newBGImage]];
    }
}

- (void) configureViewSpecialEffect:(UIView *)view cornerRadius:(CGFloat)cornerRadius {
    view.layer.mask.frame = view.bounds;
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
    
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-10.0];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:10.0];
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-10.0];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:10.0];
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis, yAxis];
    [view addMotionEffect:group];
}

@end
