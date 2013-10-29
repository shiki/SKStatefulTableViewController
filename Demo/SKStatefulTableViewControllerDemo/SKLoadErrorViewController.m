//
//  SKLoadErrorViewController.m
//  SKStatefulTableViewControllerDemo
//
//  Created by Shiki on 10/28/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//

#import "SKLoadErrorViewController.h"

@interface SKLoadErrorViewController ()

@property (nonatomic) NSInteger retriesCount;

@end

@implementation SKLoadErrorViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Load Error";
  self.retriesCount = 0;
}

- (void)statefulTableViewWillBeginInitialLoad:(SKStatefulTableViewController *)tableView
                                   completion:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  [self loadItemsOrSendError:completion];
}

- (void)statefulTableViewWillBeginLoadingFromPullToRefresh:(SKStatefulTableViewController *)tableView
                                                completion:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  [self loadItemsOrSendError:completion];
}

- (void)loadItemsOrSendError:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    self.retriesCount++;

    if (self.retriesCount % 2 != 0) {
      NSError *error = [NSError errorWithDomain:@"domain" code:100 userInfo:@{
        NSLocalizedDescriptionKey: @"Error from pull-to-refresh."
      }];
      [self.items removeAllObjects];
      [self.tableView reloadData];
      completion(self.items.count == 0, error);
    } else {
      [self addItems:10 insertFromTop:YES];
      completion(self.items.count == 0, nil);
    }
  });
}

@end
