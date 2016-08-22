require 'test_helper'

class VariablesTest < MiniTest::Test

  def test_it_fetches_variables
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      assert_equal NanocConrefFS::Variables.variables[:default].keys, ['site']
      assert_equal NanocConrefFS::Variables.variables[:default]['site']['data'].keys.sort, %w(categories reusables variables)
    end
  end

  def test_it_fetches_datafiles
    with_site(name: FIXTURES_DIR) do |site|
      file = NanocConrefFS::Variables.fetch_data_file('reusables.intro', :default)
      assert_equal file['frontmatter_intro'], 'Here I am, in the front.'
    end
  end
end
