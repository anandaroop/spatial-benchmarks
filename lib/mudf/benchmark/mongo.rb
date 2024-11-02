# frozen_string_literal: true

module MUDF
  module Benchmark
    class Mongo < Base
      def initialize
        super
        config = YAML.load_file("./config/databases.yml")["mongodb"]
        host, port, database = config.values_at("host", "port", "database")
        connection_string = "mongodb://#{host}:#{port}/#{database}"
        @client = ::Mongo::Client.new(connection_string)
        @client.logger.level = Logger::ERROR
        @collection = @client[:orgs]
      end

      def run
        each_bounding_box do |box|
          q = {
            location: geo_within_geometry_query(box)
          }
          _count = @client[:orgs].count(q)
          # puts [_count, box.to_h.values.join(',')].join("\t")
        end
      end

      # this one won't use index
      def geo_within_box_query(box)
        {
          "$geoWithin" => {
            "$box" => [[box.w, box.s], [box.e, box.n]]
          }
        }
      end

      # this one will use index -- about 30x faster
      def geo_within_geometry_query(box)
        {
          "$geoWithin" => {
            "$geometry": {
              type: "Polygon",
              coordinates: to_polygon(box)
            }
          }
        }
      end

      def to_polygon(box)
        [[
          [box.w, box.s],
          [box.w, box.n],
          [box.e, box.n],
          [box.e, box.s],
          [box.w, box.s]
        ]]
      end
    end
  end
end
