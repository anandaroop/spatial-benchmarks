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

namespace :postgres do
  desc 'Load MUDF data into a Postgres database'
  task :load do
    loader = MUDF::Loader::Postgres.new
    loader.load
  end

  desc 'Run benchmark queries against Postgres database'
  task :benchmark do
    benchmark = MUDF::Benchmark::Postgres.new
    benchmark.run
  end
end

desc 'Load all the things'
task load: %i[mongo:load elasticsearch:load postgres:load]
