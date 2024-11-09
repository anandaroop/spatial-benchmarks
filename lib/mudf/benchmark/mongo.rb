# frozen_string_literal: true

module MUDF
  module Benchmark
    class Mongo < Base
      def initialize
        super
        config = YAML.load_file("./config/databases.yml")["mongodb"]
        host, port, database, user, password = config.values_at("host", "port", "database", "user", "password")
        @client = ::Mongo::Client.new(
          ["#{host}:#{port}"],
          database:,
          user:,
          password:,
          auth_source: "admin"
        )
        @client.logger.level = Logger::ERROR
        @collection = @client[:orgs]
      end

      def run
        each_bounding_box do |box|
          result = @collection.aggregate([
            {
              "$geoNear" => {
                near: {
                  type: "Point",
                  coordinates: [box.center[:lng], box.center[:lat]]
                },
                distanceField: "distance",
                query: {
                  location: geo_within_geometry_query(box)
                }
              }
            },
            {
              "$limit" => RESULTS_PER_QUERY
            }
          ])

          pp result.map { |doc| doc.values_at("adstate", "commonname", "location") } if VERBOSE
          @num_hits += result.to_a.length
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
