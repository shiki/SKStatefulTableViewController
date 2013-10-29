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
                                   completion:(void (^)(BOOL canLoadMore, NSError *errorOrNil))completion;

- (UIView *)statefulTableViewViewForInitialLoad:(SKStatefulTableViewController *)tableView;
// TODO rename since this is reused for pull to refresh as well
- (UIView *)statefulTableView:(SKStatefulTableViewController *)tableView viewForEmptyInitialLoadWithError:(NSError *)errorOrNil;
- (UIView *)statefulTableView:(SKStatefulTableViewController *)tableView viewForLoadMoreWithError:(NSError *)errorOrNil;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SKStatefulTableViewController : UIViewController <SKStatefulTableViewControllerDelegate,
  UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) id<SKStatefulTableViewControllerDelegate> delegate;

@property (readonly, strong, nonatomic) UITableView *tableView;
@property (readonly, strong, nonatomic) UIView *staticContainerView;

@property (nonatomic) SKStatefulTableViewControllerState state;

@property (nonatomic) CGFloat loadMoreTriggerThreshold;

- (void)triggerInitialLoad;
- (void)setHasFinishedInitialLoad:(BOOL)tableIsEmpty withError:(NSError *)errorOrNil;
- (void)triggerPullToRefresh;
- (void)setHasFinishedLoadingFromPullToRefresh:(BOOL)tableIsEmpty withError:(NSError *)errorOrNil;
- (void)triggerLoadMore;
- (void)setHasFinishedLoadingMore:(BOOL)canLoadMore withError:(NSError *)errorOrNil;

@end