require 'test_helper'

class AncestryTest < MiniTest::Test
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
end
