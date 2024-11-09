# frozen_string_literal: true

require "./lib/mudf"
require "open-uri"
require "pry"
require "debug"

N = 10

desc "Get the MUDF data"
task :get_csv do
  # https://www.imls.gov/research-evaluation/data-collection/museum-universe-data-file
  url = "https://www.imls.gov/sites/default/files/2018_csv_museum_data_files.zip"

  puts "Downloading…"
  File.binwrite("mudf.zip", URI.open(url).read)
  system("unzip mudf.zip")

  puts "Modifying files…"
  files = [
    "MuseumFile2018_File1_Nulls.csv",
    "MuseumFile2018_File2_Nulls.csv",
    "MuseumFile2018_File3_Nulls.csv"
  ]

  files.each do |file|
    content = File.read(file, encoding: "ISO-8859-1").encode("UTF-8")
    File.write(file, content, encoding: "UTF-8")
  end

  system("sed -i '' 's/MID,DISCIPL,EIN/MID,DISCIPLINE,EIN/' MuseumFile2018_File1_Nulls.csv")

  puts "Done."
end

namespace :mongo do
  desc "Load MUDF data into Mongo"
  task :load do
    loader = MUDF::Loader::Mongo.new
    loader.load
  end

  desc "Run benchmark queries against Mongo"
  task :benchmark do
    benchmark = MUDF::Benchmark::Mongo.new
    print "Mongo"
    benchmark.measure(n: N)
  end
end

namespace :elasticsearch do
  desc "Load MUDF data into Elasticsearch"
  task :load do
    loader = MUDF::Loader::Elasticsearch.new
    loader.load
  end

  desc "Run benchmark queries against Elasticsearch"
  task :benchmark do
    benchmark = MUDF::Benchmark::Elasticsearch.new
    benchmark.measure(n: N)
  end
end

namespace :postgres do
  desc "Load MUDF data into Postgres/PostGIS"
  task :load do
    loader = MUDF::Loader::Postgres.new
    loader.load
  end

  desc "Run benchmark queries against Postgres/PostGIS"
  task :benchmark do
    benchmark = MUDF::Benchmark::Postgres.new
    print "PostGIS"
    benchmark.measure(n: N)
  end
end

desc "Load all the things"
task load: %i[mongo:load elasticsearch:load postgres:load]

desc "Benchmark all the things"
task :benchmark do
  mongo = MUDF::Benchmark::Mongo.new
  postgres = MUDF::Benchmark::Postgres.new
  elasticsearch = MUDF::Benchmark::Elasticsearch.new

  puts "Performing #{N} runs of 100 queries each with up to #{MUDF::Benchmark::Base::RESULTS_PER_QUERY} results"
  bm = Benchmark.bmbm do |x|
    x.report("Elastic") { N.times { elasticsearch.run } }
    x.report("Postgres") { N.times { postgres.run } }
    x.report("Mongo") { N.times { mongo.run } }
  end

  total_queries = N * 100
  ["Elastic", "Postgres", "Mongo"].map { |db|
    seconds = bm.detect { |m| m.label == db }.real
    puts "#{db}: #{(total_queries / seconds).round(2)} QPS"
  }
end

desc "Open a pry console"
task :pry do
  require "pry"
  binding.pry # standard:disable Lint/Debugger
end
