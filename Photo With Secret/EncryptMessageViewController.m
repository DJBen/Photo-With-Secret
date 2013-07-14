//
//  EncryptMessageViewController.m
//  Photo With Secret
//
//  Created by Sihao Lu on 6/29/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "EncryptMessageViewController.h"
#import "UIImage+ImageEffects.h"
#import "ImageHelper.h"
#import "UIImage+Resize.h"
#import "NSString+Brainfuck.h"
#import "MMProgressHUD.h"

@interface EncryptMessageViewController ()

@property (strong) UIImage *encodedImage;

@end

@implementation EncryptMessageViewController

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
    [self.backgroundImageView setImage:self.imageToUse];
    [self configureViewSpecialEffect:self.writeMessageLabel cornerRadius:4.0];
    [self configureViewSpecialEffect:self.outputImageQualityLabel cornerRadius:4.0];
    [self configureViewSpecialEffect:self.outputQualitySegmentedControl cornerRadius:4.0];
    [self configureViewSpecialEffect:self.doNotResizeWarningLabel cornerRadius:4.0];
    [self configureViewSpecialEffect:self.secretTextField cornerRadius:4.0];
}

- (void)viewDidAppear:(BOOL)animated {
    [self applyBackgroundToView:self.writeMessageLabel sourceBlurFromView:self.backgroundImageView];
    [self applyBackgroundToView:self.outputImageQualityLabel sourceBlurFromView:self.backgroundImageView];
    [self applyBackgroundToView:self.outputQualitySegmentedControl sourceBlurFromView:self.backgroundImageView];
    [self applyBackgroundToView:self.doNotResizeWarningLabel sourceBlurFromView:self.backgroundImageView];
    [self applyBackgroundToView:self.secretTextField sourceBlurFromView:self.backgroundImageView];
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

- (UIImage *)encodedImage:(UIImage *)sourceImage {
    NSLog(@"Encoded begins");
    NSString *secretInBrainfuckCode = [self.secretTextField.text brainfuckCode];
    NSUInteger interval = sourceImage.size.width * sourceImage.size.height / secretInBrainfuckCode.length;
    if (interval < 1) {
        NSLog(@"Picture too small to hold all the info");
        return nil;
    }
    NSLog(@"Interval = %d", interval);
    NSUInteger brainfuckCodeIndex = 0;
    unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:sourceImage];
    BOOL terminated = NO;
    for (int i = 0; i < sourceImage.size.height; i++) {
        for (int j = 0; j < 4 * sourceImage.size.width; j+=4) {
            int index = i * 4 * sourceImage.size.width + j;
            if (index == 0) {
                bitmap[index] = interval / 255 / 255;
                bitmap[index + 1] = (interval - interval / 255 / 255 * 255 * 255) / 255;
                bitmap[index + 2] = interval % 255;
                NSLog(@"Encoded interval = %d %d %d", bitmap[index], bitmap[index + 1], bitmap[index + 2]);
                continue;
            }
            if (index == 4) {
                bitmap[index] = 255.0 - bitmap[index - 4];
                bitmap[index + 1] = 255.0 - bitmap[index + 1 - 4];
                bitmap[index + 2] = 255.0 - bitmap[index + 2 - 4];
                continue;
            }
            if (index / 4 % interval != 0) {
                continue;
            }
            unsigned char red = bitmap[index];
            unsigned char green = bitmap[index + 1];
            unsigned char blue = bitmap[index + 2];
            if (brainfuckCodeIndex >= secretInBrainfuckCode.length) {
                if (!terminated) {
                    red = [self round:red withMod:1 base:2];
                    green = [self round:green withMod:1 base:2];
                    blue = [self round:blue withMod:1 base:2];
                    bitmap[index] = red;
                    bitmap[index + 1] = green;
                    bitmap[index + 2] = blue;
                    terminated = YES;
                }
                break;
            }
            switch ([secretInBrainfuckCode characterAtIndex:brainfuckCodeIndex]) {
                case '<':
                    red = [self round:red withMod:0 base:2];
                    green = [self round:green withMod:0 base:2];
                    blue = [self round:blue withMod:0 base:2];
                    break;
                case '>':
                    red = [self round:red withMod:0 base:2];
                    green = [self round:green withMod:0 base:2];
                    blue = [self round:blue withMod:1 base:2];
                    break;
                case '+':
                    red = [self round:red withMod:0 base:2];
                    green = [self round:green withMod:1 base:2];
                    blue = [self round:blue withMod:0 base:2];
                    break;
                case '-':
                    red = [self round:red withMod:0 base:2];
                    green = [self round:green withMod:1 base:2];
                    blue = [self round:blue withMod:1 base:2];
                    break;
                case '[':
                    red = [self round:red withMod:1 base:2];
                    green = [self round:green withMod:0 base:2];
                    blue = [self round:blue withMod:0 base:2];
                    break;
                case ']':
                    red = [self round:red withMod:1 base:2];
                    green = [self round:green withMod:0 base:2];
                    blue = [self round:blue withMod:1 base:2];
                    break;
                case '.':
                    red = [self round:red withMod:1 base:2];
                    green = [self round:green withMod:1 base:2];
                    blue = [self round:blue withMod:0 base:2];
                    break;
                default:
                    break;
            }
            bitmap[index] = red;
            bitmap[index + 1] = green;
            bitmap[index + 2] = blue;
            brainfuckCodeIndex++;
        }
    }
    
    return [ImageHelper convertBitmapRGBA8ToUIImage:bitmap withWidth:sourceImage.size.width withHeight:sourceImage.size.height];
}



- (unsigned char)round:(unsigned char)value withMod:(int)mod base:(int)base {
    value += (base - value % base) + mod;
    if (value > 255) {
        value -= base;
    }
    return value;
}

- (UIImage *)resizedImage {
    CGSize targetSize;
    CGFloat const lowQualityMaxLength = 500.0;
    CGFloat const mediumQualityMaxLength = 1000.0;
    CGFloat const highQualityMaxLength = 1500.0;
    switch (self.outputQualitySegmentedControl.selectedSegmentIndex) {
        case 0:
            // Low Quality
            if (self.imageToUse.size.width > self.imageToUse.size.height) {
                if (self.imageToUse.size.width <= lowQualityMaxLength) return self.imageToUse;
                targetSize = CGSizeMake(lowQualityMaxLength, lowQualityMaxLength / self.imageToUse.size.width * self.imageToUse.size.height);
            } else {
                if (self.imageToUse.size.height <= lowQualityMaxLength) return self.imageToUse;
                targetSize = CGSizeMake(lowQualityMaxLength / self.imageToUse.size.height * self.imageToUse.size.width, lowQualityMaxLength);
            }
            break;
        case 1:
            // Medium Quality
            if (self.imageToUse.size.width > self.imageToUse.size.height) {
                if (self.imageToUse.size.width <= mediumQualityMaxLength) return self.imageToUse;
                targetSize = CGSizeMake(mediumQualityMaxLength, mediumQualityMaxLength / self.imageToUse.size.width * self.imageToUse.size.height);
            } else {
                if (self.imageToUse.size.height <= mediumQualityMaxLength) return self.imageToUse;
                targetSize = CGSizeMake(mediumQualityMaxLength / self.imageToUse.size.height * self.imageToUse.size.width, mediumQualityMaxLength);
            }
            break;
        case 2:
            // High Quality
            if (self.imageToUse.size.width > self.imageToUse.size.height) {
                if (self.imageToUse.size.width <= highQualityMaxLength) return self.imageToUse;
                targetSize = CGSizeMake(highQualityMaxLength, highQualityMaxLength / self.imageToUse.size.width * self.imageToUse.size.height);
            } else {
                if (self.imageToUse.size.height <= highQualityMaxLength) return self.imageToUse;
                targetSize = CGSizeMake(highQualityMaxLength / self.imageToUse.size.height * self.imageToUse.size.width, highQualityMaxLength);
            }
            break;
        default:
            break;
    }
    self.imageToUse = [self.imageToUse resizedImage:targetSize interpolationQuality:kCGInterpolationDefault];
    NSLog(@"Resized");
    return self.imageToUse;
}

- (IBAction)nextButtonClicked:(id)sender {
    // Display HUD
    [MMProgressHUD showProgressWithStyle:MMProgressHUDProgressStyleIndeterminate title:NSLocalizedString(@"Hiding Secret", @"Progress HUD") status:NSLocalizedString(@"Please wait...", @"Progress HUD")];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        self.encodedImage = [self encodedImage:[self resizedImage]];
        NSData *encodedImageData = UIImagePNGRepresentation(self.encodedImage);
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:encodedImageData], self, nil, nil);
        dispatch_async(main_queue, ^{
            [MMProgressHUD dismiss];
        });
    });
}
@end
