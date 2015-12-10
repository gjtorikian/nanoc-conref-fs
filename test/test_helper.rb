require 'bundler/setup'
require 'nanoc'
require_relative '../lib/nanoc-conref-fs'
require 'minitest/autorun'
require 'minitest/pride'
require 'active_support'

FIXTURES_DIR = File.join(Dir.pwd, 'test', 'fixtures')

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

def with_site(params = {})
  # Build site name
  site_name = params[:name]
  if site_name.nil?
    @site_num ||= 0
    site_name = "site-#{@site_num}"
    @site_num += 1
  end

  # Build rules
  rules_content = <<EOS
compile '*' do
{{compilation_rule_content}}
end

route '*' do
if item.binary?
  item.identifier.chop + (item[:extension] ? '.' + item[:extension] : '')
else
  item.identifier + 'index.html'
end
end

layout '*', :erb
EOS
  rules_content.gsub!('{{compilation_rule_content}}', params[:compilation_rule_content] || '')

  # Create site
  unless File.directory?(site_name)
    FileUtils.mkdir_p(site_name)
    FileUtils.cd(site_name) do
      FileUtils.mkdir_p('content')
      FileUtils.mkdir_p('layouts')
      FileUtils.mkdir_p('lib')
      FileUtils.mkdir_p('output')

      if params[:has_layout]
        File.open('layouts/default.html', 'w') do |io|
          io.write('... <%= @yield %> ...')
        end
      end

      File.open('nanoc.yaml', 'w') do |io|
        io << 'string_pattern_type: legacy' << "\n"
        io << 'data_sources:' << "\n"
        io << '  -' << "\n"
        io << '    type: filesystem' << "\n"
        io << '    identifier_type: legacy' << "\n"
      end
      File.open('Rules', 'w') { |io| io.write(rules_content) }
    end
  end

  # Yield site
  FileUtils.cd(site_name) do
    yield Nanoc::Int::SiteLoader.new.new_from_cwd
  end
end
