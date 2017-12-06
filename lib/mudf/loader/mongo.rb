# frozen_string_literal: true

module MUDF
  module Loader
    class Mongo < Base
      def initialize
        super
        config = YAML.load_file('./config/databases.yml')['mongodb']
        host, port, database = config.values_at('host', 'port', 'database')
        connection_string = "mongodb://#{host}:#{port}/#{database}"
        @client = ::Mongo::Client.new(connection_string)
        @client.logger.level = Logger::ERROR
        @collection = @client[:orgs]
        @collection.drop
        @collection.indexes.create_one(location: '2dsphere')
      end

      def title
        'Mongo'
      end

      def transform_row!(input_row)
        input_row.tap do |row|
          lon = row.delete('longitude').to_f
          lat = row.delete('latitude').to_f
          row[:location] = {
            type: 'Point',
            coordinates: [lon, lat]
          }
        end
      end

      def persist_row(row)
        @collection.insert_one(row)
      end

      def finalize
        puts "Loaded #{@collection.count} records"
        @client.close
      end
    end
  end
end
