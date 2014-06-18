//
//  MSMasterViewController.h
//  MyStuff
//
//  Created by Алексей Протасов on 18.06.14.
//  Copyright (c) 2014 Alexey Protasov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSDetailViewController;

@interface MSMasterViewController : UITableViewController

@property (strong, nonatomic) MSDetailViewController *detailViewController;

@end
