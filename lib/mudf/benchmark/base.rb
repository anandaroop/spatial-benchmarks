# frozen_string_literal: true

module MUDF
  module Benchmark
    class Base
      QUERIES_PATH = "./queries.json"
      RESULTS_PER_QUERY = 20
      VERBOSE = false

      def initialize(path = QUERIES_PATH)
        @queries = JSON.parse(File.read(path))
        @num_queries = 0
        @num_hits = 0
      end

      def each_bounding_box
        @queries.each do |bounds|
          @num_queries += 1
          yield OpenStruct.new(
            w: bounds["_southWest"]["lng"],
            e: bounds["_northEast"]["lng"],
            s: bounds["_southWest"]["lat"],
            n: bounds["_northEast"]["lat"],
            center: {
              lat: (bounds["_southWest"]["lat"] + bounds["_northEast"]["lat"]) / 2,
              lng: (bounds["_southWest"]["lng"] + bounds["_northEast"]["lng"]) / 2
            }
          )
        end
      end

      def measure(n: 10)
        m = ::Benchmark.measure do
          n.times do
            print "."
            run
          end
          puts "\n"
        end
        puts m.inspect
        puts "Queries: #{@num_queries}, Hits: #{@num_hits}, QPS: #{@num_queries / m.real}"
      end
    end
  end
end
