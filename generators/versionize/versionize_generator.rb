class VersionizeGenerator < Rails::Generator::NamedBase
  attr_accessor :model_name

  def initialize(args, opts = {})
    super
    @model_name = args.first
  end

  def manifest
    model_name_for_migration = @model_name.downcase.pluralize
    
    record do |m|
      m.migration_template('migration.rb', 'db/migrate', 
        :assigns => {
          :model_name => @model_name,
          :migration_name => "CreateVersionsFor#{@model_name.pluralize}"
        }, 
        :migration_file_name => "create_versions_for_#{model_name_for_migration}")
    end
  end

protected

  def banner
    "Usage: #{$0} versionize ModelName"
  end

end
