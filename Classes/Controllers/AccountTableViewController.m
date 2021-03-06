//
//  AccountTableViewController.m
//  Sechat
//
//  Created by Albert Moky on 2018/12/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSNotificationCenter+Extension.h"
#import "UIImageView+Extension.h"

#import "User.h"
#import "Facebook+Register.h"

#import "Client.h"

#import "AccountTableViewController.h"

@interface AccountTableViewController ()

@end

@implementation AccountTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    Client *client = [Client sharedInstance];
    DIMUser *user = client.currentUser;
    if (user) {
        DIMProfile *profile = DIMProfileForID(user.ID);
        
        // avatar
        CGRect avatarFrame = _avatarImageView.frame;
        UIImage *image = [profile avatarImageWithSize:avatarFrame.size];
        if (!image) {
            image = [UIImage imageNamed:@"AppIcon"];
        }
        [_avatarImageView setImage:image];
        [_avatarImageView roundedCorner];
        
        // name
        _nameLabel.text = account_title(user);
        
        // desc
        _descLabel.text = (NSString *)user.ID;
    } else {
        _nameLabel.text = @"USER NOT FOUND";
        _descLabel.text = @"Please register/login first.";
        
        // show register view controller
        [self performSegueWithIdentifier:@"registerSegue" sender:self];
    }
    
    [NSNotificationCenter addObserver:self
                             selector:@selector(reloadData)
                                 name:kNotificationName_UsersUpdated
                               object:nil];
}

- (void)reloadData {
    // TODO: update client.users
    DIMUser *user = [Client sharedInstance].currentUser;
    DIMProfile *profile = DIMProfileForID(user.ID);
    
    // avatar
    CGRect avatarFrame = _avatarImageView.frame;
    UIImage *image = [profile avatarImageWithSize:avatarFrame.size];
    if (!image) {
        image = [UIImage imageNamed:@"AppIcon"];
    }
    [_avatarImageView setImage:image];
    //[_avatarImageView roundedCorner];
    
    // name
    _nameLabel.text = account_title(user);
    
    // desc
    _descLabel.text = (NSString *)user.ID;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    
    if (section == 1) {
        Client *client = [Client sharedInstance];
        return client.users.count;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;// = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    NSString *identifier = nil;
    
    // Configure the cell...
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    Client *client = [Client sharedInstance];
    DIMUser *user = nil;
    
    if (section == 1) {
        // Accounts
        user = [client.users objectAtIndex:row];
        
        identifier = @"AccountCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AccountCell"];
        }
        if ([user isEqual:client.currentUser]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = account_title(user);
        return cell;
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    //NSInteger row = indexPath.row;
    if (section == 1) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    }
    
    return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    //NSInteger row = indexPath.row;
    if (section == 1) {
        return 44;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    Client *client = [Client sharedInstance];
    DIMUser *user = nil;
    
    if (section == 1) {
        // All account(s)
        user = [client.users objectAtIndex:row];
        if ([user isEqual:client.currentUser]) {
            return NO;
        }
        return YES;
    }
    
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView beginUpdates];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSInteger row = indexPath.row;
        
        Client *client = [Client sharedInstance];
        DIMUser *user = [client.users objectAtIndex:row];
        [client removeUser:user];
        
        Facebook *facebook = [Facebook sharedInstance];
        [facebook removeUser:user];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
    [tableView endUpdates];
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSLog(@"section: %ld, row: %ld", (long)section, (long)row);
    
    Client *client = [Client sharedInstance];
    Facebook *facebook = [Facebook sharedInstance];
    
    if (section == 0) {
        // Account
    } else if (section == 1) {
        // Users
        DIMUser *user = [client.users objectAtIndex:row];
        if (![user isEqual:client.currentUser]) {
            [client login:user];
            [facebook reloadContactsWithUser:user];
            [NSNotificationCenter postNotificationName:kNotificationName_ContactsUpdated object:self];
            [self reloadData];
            // update user ID list file
            [facebook saveUserList:client.users withCurrentUser:client.currentUser];
        }
        
    } else if (section == 2) {
        // Functions
    } else if (section == 3) {
        // Setting
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
