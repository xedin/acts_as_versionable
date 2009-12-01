puts "
=================
Use instructions:
=================

  in your model:

  class Article < ActiveRecord::Base
    acts_as_versionable
  end

  create migration:
  
  class CreateVersioningForArticles < ActiveRecord::Migration
    def self.up
      Article.create_versions
    end

    def self.down
      Article.drop_versions
    end
  end
---
Run `rake db:migrate` and enjoy!
"
