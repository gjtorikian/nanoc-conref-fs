require 'test_helper'

class DatafilesTest < MiniTest::Test

  def test_it_renders_conrefs_in_frontmatter
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('frontmatter', 'title')
      test_file = read_test_file('frontmatter', 'title')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_conrefs_in_frontmatter_at_different_path
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('frontmatter', 'different')
      test_file = read_test_file('frontmatter', 'different')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_conrefs_in_frontmatter_with_audience
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('frontmatter', 'audience')
      test_file = read_test_file('frontmatter', 'audience')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_nested_conrefs
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('datafiles', 'deep')
      test_file = read_test_file('datafiles', 'deep')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_nested_conrefs
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('datafiles', 'deep')
      test_file = read_test_file('datafiles', 'deep')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_single_parents
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('parents', 'single_parent')
      test_file = read_test_file('parents', 'single_parent')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_two_parents
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('parents', 'two_parents')
      test_file = read_test_file('parents', 'two_parents')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_array_parents
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('parents', 'array_parents')
      test_file = read_test_file('parents', 'array_parents')
      assert_equal output_file, test_file
    end
  end

  def test_missing_category_title_does_not_blow_up_parents
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('parents', 'missing_title')
      test_file = read_test_file('parents', 'missing_title')
      assert_equal output_file, test_file
    end
  end

  def test_it_applies_any_attribute
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('attributes', 'attribute')
      test_file = read_test_file('attributes', 'attribute')
      assert_equal output_file, test_file
    end
  end

  def test_it_obfuscates_content
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('obfuscation', 'admonitions')
      test_file = read_test_file('obfuscation', 'admonitions')
      assert_equal output_file, test_file

      output_file = read_output_file('obfuscation', 'octicon')
      test_file = read_test_file('obfuscation', 'octicon')
      assert_equal output_file, test_file
    end
  end

  def test_it_fetches_variables
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile
      output_file = read_output_file('datafiles', 'retrieve')
      test_file = read_test_file('datafiles', 'retrieve')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_hash_children
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('children', 'hash_children')
      test_file = read_test_file('children', 'hash_children')
      assert_equal output_file, test_file

      output_file = read_output_file('children', 'later_hash_children')
      test_file = read_test_file('children', 'later_hash_children')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_array_children
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('children', 'array_children')
      test_file = read_test_file('children', 'array_children')
      assert_equal output_file, test_file
    end
  end

  def test_it_ignores_unknown_tags
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      output_file = read_output_file('maliciousness', 'unknown')
      test_file = read_test_file('maliciousness', 'unknown')
      assert_equal output_file, test_file
    end
  end
end
