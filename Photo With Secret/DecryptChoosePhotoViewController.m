//
//  DecryptChoosePhotoViewController.m
//  Photo With Secret
//
//  Created by Sihao Lu on 6/30/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "DecryptChoosePhotoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+ImageEffects.h"
#import "ImageHelper.h"
#import "NSString+Brainfuck.h"
#import "DecryptSecretViewController.h"
#import "MMProgressHUD.h"

@interface DecryptChoosePhotoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSString *secretMessage;

@end

@implementation DecryptChoosePhotoViewController

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
    [self configureViewSpecialEffect:self.choosePhotoLabel cornerRadius:4.0];
    [self configureViewSpecialEffect:self.existingPhotoButton cornerRadius:8.0];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"decryptMessageSegue"]) {
        [(DecryptSecretViewController *)segue.destinationViewController setSecretMessage:self.secretMessage];
        
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"decryptMessageSegue"]) {
        if (!self.imageToUse) {
            UIAlertView *noPhotoChosenAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Photo Chosen", @"No Photo Chosen Alert") message:NSLocalizedString(@"Please choose a photo before going next.", @"No Photo Chosen Alert") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [noPhotoChosenAlert show];
            return NO;
        }
    }
    return YES;
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

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                                  sourceType:(UIImagePickerControllerSourceType)sourceType
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = sourceType;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

- (IBAction)existingPhotoButtonClicked:(id)sender {
    [self startMediaBrowserFromViewController:self sourceType:UIImagePickerControllerSourceTypePhotoLibrary usingDelegate:self];
}

- (IBAction)nextButtonClicked:(id)sender {
    // Display HUD
   [MMProgressHUD showProgressWithStyle:MMProgressHUDProgressStyleIndeterminate title:NSLocalizedString(@"Revealing Secret", @"Progress HUD") status:NSLocalizedString(@"Please wait...", @"Progress HUD")];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        self.secretMessage = [self secretInImage:self.imageToUse];
        dispatch_async(main_queue, ^{
            [MMProgressHUD dismiss];
            if (!self.secretMessage) {
                UIAlertView *imageHasNoSecretAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Secret not found", @"Image Has No Secret Alert") message:NSLocalizedString(@"This image does not contain a secret or it is broken.", @"Image Has No Secret Alert") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", Nil) otherButtonTitles:nil];
                [imageHasNoSecretAlert show];
            } else {
                [self performSegueWithIdentifier:@"decryptMessageSegue" sender:self];
            }
        });
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) info[UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) info[UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        // Do something with imageToUse
        self.imageToUse = imageToUse;
        self.backgroundImageView.image = self.imageToUse;
    }
    
    // Handle a movied picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        // NSString *moviePath = [info[UIImagePickerControllerMediaURL] path];
        
        // Do something with the picked movie available at moviePath
        NSString *cannotUseMovieComment;
        cannotUseMovieComment = @"Cannot Use Movie Alert";
        UIAlertView *cannotUseMovieAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Use Movie", cannotUseMovieComment) message:NSLocalizedString(@"Please choose a still image.", cannotUseMovieComment) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [picker dismissViewControllerAnimated:YES completion:^{
            [cannotUseMovieAlert show];
        }];
        return;
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self applyBackgroundToView:self.choosePhotoLabel sourceBlurFromView:self.backgroundImageView];
        [self applyBackgroundToView:self.existingPhotoButton sourceBlurFromView:self.backgroundImageView];
    }];
    
}

- (NSString *)secretInImage:(UIImage *)sourceImage {
    NSMutableString *message = [[NSMutableString alloc] init];
    unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:sourceImage];
    NSUInteger interval = bitmap[0] * 255 * 255 + bitmap[1] * 255 + bitmap[2];
//    NSLog(@"calculated interval = %d", interval);
    BOOL valid = YES;
    for (int i = 0; i < 2; i++) {
        if (bitmap[i] != 255 - bitmap[i + 4]) valid = NO;
    }
//    for (int i = 0; i < 8; i++) {
//        NSLog(@"bit %d = %d", i, bitmap[i]);
//    }
//    
    if (!valid || interval == 0) {
        NSLog(@"This image does not contain a secret or it is broken.");
        return nil;
    }
    for (int i = 0; i < self.imageToUse.size.height; i++) {
        for (int j = 0; j < 4 * self.imageToUse.size.width; j+=4) {
            int index = i * 4 * self.imageToUse.size.width + j;
            if (index / 4 % interval != 0 || index <= 1) {
                continue;
            }
            unsigned char red = bitmap[index];
            unsigned char green = bitmap[index + 1];
            unsigned char blue = bitmap[index + 2];
            NSString *currentBrainfuckCodeBit = [self brainfuckCodeStringByDecodingRed:red green:green blue:blue];
            if ([currentBrainfuckCodeBit isEqualToString:@"terminator"]) {
                return [[message copy] parseBrainfuckCode];
            }
            [message appendString:currentBrainfuckCodeBit];
        }
    }
    return [[message copy] parseBrainfuckCode];
}

- (NSString *)brainfuckCodeStringByDecodingRed:(unsigned char)red green:(unsigned char)green blue:(unsigned char)blue {
    int value = red % 2 * 4 + green % 2 * 2 + blue % 2;
    switch (value) {
        case 0:
            return @"<";
        case 1:
            return @">";
        case 2:
            return @"+";
        case 3:
            return @"-";
        case 4:
            return @"[";
        case 5:
            return @"]";
        case 6:
            return @".";
        case 7:
            return @"terminator";
        default:
            break;
    }
//    NSLog(@"!!! %d: %d %d %d", value, red, green, blue);
    return nil;
}


@end
