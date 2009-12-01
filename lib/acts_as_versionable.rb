# ActsAsVersionable
module ActsAsVersionable

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def acts_as_versionable(opts = {})
    end

    # generates versions table for specific model
    def create_versions
      model_name = self.to_s.downcase
      migration = ActiveRecord::Migration
      columns = self.content_columns.reject { |c| c.type == :datetime }

      migration.create_table "#{model_name}_versions" do |t|
        columns.each do |column|
          t.column column.name, column.type
        end

        t.integer "#{model_name}_id"
        t.timestamps
      end
    end

    # drops model specific versions table
    def drop_versions
      model_name = self.to_s.downcase
      ActiveRecord::Migration.drop_table "#{model_name}_versions"
    end

  end

  module InstanceMethods
  end

end

ActiveRecord::Base.send(:include, ActsAsVersionable)
