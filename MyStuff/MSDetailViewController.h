//
//  MSDetailViewController.h
//  MyStuff
//
//  Created by Алексей Протасов on 18.06.14.
//  Copyright (c) 2014 Alexey Protasov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyWhatsit.h"

@interface MSDetailViewController : UIViewController <UISplitViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) MyWhatsit *detailItem;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)choosePicture:(id)sender;

- (IBAction)changedDetail:(id)sender;

@end
