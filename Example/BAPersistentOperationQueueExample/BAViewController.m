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
  BAPersistentOperationQueue *offlineQueue;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [paths objectAtIndex:0];
  NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"Requests.db"];
  
  offlineQueue = [[BAPersistentOperationQueue alloc] initWithDatabasePath:dbPath];
  offlineQueue.delegate = self;
  
  _online = YES;
  // We start online, so start the queue immediately
  [offlineQueue startWorking];
  
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

#pragma mark - BAPersistentOperationQueueDelegate

- (NSDictionary *)persistentOperationQueueSerializeObject:(id)object {
  // Serialize our request into an NSDictionary data structure
  BARequest *request = (BARequest *)object;
  NSDictionary *data = @{@"name": request.name};
  return data;
}

- (void)persistentOperationQueueReceivedOperation:(BAPersistentOperation *)operation
{
  // Transform the operation back into a request if it's not already in the table.
  // operation.data holds the previously serialized data structure
  BARequest *request;
  
  for (BARequest *req in requests) {
    if ([req.name isEqualToString:operation.data[@"name"]]) {
      request = req;
    }
  }
  
  if (request == nil) {
    request = [[BARequest alloc] initWithName:operation.data[@"name"]];
    request.delegate = self;
    [requests addObject:request];
  }
  
  [request performWithBlock:^{
    [operation finish];
  }];
  
  [self.tableView reloadData];
}

#pragma mark - IBActions
- (IBAction)switchState:(id)sender
{
  _online = !_online;
  [self updateStateButton];
  [self.tableView reloadData];
  
  if (_online) {
    [offlineQueue startWorking];
  } else {
    [offlineQueue stopWorking];
  }
}

- (IBAction)addRequest:(id)sender
{
  BARequest *request = [[BARequest alloc] initWithName:[NSString stringWithFormat:@"Request %d", requests.count+1]];
  request.delegate = self;
  
  if (_online) {
    [request performWithBlock:nil];
  } else {
    // Add to our persistent queue
    [offlineQueue insertObject:request];
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
