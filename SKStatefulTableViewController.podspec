Pod::Spec.new do |s|
  s.name    = 'SKStatefulTableViewController'
  s.version = '0.1.1'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'http://github.com/shiki/SKStatefulTableViewController'
  s.summary = 'UITableviewController subclass that supports pull-to-refresh, load-more, initial-load, and empty states.'
  s.author = {
    'Shiki' => 'jayson@basanes.net'
  }
  s.source = {
    :git => 'https://github.com/shiki/SKStatefulTableViewController.git',
    :tag => s.version.to_s
  }
  s.platform = :ios, "7.1"
  s.source_files = 'SKStatefulTableViewController/*.{h,m}'
  s.requires_arc = true
end
