require 'test_helper'

class DatafilesTest < MiniTest::Test
  def setup
    @config = YAML.load_file(File.join(FIXTURES_DIR, 'nanoc.yaml')).deep_symbolize_keys
  end

  def test_it_collects_the_files
    files = Datafiles.collect_data(File.join(FIXTURES_DIR, 'data')).sort
    names = %w(categories/category categories/simple reusables/intro reusables/names variables/asterisks variables/empty variables/product)
    names.map! { |name| File.join(FIXTURES_DIR, 'data', "#{name}.yml") }
    assert_equal files, names
  end

  def test_it_creates_nested_hash
    string = %w(this is deep)
    value = 42
    hash = Datafiles.create_nested_hash(string, value)
    value = { 'this' => { 'is' => { 'deep' => 42 } } }
    assert_equal value, hash
  end

  def test_it_applies_conref_conditionals
    file = File.join(FIXTURES_DIR, 'data', 'variables', 'product.yml')
    content = File.read(file)
    result = Datafiles.apply_conditionals(@config, file, content)
    assert_includes result.to_s, 'No caveats!'

    @config[:data_variables][0][:values][:version] = 'foof'
    result = Datafiles.apply_conditionals(@config, file, content)
    assert_includes result.to_s, 'Well.....there is one.'
  end

  def test_it_leaves_liquid_substitutions_alone
    file = File.join(FIXTURES_DIR, 'data', 'reusables', 'intro.yml')
    content = File.read(file)
    result = Datafiles.apply_conditionals(@config, file, content)
    assert_includes result.to_s, 'We use {{ site.data.reusables.names.new_name }}'
    assert_includes result.to_s, '{{ site.data.variables.product.product_name }} is great'
  end
end
