# frozen_string_literal: true

# def search_near(page:, size:, lat:, lon:, radius: '10km')
#   from = (page - 1) * size
#   body = {
#     from: from,
#     size: size,
#     query: {
#       geo_distance: {
#         distance: radius,
#         coordinates: {
#           lat: lat, lon: lon
#         }
#       }
#     }
#   }
#   search(body)
# end

module MUDF
  module Benchmark
    class Elasticsearch
      def initialize; end

      def run; end
    end
  end
end
