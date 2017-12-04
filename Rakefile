# frozen_string_literal: true

require './lib/mudf'
require 'open-uri'

N = 100

desc 'Get the MUDF data'
task :get_csv do
  # https://www.imls.gov/research-evaluation/data-collection/museum-universe-data-file
  puts 'Downloading…'
  src = open('https://www.imls.gov/sites/default/files/mudf15q3pub_csv.zip')
  dst = File.open('./mudf15q3pub_csv.zip', 'w')
  dst.write(src.read)
  puts 'Decompressing…'
  system "unzip #{dst.path}"
  puts 'Done.'
end

namespace :mongo do
  desc 'Load MUDF data into Mongo'
  task :load do
    loader = MUDF::Loader::Mongo.new
    loader.load
  end

  desc 'Run benchmark queries against Mongo'
  task :benchmark do
    benchmark = MUDF::Benchmark::Mongo.new
    print 'Mongo'
    benchmark.measure(n: N)
  end
end

namespace :elasticsearch do
  desc 'Load MUDF data into Elasticsearch'
  task :load do
    loader = MUDF::Loader::Elasticsearch.new
    loader.load
  end

  desc 'Run benchmark queries against Elasticsearch'
  task :benchmark do
    benchmark = MUDF::Benchmark::Elasticsearch.new
    benchmark.measure(n: N)
  end
end

namespace :postgres do
  desc 'Load MUDF data into Postgres/PostGIS'
  task :load do
    loader = MUDF::Loader::Postgres.new
    loader.load
  end

  desc 'Run benchmark queries against Postgres/PostGIS'
  task :benchmark do
    benchmark = MUDF::Benchmark::Postgres.new
    print 'PostGIS'
    benchmark.measure(n: N)
  end
end

desc 'Load all the things'
task load: %i[mongo:load elasticsearch:load postgres:load]

desc 'Benchmark all the things'
task :benchmark do
  mongo = MUDF::Benchmark::Mongo.new
  postgres = MUDF::Benchmark::Postgres.new
  elasticsearch = MUDF::Benchmark::Elasticsearch.new

  Benchmark.bmbm do |x|
    x.report('Mongo')    { N.times { mongo.run } }
    x.report('Postgres') { N.times { postgres.run } }
    x.report('Elastic')  { N.times { elasticsearch.run } }
  end
end
