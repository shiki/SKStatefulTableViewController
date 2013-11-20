//
//  SKStatefulTableViewController
//  SKStatefulTableViewController
//
//  Created by Shiki on 10/24/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef enum {
  SKStatefulTableViewControllerStateIdle = 0,
  SKStatefulTableViewControllerStateInitialLoading,
  SKStatefulTableViewControllerStateEmptyOrInitialLoadError,
  SKStatefulTableViewControllerStateLoadingFromPullToRefresh,
  SKStatefulTableViewControllerStateLoadingMore
} SKStatefulTableViewControllerState;

@class SKStatefulTableViewController;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol SKStatefulTableViewControllerDelegate <NSObject>

@optional

- (void)statefulTableViewWillBeginInitialLoad:(SKStatefulTableViewController *)tableView
                                   completion:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion;
- (void)statefulTableViewWillBeginLoadingFromPullToRefresh:(SKStatefulTableViewController *)tableView
                                                completion:(void (^)(BOOL tableIsEmpty, NSError *errorOrNil))completion;
- (void)statefulTableViewWillBeginLoadingMore:(SKStatefulTableViewController *)tableView
                                   completion:(void (^)(BOOL canLoadMore, NSError *errorOrNil, BOOL showErrorView))completion;

- (UIView *)statefulTableViewViewForInitialLoad:(SKStatefulTableViewController *)tableView;
// TODO rename since this is reused for pull to refresh as well
- (UIView *)statefulTableView:(SKStatefulTableViewController *)tableView viewForEmptyInitialLoadWithError:(NSError *)errorOrNil;
- (UIView *)statefulTableView:(SKStatefulTableViewController *)tableView viewForLoadMoreWithError:(NSError *)errorOrNil;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SKStatefulTableViewController : UIViewController <SKStatefulTableViewControllerDelegate,
  UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) id<SKStatefulTableViewControllerDelegate> statefulDelegate;

@property (readonly, strong, nonatomic) UITableView *tableView;
@property (readonly, strong, nonatomic) UIView *staticContainerView;

@property (nonatomic) SKStatefulTableViewControllerState statefulState;

// Enable/disable pull-to-refresh. This will only work if this is set before -viewDidLoad gets
// launched.
@property (nonatomic) BOOL canPullToRefresh;
@property (strong, readonly, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) CGFloat loadMoreTriggerThreshold;
@property (nonatomic) BOOL canLoadMore;
@property (strong, nonatomic) NSError *lastLoadMoreError;

- (void)onInit;

- (void)setStatefulState:(SKStatefulTableViewControllerState)state withError:(NSError *)error;

- (BOOL)triggerInitialLoad;
- (void)setHasFinishedInitialLoad:(BOOL)tableIsEmpty withError:(NSError *)errorOrNil;
- (BOOL)triggerPullToRefresh;
- (void)setHasFinishedLoadingFromPullToRefresh:(BOOL)tableIsEmpty withError:(NSError *)errorOrNil;
- (void)triggerLoadMore;
- (void)setHasFinishedLoadingMore:(BOOL)canLoadMore withError:(NSError *)errorOrNil showErrorView:(BOOL)showErrorView;

@end