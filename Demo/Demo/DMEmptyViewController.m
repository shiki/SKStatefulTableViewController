//
//  DMEmptyViewController
//  SKStatefulTableViewControllerDemo
//
//  Created by Shiki on 10/29/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//

#import "DMEmptyViewController.h"

@interface DMEmptyViewController ()

@property (nonatomic) NSInteger retriesCount;

@end

@implementation DMEmptyViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Empty";
  self.retriesCount = 0;
}

- (void)statefulTableViewControllerWillBeginInitialLoad:(SKStatefulTableViewController *)tvc
                             completion:
                                 (void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  [self loadItemsOrSetEmpty:completion];
}

- (void)statefulTableViewControllerWillBeginLoadingFromPullToRefresh:(SKStatefulTableViewController *)tvc
                                          completion:(void (^)(BOOL tableIsEmpty,
                                                               NSError *errorOrNil))completion {
  [self loadItemsOrSetEmpty:completion];
}

- (void)loadItemsOrSetEmpty:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    self.retriesCount++;

    if (self.retriesCount % 3 != 0) {
      [self.items removeAllObjects];
      [self.tableView reloadData];
      completion(self.items.count == 0, nil);
    } else {
      [self addItems:10 insertFromTop:YES];
      completion(self.items.count == 0, nil);
    }
  });
}

@end