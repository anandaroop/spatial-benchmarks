# frozen_string_literal: true

module MUDF
  module Benchmark
    class Base
      QUERIES_PATH = "./queries.json"

      def initialize(path = QUERIES_PATH)
        @queries = JSON.parse(File.read(path))
      end

      def each_bounding_box
        @queries.each do |bounds|
          yield OpenStruct.new(
            w: bounds["_southWest"]["lng"],
            e: bounds["_northEast"]["lng"],
            s: bounds["_southWest"]["lat"],
            n: bounds["_northEast"]["lat"]
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
      end
    end
  end
end
