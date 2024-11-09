# frozen_string_literal: true

module MUDF
  module Benchmark
    class Elasticsearch < Base
      def initialize
        super
        config = YAML.load_file("./config/databases.yml")["elasticsearch"]
        host, port, index = config.values_at("host", "port", "index")
        host_url = "http://#{host}:#{port}"

        @client = ::Elasticsearch::Client.new(
          host: host_url
          # log: true
        )
        @index = index
      end

      def run
        each_bounding_box do |box|
          result = @client.search index: @index, body: {
            query: geo_bounding_box_query(box),
            size: RESULTS_PER_QUERY,
            sort: [
              {
                _geo_distance: {
                  location: {
                    lat: box.center[:lat],
                    lon: box.center[:lng]
                  },
                  order: "asc",
                  distance_type: "arc"
                }
              }
            ]
          }
          pp result["hits"]["hits"].map { |hit| hit["_source"].values_at("adstate", "commonname") } if VERBOSE
          @num_hits += result["hits"]["hits"].length
        end
      end

      def geo_bounding_box_query(box)
        {
          geo_bounding_box: {
            location: {
              top_left: {lat: box.n, lon: box.w},
              bottom_right: {lat: box.s, lon: box.e}
            }
          }
        }
      end
    end
  end
end
