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
  cell.textLabel.text = @"Request";
  
  return cell;
}

#pragma mark - IBActions
- (IBAction)switchState:(id)sender
{
  _online = !_online;
  [self updateStateButton];
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
