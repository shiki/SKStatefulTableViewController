//
//  SKLoadErrorViewController.m
//  SKStatefulTableViewControllerDemo
//
//  Created by Shiki on 10/28/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//

#import "SKLoadErrorViewController.h"

@interface SKLoadErrorViewController ()

@end

@implementation SKLoadErrorViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Load Error";
}

- (void)statefulTableViewWillBeginInitialLoad:(SKStatefulTableViewController *)tableView
                                   completion:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    NSError *error = [NSError errorWithDomain:@"domain" code:100 userInfo:@{
      NSLocalizedDescriptionKey: @"The server exploded while loading items."
    }];
    completion(self.items.count == 0, error);
  });
}

- (void)statefulTableViewWillBeginLoadingFromPullToRefresh:(SKStatefulTableViewController *)tableView completion:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    NSError *error = [NSError errorWithDomain:@"domain" code:100 userInfo:@{
      NSLocalizedDescriptionKey: @"Error from pull-to-refresh."
    }];
    completion(self.items.count == 0, error);
  });
}

@end
