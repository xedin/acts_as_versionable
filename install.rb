puts "
=================
Use instructions:
=================

  In your model:

  class Article < ActiveRecord::Base
    acts_as_versionable
  end

  Then `script/generate versionize Article` and enjoy!
"
