# frozen_string_literal: true

module MUDF
  module Benchmark
    class Postgres < Base
      ENVELOPE_QUERY = <<~SQL
        SELECT *
        -- , ST_X(location::geometry) as lat
        -- , ST_Y(location::geometry) as lng
        FROM orgs
        WHERE location && ST_MakeEnvelope($1, $2, $3, $4, 4326)
        ORDER BY ST_Distance(location::geography, ST_MakePoint($5, $6)::geography)
        LIMIT #{RESULTS_PER_QUERY}
      SQL

      def initialize
        super
        config = YAML.load_file("./config/databases.yml")["postgresql"]
        host, port, database, user, password = config.values_at("host", "port", "database", "user", "password")
        @client = ::PG::Connection.new(
          host:,
          port:,
          dbname: database,
          user:,
          password:
        )
        @client.prepare("location_envelope", ENVELOPE_QUERY)
      end

      def run
        each_bounding_box do |box|
          result = @client.exec_prepared("location_envelope",
            [box.w, box.s, box.e, box.n, box.center[:lng], box.center[:lat]])
          pp result.map { |row| row.values_at("adstate", "commonname") } if VERBOSE
          @num_hits += result.count
        end
      end
    end
  end
end
