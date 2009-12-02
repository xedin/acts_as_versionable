# ActsAsVersionable
module ActsAsVersionable

  class NoSuchVersionError < Exception; end
  
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
  
    def create_class(name, superclass, &block)
      klass = Class.new superclass, &block
      Object.const_set name, klass
    end

    def acts_as_versionable(opts = {})
      has_many :versions, :class_name => "#{self}Version", :dependent => :destroy
      after_save :apply_versioning 

      attr_accessor :local_changes

      class << create_class("#{self}Version", ActiveRecord::Base)
        def actual_columns
          content_columns.reject { |c| c.type == :datetime || c.name == 'versioned_as' }
        end
      end

      include InstanceMethods
    end

  end

  module InstanceMethods

    def version
      current_version || 0
    end

    def revert_to(version)
      revision = versions.find_by_versioned_as(version) 
      
      raise NoSuchVersionError, "Couldn't find #{version} version" if revision.blank?

      versions.actual_columns.each do |column|
        self[column.name] = revision[column.name]  
      end

      self.current_version = version
      self.local_changes = true
      self.save
    end

    private
      
    def apply_versioning
      unless self.local_changes
        version_content = {}
        last_version = version + 1

        versions.actual_columns.each do |column|
          version_content[column.name] = self[column.name]
        end

        version_content.merge!(:versioned_as => last_version)

        if versions.create(version_content)
          self.local_changes = true
          self.update_attribute(:current_version, last_version)
        end
      end

      self.local_changes = false 
    end

  end

end

