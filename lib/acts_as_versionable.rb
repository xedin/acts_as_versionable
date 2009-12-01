# ActsAsVersionable
module ActsAsVersionable

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

    # generates versions table for specific model
    def create_versions
      model_name = self.to_s.downcase
      versions_table = model_name + '_versions'
      migration = ActiveRecord::Migration
      columns = self.content_columns.reject { |c| c.type == :datetime }

      migration.create_table versions_table do |t|
        columns.each do |column|
          t.column column.name, column.type
        end

        t.integer "#{model_name}_id"
        t.integer :versioned_as
        t.timestamps
      end
    
      migration.add_index versions_table, :versioned_as
      migration.add_column model_name.pluralize, :current_version, :integer
    end

    # drops model specific versions table
    def drop_versions
      model_name = self.to_s.downcase
      migration = ActiveRecord::Migration
      
      migration.drop_table "#{model_name}_versions"
      migration.remove_column model_name.pluralize, :current_version
    end

  end

  module InstanceMethods
    def version
      current_version
    end

    def revert_to(version)
      revision = versions.find_by_versioned_as(version) 
      
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

ActiveRecord::Base.send(:include, ActsAsVersionable)
