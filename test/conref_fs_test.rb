require 'test_helper'

class DatafilesTest < MiniTest::Test

  def test_it_renders_conrefs_in_frontmatter
    with_site do |site|
      site.compile

      output_file = read_output_file('frontmatter', 'title')
      test_file = read_test_file('frontmatter', 'title')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_conrefs_in_frontmatter_at_different_path
    with_site do |site|
      site.compile

      output_file = read_output_file('frontmatter', 'different')
      test_file = read_test_file('frontmatter', 'different')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_conrefs_in_frontmatter_with_audience
    with_site do |site|
      site.compile

      output_file = read_output_file('frontmatter', 'audience')
      test_file = read_test_file('frontmatter', 'audience')
      assert_equal output_file, test_file
    end
  end

  def test_it_renders_nested_conrefs
    with_site do |site|
      site.compile

      output_file = read_output_file('datafiles', 'deep')
      test_file = read_test_file('datafiles', 'deep')
      assert_equal output_file, test_file
    end
  end

  def test_it_applies_any_attribute
    with_site do |site|
      site.compile

      output_file = read_output_file('attributes', 'attribute')
      test_file = read_test_file('attributes', 'attribute')
      assert_equal output_file, test_file
    end
  end

  def test_it_does_not_obfuscate_content
    with_site do |site|
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
    with_site do |site|
      site.compile
      output_file = read_output_file('datafiles', 'retrieve')
      test_file = read_test_file('datafiles', 'retrieve')
      assert_equal output_file, test_file
    end
  end

  def test_it_ignores_unknown_tags
    with_site do |site|
      site.compile

      output_file = read_output_file('maliciousness', 'unknown')
      test_file = read_test_file('maliciousness', 'unknown')
      assert_equal output_file, test_file
    end
  end

  def test_it_works_if_an_asterisk_is_the_first_character
    with_site do |site|
      site.compile

      output_file = read_output_file('maliciousness', 'asterisk_single')
      test_file = read_test_file('maliciousness', 'asterisk_single')
      assert_equal output_file, test_file
    end
  end

  def test_it_works_if_asterisks_are_the_first_two_characters
    with_site do |site|
      site.compile

      output_file = read_output_file('maliciousness', 'asterisk_double')
      test_file = read_test_file('maliciousness', 'asterisk_double')
      assert_equal output_file, test_file
    end
  end

  def test_raw_tags
    with_site do |site|
      site.compile

      output_file = read_output_file('liquid', 'raw')
      test_file = read_test_file('liquid', 'raw')

      assert_equal output_file, test_file
    end
  end

  def test_multiple_version_blocks
    with_site do |site|
      site.compile

      output_file = read_output_file('liquid', 'multiple_versions')
      test_file = read_test_file('liquid', 'multiple_versions')

      assert_equal output_file, test_file
    end
  end

  def test_multiple_outputs
    with_site do |site|
      site.compile

      single_var_github = read_output_file('multiple', 'single_var')
      assert_match(/Welcome to GitHub/, single_var_github)

      single_var_x = read_output_file('multiple', 'single_var_x')
      assert_match(/Welcome to GitHub X/, single_var_x)
    end
  end
end
