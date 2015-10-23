require 'test_helper'

class VariableMixinTest < MiniTest::Test

  def test_it_fetches_variables
    with_site(name: FIXTURES_DIR) do |site|

      site = Nanoc::Int::SiteLoader.new.new_from_cwd
      site.compile

      assert_equal VariableMixin.variables.keys, ['site']
      assert_equal VariableMixin.variables['site']['data'].keys, %w(categories reusables variables)
    end
  end

  def test_it_fetches_datafiles
    file = VariableMixin.fetch_data_file('reusables.intro')
    assert_equal file['frontmatter_intro'], 'Here I am, in the front.'
  end
end
