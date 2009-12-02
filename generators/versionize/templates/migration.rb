<% 
  model = model_name.constantize
  model_name = model_name.downcase # model_name.downcase! - can't modify frozen string
  versions_table = model_name + '_versions'
  columns = model.content_columns.reject { |c| c.type == :datetime }
%>
class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= versions_table %> do |t| 
      <% columns.each do |column| %>
        t.column :<%= column.name %>, :<%= column.type %>
      <% end %>

      t.integer :<%= model_name + '_id' %>
      t.integer :versioned_as
      t.timestamps
    end

    add_index :<%= versions_table %>, :versioned_as
    add_column :<%= model_name.pluralize %>, :current_version, :integer
  end

  def self.down
    drop_table :<%= versions_table %>
    remove_column :<%= model_name.pluralize %>, :current_version
  end
end
