//
//  SKNoPullToRefreshViewController
//  SKStatefulTableViewControllerDemo
//
//  Created by Shiki on 11/4/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//


#import "SKNoPullToRefreshViewController.h"

@implementation SKNoPullToRefreshViewController

- (void)onInit {
  [super onInit];
  self.canPullToRefresh = NO;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"No Pull To Refresh";
}

@end