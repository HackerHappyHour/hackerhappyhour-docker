require 'rspec-puppet'
require 'puppetlabs_spec_helper/module_spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
RSpec.configure do |c|
  c.hiera_config = File.join(fixture_path, 'modules/docker/hiera.yaml')
  c.module_path = File.join(fixture_path, 'modules')
  c.setup_fixtures = true
end

RSpec::Matchers.define :require_string_for do |property|
  match do |type_class|
    config = {:name => 'name'}
    config[property] = 2
    expect do
      type_class.new(config)
    end.to raise_error(Puppet::Error, /#{property} should be a String/)
  end
  failure_message do |type_class|
    "#{type_class} should require #{property} to be a String"
  end
end

RSpec::Matchers.define :require_hash_for do |property|
  match do |type_class|
    config = {:name => 'name'}
    config[property] = 2
    expect do
      type_class.new(config)
    end.to raise_error(Puppet::Error, /#{property} should be a Hash/)
  end
  failure_message do |type_class|
    "#{type_class} should require #{property} to be a Hash"
  end
end
