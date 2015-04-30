//
//  DMLoadMoreErrorViewController
//  SKStatefulTableViewControllerDemo
//
//  Created by Shiki on 10/29/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//

#import "DMLoadMoreErrorViewController.h"

@interface DMLoadMoreErrorViewController ()

@property (nonatomic) NSInteger retriesCount;

@end

@implementation DMLoadMoreErrorViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Load More Error";

  self.retriesCount = 0;
}

- (void)statefulTVCWillBeginLoadingMore:(SKStatefulTVC *)tvc
                             completion:(void (^)(BOOL canLoadMore, NSError *errorOrNil,
                                                  BOOL showErrorView))completion {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    self.retriesCount++;

    NSError *error = nil;
    if (self.retriesCount % 3 == 0 || self.retriesCount == 1) {
      error = [NSError errorWithDomain:@"domain"
                                  code:100
                              userInfo:(@{
                                NSLocalizedDescriptionKey: @"Failed loading more items"
                              })];
      completion(YES, error, YES);
    } else {
      [self addItems:10 insertFromTop:NO];
      completion(self.items.count < 100, nil, NO);
    }
  });
}
@end