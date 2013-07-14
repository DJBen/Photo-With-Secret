//
//  EncryptMessageViewController.h
//  Photo With Secret
//
//  Created by Sihao Lu on 6/29/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EncryptMessageViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *writeMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *outputImageQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *doNotResizeWarningLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *outputQualitySegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *secretTextField;
@property (strong) UIImage *imageToUse;
- (IBAction)nextButtonClicked:(id)sender;

@end
