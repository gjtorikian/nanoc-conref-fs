require 'test_helper'

class DatafilesTest < MiniTest::Test
  def test_it_collects_the_files
    files = NanocConrefFS::Datafiles.collect_data(File.join(FIXTURES_DIR, 'data')).keys.sort
    names = %w(categories/category categories/empty_category categories/nested categories/simple reusables/intro reusables/names variables/asterisks variables/empty variables/product)
    names.map! { |name| File.join(FIXTURES_DIR, 'data', "#{name}.yml") }
    assert_equal files, names
  end

  def test_it_creates_nested_hash
    string = %w(this is deep)
    value = 42
    hash = NanocConrefFS::Datafiles.create_nested_hash(string, value)
    value = { 'this' => { 'is' => { 'deep' => 42 } } }
    assert_equal value, hash
  end

  def test_it_applies_conref_conditionals
    file = File.join(FIXTURES_DIR, 'data', 'variables', 'product.yml')
    content = File.read(file)
    result = NanocConrefFS::Datafiles.apply_conditionals(CONFIG, path: file, content: content, rep: :default)
    assert_includes result.to_s, 'No caveats!'

    # Don't modify the global constant, you break other tests.
    config = YAML.load_file(File.join(FIXTURES_DIR, 'nanoc.yaml')).deep_symbolize_keys
    config[:data_variables][0][:values][:version] = 'foof'

    result = NanocConrefFS::Datafiles.apply_conditionals(config, path: file, content: content, rep: :default)
    assert_includes result.to_s, 'Well.....there is one.'
  end

  def test_it_leaves_liquid_substitutions_alone
    file = File.join(FIXTURES_DIR, 'data', 'reusables', 'intro.yml')
    content = File.read(file)
    result = NanocConrefFS::Datafiles.apply_conditionals(CONFIG, path: file, content: content, rep: :default)
    assert_includes result.to_s, 'We use {{ site.data.reusables.names.new_name }}'
    assert_includes result.to_s, '{{ site.data.variables.product.product_name }} is great'
  end

  def test_it_converts_nested_blocks
    file = File.join(FIXTURES_DIR, 'data', 'categories', 'nested.yml')
    content = File.read(file)
    result = NanocConrefFS::Datafiles.apply_conditionals(CONFIG, path: file, content: content, rep: :default)
    assert_includes result.to_s, 'About gists'
    refute_includes result.to_s, 'Deleting an anonymous gist'
  end
end
