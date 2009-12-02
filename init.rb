require File.join(File.dirname(__FILE__), 'lib', 'acts_as_versionable')
ActiveRecord::Base.class_eval { include ActsAsVersionable }
