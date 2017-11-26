# frozen_string_literal: true

# db.orgs.find(
#    {
#      location: {
#         $nearSphere: {
#            $geometry: {
#               type : "Point",
#               coordinates : [ -150.98965, 60.50184 ]
#            },
#            $maxDistance: 10000
#         }
#      }
#    }
# )

module MUDF
  module Benchmark
    class Mongo
      def initialize; end

      def run; end
    end
  end
end
