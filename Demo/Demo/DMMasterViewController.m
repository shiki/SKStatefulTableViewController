//
//  DMMasterViewController.m
//  SKStatefulTableViewControllerDemo
//
//  Created by Shiki on 10/27/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//

#import "DMMasterViewController.h"

#import "DMBasicViewController.h"
#import "DMLoadErrorViewController.h"
#import "DMEmptyViewController.h"
#import "DMLoadMoreErrorViewController.h"
#import "DMNoPullToRefreshViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface DMMasterViewController ()

@property (strong, nonatomic) NSMutableArray *objects;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation DMMasterViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.objects = [NSMutableArray arrayWithObjects:@"Basic", @"Initial Error", @"Empty",
                                                  @"Load More Error", @"No Pull To Refresh", nil];

  self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
  [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Cell"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

  NSString *object = self.objects[(NSUInteger)indexPath.row];
  cell.textLabel.text = object;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UIViewController *vc = nil;
  if (indexPath.row == 1)
    vc = [[DMLoadErrorViewController alloc] init];
  else if (indexPath.row == 2)
    vc = [[DMEmptyViewController alloc] init];
  else if (indexPath.row == 3)
    vc = [[DMLoadMoreErrorViewController alloc] init];
  else if (indexPath.row == 4)
    vc = [[DMNoPullToRefreshViewController alloc] init];
  else
    vc = [[DMBasicViewController alloc] init];

  [self.navigationController pushViewController:vc animated:YES];
}

@end
