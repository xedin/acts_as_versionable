require 'rubygems'
gem 'activerecord'
require 'active_record'
require 'test/unit'
require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :articles do |t|
      t.string :title
      t.text   :body

      t.integer :user_id
      t.integer :current_version
      t.timestamps
    end

    create_table :article_versions do |t|
      t.string  :title
      t.text    :body
      t.integer :article_id
      t.integer :versioned_as
      t.timestamps
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Article < ActiveRecord::Base
  acts_as_versionable
end

class VersionableTest < Test::Unit::TestCase
  def setup
    setup_db

    (1..3).each { |c| 
      Article.create!(:title => c.to_s, :body => c.to_s)
    }
  end

  def teardown
    teardown_db
  end

  def test_if_mixed_methods_present
    article = Article.first
    [:versions, :version, :revert_to].each do |method|
      assert_equal true, article.respond_to?(method) 
    end
  end

  def test_initial_versions_of_the_articles
    Article.all.each do |a|
      assert_equal 1, a.versions.size
      assert_equal 1, a.version
    end
  end

  def test_version_change_to_2
    article = Article.first

    assert_not_nil article
    assert_equal '1', article.title
    assert_equal 1, article.version

    article.update_attributes(:title => '4', :body => '4')
    
    assert_equal 2, article.version
    assert_equal 2, article.versions.size
    assert_equal '4', article.title
    assert_equal '4', article.body
  end

  def test_revert_to
    article = Article.first
    assert_not_nil article

    article.update_attributes(:title => '4', :body => '4')
    assert_equal 2, article.versions.size
    
    article.revert_to(1)
    assert_equal 1, article.version
    assert_equal '1', article.title
    assert_equal '1', article.body

    article.revert_to(2)
    assert_equal 2, article.version
    assert_equal '4', article.title 
    assert_equal '4', article.body
  
    assert_raise ActsAsVersionable::NoSuchVersionError do
      article.revert_to(3)
    end
  end

  def test_dependent_destroy
    Article.destroy_all
    assert_equal [], ArticleVersion.all
  end
end

