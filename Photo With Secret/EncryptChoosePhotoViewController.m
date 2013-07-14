//
//  ViewController.m
//  Photo With Secret
//
//  Created by Sihao Lu on 6/29/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import "EncryptChoosePhotoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "EncryptMessageViewController.h"
#import "UIImage+ImageEffects.h"

@interface EncryptChoosePhotoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImage *imageToUse;

@end

@implementation EncryptChoosePhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureViewSpecialEffect:self.choosePhotoLabel cornerRadius:4.0];
    [self configureViewSpecialEffect:self.takeNewPhotoButton cornerRadius:8.0];
    [self configureViewSpecialEffect:self.existingPhotoButton cornerRadius:8.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"messageSegue"]) {
        [(EncryptMessageViewController *)segue.destinationViewController setImageToUse:self.imageToUse];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"messageSegue"]) {
        if (!self.imageToUse) {
            UIAlertView *noPhotoChosenAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Photo Chosen", @"No Photo Chosen Alert") message:NSLocalizedString(@"Please choose a photo before going next.", @"No Photo Chosen Alert") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [noPhotoChosenAlert show];
            return NO;
        }
    }
    return YES;
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

- (IBAction)newPhotoButtonClicked:(id)sender {
    [self startMediaBrowserFromViewController:self sourceType:UIImagePickerControllerSourceTypeCamera usingDelegate:self];
}

- (IBAction)existingPhotoButtonClicked:(id)sender {
    [self startMediaBrowserFromViewController:self sourceType:UIImagePickerControllerSourceTypePhotoLibrary usingDelegate:self];
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
        [self applyBackgroundToView:self.takeNewPhotoButton sourceBlurFromView:self.backgroundImageView];
        [self applyBackgroundToView:self.existingPhotoButton sourceBlurFromView:self.backgroundImageView];
    }];
    
}
@end
