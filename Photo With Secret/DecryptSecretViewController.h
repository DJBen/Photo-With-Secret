//
//  DecryptSecretViewController.h
//  Photo With Secret
//
//  Created by Sihao Lu on 7/1/13.
//  Copyright (c) 2013 Sihao Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DecryptSecretViewController : UIViewController

@property (nonatomic, strong) NSString *secretMessage;
@property (weak, nonatomic) IBOutlet UILabel *secretMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *secretMessageContentLabel;

@end
