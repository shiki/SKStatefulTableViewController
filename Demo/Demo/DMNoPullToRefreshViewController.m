//
//  DMNoPullToRefreshViewController
//  SKStatefulTableViewControllerDemo
//
//  Created by Shiki on 11/4/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//


#import "DMNoPullToRefreshViewController.h"

@implementation DMNoPullToRefreshViewController

- (void)onInit {
  [super onInit];
  self.canPullToRefresh = NO;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"No Pull To Refresh";
}

@end