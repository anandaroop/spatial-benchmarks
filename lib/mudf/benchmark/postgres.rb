# frozen_string_literal: true

module MUDF
  module Benchmark
    class Postgres < Base
      ENVELOPE_QUERY = <<~SQL
        SELECT count(*)
        FROM orgs
        WHERE location && ST_MakeEnvelope($1, $2, $3, $4, 4326);
      SQL

      def initialize
        super
        config = YAML.load_file('./config/databases.yml')['postgresql']
        host, port, database = config.values_at('host', 'port', 'database')
        @client = ::PG::Connection.new(host: host, port: port, dbname: database)
        @client.prepare('location_envelope', ENVELOPE_QUERY)
      end

      def run
        each_bounding_box do |box|
          result = @client.exec_prepared('location_envelope',
                                         [box.w, box.s, box.e, box.n])
          _count = result[0]['count']
          # puts [_count, box.to_h.values.join(',')].join("\t")
        end
      end
    end
  end
end
