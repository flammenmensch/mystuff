//
//  MSDetailViewController.m
//  MyStuff
//
//  Created by Алексей Протасов on 18.06.14.
//  Copyright (c) 2014 Alexey Protasov. All rights reserved.
//
#import <MobileCoreServices/UTCoreTypes.h>
#import "MSDetailViewController.h"


@interface MSDetailViewController () {
    UIPopoverController *imagePopoverController;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
- (void)presentImagePickerUsingCamera:(BOOL)useCamera;
@end

@implementation MSDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem != nil) {
        self.nameField.text = self.detailItem.name;
        self.locationField.text = self.detailItem.location;
        self.imageView.image = self.detailItem.viewImage;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.view endEditing:NO];
}

- (IBAction)changedDetail:(id)sender {
    if (sender == self.nameField) {
        self.detailItem.name = self.nameField.text;
    } else if (sender == self.locationField) {
        self.detailItem.location = self.locationField.text;
    }
    
    [self.detailItem postDidChangeNotification];
}

- (IBAction)choosePicture:(id)sender {
    if (self.detailItem == nil) {
        return;
    }
    
    BOOL hasPhotoLibrary = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    [self dismissKeyboard:self];
    
    if (!hasPhotoLibrary && !hasCamera) {
        return;
    }
    
    if (hasPhotoLibrary && hasCamera) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Picture", @"Choose a Photo", nil];
        
        [actionSheet showInView:self.view];
        
        return;
    }
    
    [self presentImagePickerUsingCamera:hasCamera];
}

- (void)actionSheet:(UIActionSheet*)actionsheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        case 1:
            [self presentImagePickerUsingCamera:(buttonIndex==0)];
            break;
        default:
            break;
    }
}

- (void)presentImagePickerUsingCamera:(BOOL)useCamera {
    imagePopoverController = nil;
    
    UIImagePickerController *cameraUI = [UIImagePickerController new];
    
    cameraUI.sourceType = (useCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary);
    
    cameraUI.mediaTypes = @[(NSString*)kUTTypeImage];
    cameraUI.delegate = self;
    
    if (useCamera || UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self presentViewController:cameraUI animated:YES completion:nil];
    } else {
        imagePopoverController = [[UIPopoverController alloc] initWithContentViewController:cameraUI];
        
        [imagePopoverController presentPopoverFromRect:self.imageView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage *whatsitImage = info[UIImagePickerControllerEditedImage];
        
        if (whatsitImage == nil) {
            whatsitImage = info[UIImagePickerControllerOriginalImage];
        }
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(whatsitImage, nil, nil, nil);
        }
        
        CGImageRef coreGraphicsImage = whatsitImage.CGImage;
        CGFloat height = CGImageGetHeight(coreGraphicsImage);
        CGFloat width = CGImageGetWidth(coreGraphicsImage);
        
        CGRect crop;
        
        if (height > width) {
            crop.size.height = crop.size.width = width;
            crop.origin.x = 0;
            crop.origin.y = floorf((height - width) / 2);
        } else {
            crop.size.height = crop.size.width = height;
            crop.origin.y = 0;
            crop.origin.x = floorf((width - height) / 2);
        }
        
        CGImageRef croppedImage = CGImageCreateWithImageInRect(coreGraphicsImage, crop);
        
        whatsitImage = [UIImage imageWithCGImage:croppedImage scale:MAX(crop.size.height / 512, 1.0) orientation:whatsitImage.imageOrientation];
        
        CGImageRelease(croppedImage);
        
        _detailItem.image = whatsitImage;
        self.imageView.image = whatsitImage;
        
        [_detailItem postDidChangeNotification];
    }
    
    [self dismissImagePicker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissImagePicker];
}

- (void)dismissImagePicker {
    if (imagePopoverController == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [imagePopoverController dismissPopoverAnimated:YES];
        imagePopoverController = nil;
    }
}

@end
