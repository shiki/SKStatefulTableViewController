# SKStatefulTableViewController

SKStatefulTableViewController is a `UITableViewController` subclass that supports these states:

  State | Description
  ------|-----------------------------------------
  `SKStatefulTVCStateLoadingFromPullToRefresh` | the standard pull to refresh functionality you see in most apps
  `SKStatefulTVCStateLoadingMore`              | shows a "loading" view when the user scrolls to the bottom 
  `SKStatefulTVCStateInitialLoading`           | shows a static view when showing the controller for the first time (e.g. a big-ass spinner icon) 
  `SKStatefulTVCStateInitialLoadingTableView`  | shows the tableView instead of a static view when the controller is shown for the first time 
  `SKStatefulTVCStateEmptyOrInitialLoadError`  | shows a static view that indicates whether the initial load failed or there are no data to show 

The states can be disabled depending on your needs. The views used by the states can also be customized.

## Installation

Add this to your project using [Cocoapods](https://cocoapods.org).

    pod "SKStatefulTableViewController", "~> 0.1"

## Customizing the state views

_Work in progress_. Please see the Demo project on how to do this for now.


