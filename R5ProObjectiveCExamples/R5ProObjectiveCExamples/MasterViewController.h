//
//  MasterViewController.h
//  R5ProObjectiveCExamples
//
//  Created by David Heimann on 6/5/17.
//  Copyright © 2017 Infrared5. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <UINavigationControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;


@end

