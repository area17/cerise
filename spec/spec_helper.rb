# add lib directory to the search path
libdir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
require 'spec'
require 'rake'

# Console redirection helper
require File.expand_path(File.join(File.dirname(__FILE__), 'support/capture_output_helper'))

# Load rake tasks form lib
Dir.glob("#{libdir}/tasks/*.rake").sort.each { |f| load f }

Spec::Runner.configure do |config|
  include CaptureOutputHelper
end
