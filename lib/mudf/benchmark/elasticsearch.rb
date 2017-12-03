# frozen_string_literal: true

module MUDF
  module Benchmark
    class Elasticsearch < Base
      def initialize
        super
        config = YAML.load_file('./config/databases.yml')['elasticsearch']
        host, port = config.values_at('host', 'port')
        url = "http://#{host}:#{port}"
        @client = ::Elasticsearch::Client.new(url: url)
        @index = config['index']
      end

      def run
        each_bounding_box do |box|
          result = @client.count index: @index, body: {
            query: geo_bounding_box_query(box)
          }
          _count = result['count']
        end
      end

      def geo_bounding_box_query(box)
        {
          geo_bounding_box: {
            location: {
              top_left: { lat: box.n, lon: box.w },
              bottom_right: { lat: box.s, lon: box.e }
            }
          }
        }
      end
    end
  end
end

# def search_within(page:, size:, north:, west:, south:, east:)
#   from = (page - 1) * size
#   body = {
#     from: from,
#     size: size,
#     sort: {
#       :"partner.relative_size" => :asc
#     },
#     query: {
#       geo_bounding_box: {
#         coordinates: {
#           top_left: {
#             lat: north,
#             lon: west
#           },
#           bottom_right: {
#             lat: south,
#             lon: east
#           }
#         }
#       }
#     }
#   }
#   search(body)
# end
# end
