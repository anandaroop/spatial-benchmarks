# frozen_string_literal: true

module MUDF
  module Benchmark
    class Base
      QUERIES_PATH = './queries.json'

      def initialize(path = QUERIES_PATH)
        hash = JSON.parse(File.read(path))
        @queries = OpenStruct.new(hash)
      end

      def each_bounding_box
        @queries.bounding_boxes.each do |box|
          yield OpenStruct.new(box)
        end
      end

      def measure(n: 10)
        m = ::Benchmark.measure do
          n.times do
            print '.'
            run
          end
          puts "\n"
        end
        puts m.inspect
      end
    end
  end
end
