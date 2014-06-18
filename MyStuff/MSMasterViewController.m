//
//  MSMasterViewController.m
//  MyStuff
//
//  Created by Алексей Протасов on 18.06.14.
//  Copyright (c) 2014 Alexey Protasov. All rights reserved.
//

#import "MSMasterViewController.h"

#import "MSDetailViewController.h"

#import "MyWhatsit.h"

@interface MSMasterViewController () {
    NSMutableArray *things;
}

- (void)whatsitDidChangeNotification:(NSNotification*)notification;

@end

@implementation MSMasterViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    
    things = [@[
                [[MyWhatsit alloc] initWithName:@"Gort" location:@"den"],
                [[MyWhatsit alloc] initWithName:@"Disappearing TARDIS mug" location:@"kitchen"],
                [[MyWhatsit alloc] initWithName:@"Robot USB drive" location:@"office"],
                [[MyWhatsit alloc] initWithName:@"Sad Robot USB hub" location:@"office"],
                [[MyWhatsit alloc] initWithName:@"Solar Powered Bunny" location:@"office"]
    ] mutableCopy];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(whatsitDidChangeNotification:) name:kWhatsitDidChangeNotification object:nil];
    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (MSDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!things) {
        things = [[NSMutableArray alloc] init];
    }
    
    static unsigned int itemNumber = 1;
    NSString *newItemName = [NSString stringWithFormat:@"My Item %u", itemNumber++];
    NSString *newItemLocation = @"unknown";
    
    MyWhatsit *newItem = [[MyWhatsit alloc] initWithName:newItemName location:newItemLocation];
    
    [things insertObject:newItem atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return things.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    MyWhatsit *thing = things[indexPath.row];
    
    cell.textLabel.text = thing.name;
    cell.detailTextLabel.text = thing.location;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [things removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        MyWhatsit *object = things[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MyWhatsit *object = things[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

- (void)whatsitDidChangeNotification:(NSNotification *)notification {
    NSUInteger index = [things indexOfObject:notification.object];
    
    if (index != NSNotFound) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
        
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
