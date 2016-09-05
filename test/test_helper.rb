require 'bundler/setup'
require 'nanoc'
require_relative '../lib/nanoc-conref-fs'
require 'minitest/autorun'
require 'minitest/pride'
require 'active_support'

FIXTURES_DIR = File.join(Dir.pwd, 'test', 'fixtures')
CONFIG = YAML.load_file(File.join(FIXTURES_DIR, 'nanoc.yaml')).deep_symbolize_keys

class Minitest::Test
  FileUtils.rm_rf File.join(FIXTURES_DIR, 'output')
  FileUtils.rm_rf File.join(FIXTURES_DIR, 'tmp')
end

def read_output_file(dir, name)
  File.read(File.join('output', dir, name, 'index.html')).gsub(/^\s*$/, '')
end

def read_test_file(dir, name)
  File.read(File.join(FIXTURES_DIR, 'content', dir, "#{name}.html")).gsub(/^\s*$/, '')
end

def with_site
  # Yield site
  FileUtils.cd(FIXTURES_DIR) do
    yield Nanoc::Int::SiteLoader.new.new_from_cwd
  end
end
