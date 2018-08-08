require 'faraday'
require 'faraday_middleware'
require 'rspec'
require 'multi_xml'
require 'nokogiri'


RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end