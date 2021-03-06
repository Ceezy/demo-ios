//
//  ProfileTableViewController.h
//  Sechat
//
//  Created by Albert Moky on 2018/12/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Table view controller for Contact Profile
 */
@interface ProfileTableViewController : UITableViewController

@property (strong, nonatomic) DIMAccount *account;

@end

NS_ASSUME_NONNULL_END
