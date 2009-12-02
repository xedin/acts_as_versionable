module ActsAsVersionable
  module Migrations
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

end

