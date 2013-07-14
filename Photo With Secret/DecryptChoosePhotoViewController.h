//
//  DecryptChoosePhotoViewController.h
//  Photo With Secret
//
//  Created by Sihao Lu on 6/30/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DecryptChoosePhotoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *choosePhotoLabel;
@property (weak, nonatomic) IBOutlet UIButton *existingPhotoButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImage *imageToUse;
- (IBAction)existingPhotoButtonClicked:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;

@end
