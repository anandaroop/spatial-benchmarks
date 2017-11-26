# frozen_string_literal: true

require './lib/mudf'

namespace :mongo do
  desc 'Load MUDF data into a Mongo database'
  task :load do
    loader = MUDF::Loader::Mongo.new
    loader.load
  end

  desc 'Run benchmark queries against Mongo database'
  task :benchmark do
    benchmark = MUDF::Benchmark::Mongo.new
    benchmark.run
  end
end

namespace :elasticsearch do
  desc 'Load MUDF data into a Elasticsearch database'
  task :load do
    loader = MUDF::Loader::Elasticsearch.new
    loader.load
  end

  desc 'Run benchmark queries against Elasticsearch database'
  task :benchmark do
    benchmark = MUDF::Benchmark::Elasticsearch.new
    benchmark.run
  end
end

task :config do
  config = YAML.load_file './config/databases.yml'
  puts config.inspect
end
