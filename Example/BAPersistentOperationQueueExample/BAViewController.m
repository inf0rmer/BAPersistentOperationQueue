//
//  BAViewController.m
//  BAPersistentOperationQueueExample
//
//  Created by Bruno Abrantes on 23/05/14.
//  Copyright (c) 2014 Bruno Abrantes. All rights reserved.
//

#import "BAViewController.h"

@interface BAViewController ()

@property (nonatomic, assign) BOOL online;

@end

@implementation BAViewController {
  NSMutableArray *requests;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	
  _online = YES;
  requests = [[NSMutableArray alloc] init];
  [self updateStateButton];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSourceDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:tableView numberOfRowsInSection:(NSInteger)section
{
  return requests.count;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  
  BARequest *request = requests[indexPath.row];
  
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
  }

  cell.textLabel.text = request.name;
  cell.detailTextLabel.text = (request.finished) ? @"Finished!" : (request.performing) ? @"Working..." : @"Stopped";
  
  return cell;
}

#pragma mark - IBActions
- (IBAction)switchState:(id)sender
{
  _online = !_online;
  [self updateStateButton];
  [self.tableView reloadData];
}

- (IBAction)addRequest:(id)sender
{
  BARequest *request = [[BARequest alloc] initWithName:[NSString stringWithFormat:@"Request %d", requests.count+1]];
  request.delegate = self;
  
  if (_online) {
    [request perform];
  }
  
  [requests addObject:request];
  [self.tableView reloadData];
}

#pragma mark - BARequestDelegate
- (void)BARequestDidFinish:(BARequest *)request
{
  [self.tableView reloadData];
}

#pragma mark - Helpers
- (void)updateStateButton
{
  if (_online) {
    self.stateButton.backgroundColor = [UIColor redColor];
    [self.stateButton setTitle:@"GO OFFLINE" forState:UIControlStateNormal];
  } else {
    self.stateButton.backgroundColor = [UIColor greenColor];
    [self.stateButton setTitle:@"GO ONLINE" forState:UIControlStateNormal];
  }
}

@end
