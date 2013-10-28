//
//  SKBasicViewController.m
//  SKStatefulTableViewControllerDemo
//
//  Created by Shiki on 10/27/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//

#import "SKBasicViewController.h"

@interface SKBasicViewController () {
  NSMutableArray *_items;
}

@end

@implementation SKBasicViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Basic";

  [self triggerInitialLoad];
}

- (void)statefulTableViewWillBeginInitialLoad:(SKStatefulTableViewController *)tableView
                                   completion:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self insertNewItem:10 fromTop:NO];
    completion(NO, nil);
  });
}

- (void)statefulTableViewWillBeginLoadingFromPullToRefresh:(SKStatefulTableViewController *)tableView completion:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self insertNewItem:5 fromTop:YES];
    completion(NO, nil);
  });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noreuse"];
  cell.textLabel.text = _items[(NSUInteger)indexPath.row];
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _items.count;
}

- (void)insertNewItem:(NSInteger)count fromTop:(BOOL)fromTop {
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

    if (fromTop)
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
