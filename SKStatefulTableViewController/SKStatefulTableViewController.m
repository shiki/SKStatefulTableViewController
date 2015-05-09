//
//  SKStatefulTableViewController
//  SKStatefulTableViewController
//
//  Created by Shiki on 10/24/13.
//  Copyright (c) 2013 Shiki. All rights reserved.
//

#import "SKStatefulTableViewController.h"

typedef enum {
  SKStatefulTableViewControllerViewModeStatic = 1,
  SKStatefulTableViewControllerViewModeTable,
} SKStatefulTableViewControllerViewMode;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SKStatefulTableViewController ()

@property (readwrite, strong, nonatomic) UIView *staticContainerView;

@property (nonatomic) BOOL watchForLoadMore;
@property (nonatomic) BOOL loadMoreViewIsErrorView;

/**
 Used for restoring the original separator style when it's set to "none" if the
 static container view is shown.
 */
@property (nonatomic) UITableViewCellSeparatorStyle lastSeparatorStyle;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SKStatefulTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    [self onInit];
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    [self onInit];
  }
  return self;
}

- (void)onInit {
  self.statefulDelegate = self;
  self.loadMoreTriggerThreshold = 64.f;
  self.canLoadMore = YES;
  self.canPullToRefresh = YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.lastSeparatorStyle = self.tableView.separatorStyle;

  // Initialize pull to refresh control
  if (self.canPullToRefresh) {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refreshControlValueChanged:)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
  }

  UIView *staticContentView = [[UIView alloc] initWithFrame:self.tableView.bounds];
  staticContentView.hidden = YES;
  staticContentView.backgroundColor = [UIColor whiteColor];
  staticContentView.autoresizingMask =
      UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |
      UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
  [self.tableView addSubview:staticContentView];
  self.staticContainerView = staticContentView;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)setStatefulState:(SKStatefulTableViewControllerState)state {
  [self setStatefulState:state updateViewMode:YES error:nil];
}

- (void)setStatefulState:(SKStatefulTableViewControllerState)state withError:(NSError *)error {
  [self setStatefulState:state updateViewMode:YES error:error];
}

- (void)setStatefulState:(SKStatefulTableViewControllerState)state
          updateViewMode:(BOOL)updateViewMode
                   error:(NSError *)error {
  _statefulState = state;

  if (state == SKStatefulTableViewControllerStateInitialLoading) {
    UIView *initialLoadView = [self viewForInitialLoad];
    [self resetStaticContentViewWithChildView:initialLoadView];
  } else if (state == SKStatefulTableViewControllerStateEmptyOrInitialLoadError) {
    UIView *view = [self viewForEmptyInitialLoadWithError:error];
    [self resetStaticContentViewWithChildView:view];
  }

  if (state == SKStatefulTableViewControllerStateIdle) {
    [self setWatchForLoadMoreIfApplicable:YES];
  } else if (state == SKStatefulTableViewControllerStateEmptyOrInitialLoadError) {
    [self setWatchForLoadMoreIfApplicable:NO];
  }

  if (updateViewMode) {
    SKStatefulTableViewControllerViewMode viewMode;
    switch (state) {
    case SKStatefulTableViewControllerStateInitialLoading:
    case SKStatefulTableViewControllerStateEmptyOrInitialLoadError:
      viewMode = SKStatefulTableViewControllerViewModeStatic;
      break;
    case SKStatefulTableViewControllerStateInitialLoadingTableView:
    default:
      viewMode = SKStatefulTableViewControllerViewModeTable;
      break;
    }

    [self setViewMode:viewMode];
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initial Load

- (BOOL)triggerInitialLoad {
  return [self triggerInitialLoadShowingTableView:NO];
}

- (BOOL)triggerInitialLoadShowingTableView:(BOOL)showTableView {
  if ([self stateIsLoading])
    return NO;

  if (showTableView)
    [self setStatefulState:SKStatefulTableViewControllerStateInitialLoadingTableView];
  else
    [self setStatefulState:SKStatefulTableViewControllerStateInitialLoading];

  __weak typeof(self) wSelf = self;
  if ([self.statefulDelegate
          respondsToSelector:@selector(statefulTableViewControllerWillBeginInitialLoad:completion:)]) {
    [self.statefulDelegate
        statefulTableViewControllerWillBeginInitialLoad:self
                             completion:^(BOOL tableIsEmpty, NSError *errorOrNil) {
                               [wSelf setHasFinishedInitialLoad:tableIsEmpty withError:errorOrNil];
                             }];
  }

  return YES;
}

- (void)setHasFinishedInitialLoad:(BOOL)tableIsEmpty withError:(NSError *)errorOrNil {
  if (self.statefulState != SKStatefulTableViewControllerStateInitialLoading &&
      self.statefulState != SKStatefulTableViewControllerStateInitialLoadingTableView) {
    return;
  }

  // We will only show the error page if the table is empty or there is an error and the table is
  // empty.
  if (tableIsEmpty) {
    [self setStatefulState:SKStatefulTableViewControllerStateEmptyOrInitialLoadError
            updateViewMode:YES
                     error:errorOrNil];
  } else {
    [self setStatefulState:SKStatefulTableViewControllerStateIdle];
  }
}

- (UIView *)viewForInitialLoad {
  if ([self.statefulDelegate respondsToSelector:@selector(statefulTableViewControllerViewForInitialLoad:)]) {
    return [self.statefulDelegate statefulTableViewControllerViewForInitialLoad:self];
  } else {
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.frame = ({
      CGRect f = activityIndicatorView.frame;
      f.origin.x = self.staticContainerView.frame.size.width * 0.5f - f.size.width * 0.5f;
      f.origin.y = self.staticContainerView.frame.size.height * 0.5f - f.size.height * 0.5f;
      f;
    });
    [activityIndicatorView startAnimating];
    return activityIndicatorView;
  }
}

- (UIView *)viewForEmptyInitialLoadWithError:(NSError *)errorOrNil {
  if ([self.statefulDelegate
          respondsToSelector:@selector(statefulTableViewController:viewForEmptyInitialLoadWithError:)]) {
    return [self.statefulDelegate statefulTableViewController:self viewForEmptyInitialLoadWithError:errorOrNil];
  } else {
    UIView *container =
        [[UIView alloc] initWithFrame:({
                          CGRect f = CGRectMake(0.f, 0.f,
                                                self.staticContainerView.bounds.size.width, 120.f);
                          f.origin.y = self.staticContainerView.bounds.size.height * 0.5f -
                                       f.size.height * 0.5f;
                          f;
                        })];

    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = errorOrNil ? errorOrNil.localizedDescription : @"No records found.";
    [label sizeToFit];
    label.frame = ({
      CGRect f = label.frame;
      f.origin.x = container.bounds.size.width * 0.5f - label.bounds.size.width * 0.5f;
      f;
    });

    [container addSubview:label];
    if (errorOrNil) {
      UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      [button setTitle:@"Try Again" forState:UIControlStateNormal];
      [button addTarget:self
                    action:@selector(triggerInitialLoad)
          forControlEvents:UIControlEventTouchUpInside];
      button.frame = ({
        CGRect f = CGRectMake(0.f, 0.f, 130.f, 32.f);
        f.origin.x = container.bounds.size.width * 0.5f - f.size.width * 0.5f;
        f.origin.y = label.frame.origin.y + label.frame.size.height + 10.f;
        f;
      });
      [container addSubview:button];
    }

    return container;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Pull To Refresh

- (void)refreshControlValueChanged:(id)sender {
  if (self.statefulState != SKStatefulTableViewControllerStateLoadingFromPullToRefresh &&
      !self.stateIsInitialLoading) {
    if (![self triggerPullToRefresh]) {
      [self.refreshControl endRefreshing];
    }
  }
}

- (BOOL)triggerPullToRefresh {
  if ([self stateIsLoading])
    return NO;

  // We don't want to change the view mode since pulling may come from the static view mode as well.
  [self setStatefulState:SKStatefulTableViewControllerStateLoadingFromPullToRefresh
          updateViewMode:NO
                   error:nil];

  __weak typeof(self) wSelf = self;
  if ([self.statefulDelegate
          respondsToSelector:@selector(statefulTableViewControllerWillBeginLoadingFromPullToRefresh:completion:)]) {
    [self.statefulDelegate statefulTableViewControllerWillBeginLoadingFromPullToRefresh:
                               self completion:^(BOOL tableIsEmpty, NSError *errorOrNil) {
      [wSelf setHasFinishedLoadingFromPullToRefresh:tableIsEmpty withError:errorOrNil];
    }];
  }

  [self.refreshControl beginRefreshing];
  return YES;
}

- (void)setHasFinishedLoadingFromPullToRefresh:(BOOL)tableIsEmpty withError:(NSError *)errorOrNil {
  if (self.statefulState != SKStatefulTableViewControllerStateLoadingFromPullToRefresh)
    return;

  [self.refreshControl endRefreshing];

  // We will only show the error page if the table is empty or there is an error and the table is
  // empty.
  if (tableIsEmpty) {
    [self setStatefulState:SKStatefulTableViewControllerStateEmptyOrInitialLoadError
            updateViewMode:YES
                     error:errorOrNil];
  } else {
    [self setStatefulState:SKStatefulTableViewControllerStateIdle];
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Load More

- (void)triggerLoadMore {
  if ([self stateIsLoading])
    return;

  self.loadMoreViewIsErrorView = NO;
  self.lastLoadMoreError = nil;
  [self updateLoadMoreView];

  [self setStatefulState:SKStatefulTableViewControllerStateLoadingMore];

  __weak typeof(self) wSelf = self;
  if ([self.statefulDelegate
          respondsToSelector:@selector(statefulTableViewControllerWillBeginLoadingMore:completion:)]) {
    [self.statefulDelegate statefulTableViewControllerWillBeginLoadingMore:self
                                                completion:^(BOOL canLoadMore, NSError *errorOrNil,
                                                             BOOL showErrorView) {

                                                  [wSelf setHasFinishedLoadingMore:canLoadMore
                                                                         withError:errorOrNil
                                                                     showErrorView:showErrorView];
                                                }];
  }
}

- (void)setWatchForLoadMoreIfApplicable:(BOOL)watch {
  // We will only watch if -canLoadMore is enabled
  if (watch && !self.canLoadMore)
    watch = NO;

  self.watchForLoadMore = watch;
  [self updateLoadMoreView];
  [self triggerLoadMoreIfApplicable:self.tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self triggerLoadMoreIfApplicable:scrollView];
}

- (void)triggerLoadMoreIfApplicable:(UIScrollView *)scrollView {
  if (self.watchForLoadMore && !self.loadMoreViewIsErrorView) {
    CGFloat scrollPosition =
        scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
    if (scrollPosition < self.loadMoreTriggerThreshold) {
      [self triggerLoadMore];
    }
  }
}

- (void)setHasFinishedLoadingMore:(BOOL)canLoadMore
                        withError:(NSError *)errorOrNil
                    showErrorView:(BOOL)showErrorView {
  if (self.statefulState != SKStatefulTableViewControllerStateLoadingMore)
    return;

  self.canLoadMore = canLoadMore;
  self.loadMoreViewIsErrorView = errorOrNil && showErrorView;
  self.lastLoadMoreError = errorOrNil;

  [self setStatefulState:SKStatefulTableViewControllerStateIdle];
}

- (void)updateLoadMoreView {
  if (self.watchForLoadMore) {
    UIView *loadMoreView = [self
        viewForLoadingMoreWithError:self.loadMoreViewIsErrorView ? self.lastLoadMoreError : nil];
    self.tableView.tableFooterView = loadMoreView;
  } else {
    self.tableView.tableFooterView = [[UIView alloc] init];
  }
}

- (UIView *)viewForLoadingMoreWithError:(NSError *)error {
  if ([self.statefulDelegate respondsToSelector:@selector(statefulTableViewController:viewForLoadMoreWithError:)]) {
    return [self.statefulDelegate statefulTableViewController:self viewForLoadMoreWithError:error];
  } else {
    UIView *container =
        [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.bounds.size.width, 44.f)];
    if (error) {
      UILabel *label = [[UILabel alloc] init];
      label.text = error.localizedDescription;
      label.font = [label.font fontWithSize:12.f];
      label.frame = ({
        CGRect f = label.frame;
        f.size.height = container.bounds.size.height;
        f.origin.x = 10.f;
        f.size.width = container.bounds.size.width - 140.f;
        f;
      });
      [container addSubview:label];

      UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      [button setTitle:@"Try Again" forState:UIControlStateNormal];
      [button addTarget:self
                    action:@selector(triggerLoadMore)
          forControlEvents:UIControlEventTouchUpInside];
      button.frame = ({
        CGRect f = CGRectMake(0.f, 0.f, 130.f, container.bounds.size.height);
        f.origin.x = container.bounds.size.width - f.size.width - 5.f;
        f.origin.y = 0.f;
        f;
      });
      [container addSubview:button];
    } else {
      UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]
          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      activityIndicatorView.frame = ({
        CGRect f = activityIndicatorView.frame;
        f.origin.x = container.frame.size.width * 0.5f - f.size.width * 0.5f;
        f.origin.y = container.frame.size.height * 0.5f - f.size.height * 0.5f;
        f;
      });
      [activityIndicatorView startAnimating];
      [container addSubview:activityIndicatorView];
    }
    return container;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utils

- (void)updateIdleOrEmptyOrInitialLoadState:(BOOL)tableIsEmpty withError:(NSError *)errorOrNil {
  if (self.statefulState != SKStatefulTableViewControllerStateIdle &&
      self.statefulState != SKStatefulTableViewControllerStateEmptyOrInitialLoadError) {
    return;
  }

  // We will only show the error page if the table is empty or there is an error and the table is
  // empty.
  if (tableIsEmpty) {
    [self setStatefulState:SKStatefulTableViewControllerStateEmptyOrInitialLoadError
            updateViewMode:YES
                     error:errorOrNil];
  } else {
    [self setStatefulState:SKStatefulTableViewControllerStateIdle];
  }
}
- (void)setViewMode:(SKStatefulTableViewControllerViewMode)mode {
  BOOL hidden = mode == SKStatefulTableViewControllerViewModeTable;
  if (self.staticContainerView.hidden != hidden) {
    self.staticContainerView.hidden = hidden;

    if (self.staticContainerView.hidden) {
      self.tableView.separatorStyle = self.lastSeparatorStyle;
    } else {
      self.lastSeparatorStyle = self.tableView.separatorStyle;
      self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
  }
}

- (void)resetStaticContentViewWithChildView:(UIView *)childView {
  [self.staticContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.staticContainerView addSubview:childView];
}

- (BOOL)stateIsLoading {
  return self.statefulState == SKStatefulTableViewControllerStateInitialLoading ||
         self.statefulState == SKStatefulTableViewControllerStateInitialLoadingTableView ||
         self.statefulState == SKStatefulTableViewControllerStateLoadingFromPullToRefresh ||
         self.statefulState == SKStatefulTableViewControllerStateLoadingMore;
}

- (BOOL)stateIsInitialLoading {
  return self.statefulState == SKStatefulTableViewControllerStateInitialLoading ||
         self.statefulState == SKStatefulTableViewControllerStateInitialLoadingTableView;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return nil;
}

@end