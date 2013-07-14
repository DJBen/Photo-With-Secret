//
//  ViewController.h
//  Photo With Secret
//
//  Created by Sihao Lu on 6/29/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EncryptChoosePhotoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *choosePhotoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *takeNewPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *existingPhotoButton;
- (IBAction)newPhotoButtonClicked:(id)sender;
- (IBAction)existingPhotoButtonClicked:(id)sender;

@end
