//
//  BAViewController.h
//  BAPersistentOperationQueueExample
//
//  Created by Bruno Abrantes on 23/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BAPersistentOperationQueue/BAPersistentOperationQueue.h>
#import "BARequest.h"

@interface BAViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, BARequestDelegate, BAPersistentOperationQueueDelegate>

@property (nonatomic, weak) IBOutlet UIButton *stateButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
