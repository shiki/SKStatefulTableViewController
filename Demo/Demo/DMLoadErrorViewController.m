//
//  DMLoadErrorViewController.m
//  SKStatefulTableViewControllerDemo
//
//  Created by Shiki on 10/28/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//

#import "DMLoadErrorViewController.h"

@interface DMLoadErrorViewController ()

@property (nonatomic) NSInteger retriesCount;

@end

@implementation DMLoadErrorViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Load Error";
  self.retriesCount = 0;
}

- (void)statefulTableViewWillBeginInitialLoad:(SKStatefulTableViewController *)tableView
                                   completion:(void (^)(BOOL tableIsEmpty,
                                                        NSError *errorOrNil))completion {
  [self loadItemsOrSendError:completion messageIfError:@"Error on initial load."];
}

- (void)statefulTableViewWillBeginLoadingFromPullToRefresh:
            (SKStatefulTableViewController *)
                tableView completion:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion {
  [self loadItemsOrSendError:completion messageIfError:@"Error from pull-to-refresh."];
}

- (void)loadItemsOrSendError:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion
              messageIfError:(NSString *)message {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    self.retriesCount++;

    if (self.retriesCount % 2 != 0) {
      NSError *error = [NSError errorWithDomain:@"domain"
                                           code:100
                                       userInfo:@{NSLocalizedDescriptionKey: message}];
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
