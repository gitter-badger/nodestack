# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::elasticsearch' do
  before { stub_resources }

  platform = 'ubuntu'
  version = '12.04'

  cached('runner') do
    ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: LOG_LEVEL) do |node, server|
      # memoized_runner(platform: platform, version: version, log_level: LOG_LEVEL) do |node, server|
      node_resources(node)
    end
  end

  recipes = %w(
          java
          elasticsearch
  )

  let(:chef_run) do
    node_resources(runner.clean_node)
    recipes.each do |recipe|
      runner.converge(recipe)
    end
  end

  it 'includes the java recipe' do
    recipes.each do |recipe|
      expect(chef_run).to include_recipe(recipe)
    end
  end
end
