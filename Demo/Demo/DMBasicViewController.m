//
//  DMBasicViewController.m
//  SKStatefulTableViewControllerDemo
//
//  Created by Shiki on 10/27/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//

#import "DMBasicViewController.h"

@implementation DMBasicViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Basic";

  [self triggerInitialLoad];
}

- (void)statefulTableViewWillBeginInitialLoad:(SKStatefulTableViewController *)tableView
                                   completion:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self addItems:10 insertFromTop:NO];
    completion(self.items.count == 0, nil);
  });
}

- (void)statefulTableViewWillBeginLoadingFromPullToRefresh:(SKStatefulTableViewController *)tableView
                                                completion:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self addItems:5 insertFromTop:YES];
    completion(self.items.count == 0, nil);
  });
}

- (void)statefulTableViewWillBeginLoadingMore:(SKStatefulTableViewController *)tableView
                                   completion:(void (^)(BOOL canLoadMore, NSError *errorOrNil, BOOL showErrorView))completion {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self addItems:10 insertFromTop:NO];
    completion(self.items.count < 100, nil, NO);
  });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noreuse"];
  cell.textLabel.text = self.items[(NSUInteger)indexPath.row];
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.items.count;
}

- (void)addItems:(NSInteger)count insertFromTop:(BOOL)insertFromTop {
  if (!_items) {
    _items = [[NSMutableArray alloc] init];
  }

  NSMutableArray *indexPaths = [NSMutableArray array];
  NSMutableArray *addedItems = [NSMutableArray array];
  for (int i = 0; i < count; i++) {
    NSString *item = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                    dateStyle:NSDateFormatterShortStyle
                                                    timeStyle:NSDateFormatterShortStyle];
    item = [NSString stringWithFormat:@"#%i %@", _items.count, item];

    if (insertFromTop)
      [_items insertObject:item atIndex:0];
    else
      [_items addObject:item];

    [addedItems addObject:item];
  }

  for (NSString *item in addedItems) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_items indexOfObject:item] inSection:0];
    [indexPaths addObject:indexPath];
  }

  [self.tableView insertRowsAtIndexPaths:indexPaths
                        withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
