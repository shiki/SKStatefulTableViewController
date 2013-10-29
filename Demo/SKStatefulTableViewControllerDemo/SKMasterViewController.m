//
//  SKMasterViewController.m
//  SKStatefulTableViewControllerDemo
//
//  Created by Shiki on 10/27/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//

#import "SKMasterViewController.h"

#import "SKBasicViewController.h"
#import "SKLoadErrorViewController.h"
#import "SKEmptyViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SKMasterViewController () {
  NSMutableArray *_objects;
}
@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SKMasterViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  _objects = [NSMutableArray arrayWithObjects:@"Basic", @"Initial Error", @"Empty", nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

  NSString *object = _objects[(NSUInteger)indexPath.row];
  cell.textLabel.text = object;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UIViewController *vc = nil;
  if (indexPath.row == 1)
    vc = [[SKLoadErrorViewController alloc] init];
  else if (indexPath.row == 2)
    vc = [[SKEmptyViewController alloc] init];
  else
    vc = [[SKBasicViewController alloc] init];

  [self.navigationController pushViewController:vc animated:YES];
}

@end
