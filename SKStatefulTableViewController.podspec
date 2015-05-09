Pod::Spec.new do |s|
  s.name    = 'SKStatefulTableViewController'
  s.version = '0.0.12'
  s.summary = ''
  s.author = {
    'Shiki' => 'jayson@basanes.net'
  }
  s.source = {
    :git => 'https://github.com/shiki/SKStatefulTableViewController.git',
    :tag => '0.0.12'
  }
  s.platform = :ios, "7.1"
  s.source_files = 'SKStatefulTableViewController/*.{h,m}'
  s.requires_arc = true
end
