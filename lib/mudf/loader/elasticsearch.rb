# frozen_string_literal: true

module MUDF
  module Loader
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
        @current_batch = []
        reset_index!
      end

      def title
        "Elastic"
      end

      def mapping
        {
          mappings: {
            properties: {
              location: {
                type: "geo_point"
              }
            }
          }
        }
      end

      def reset_index!
        if @client.indices.exists?(index: @index)
          @client.indices.delete(index: @index)
        end

        @client.indices.create(
          index: @index,
          body: mapping
        )
      end

      def transform_row!(input_row)
        input_row.tap do |row|
          lon = row.delete("longitude").to_f
          lat = row.delete("latitude").to_f
          row[:location] = [lon, lat]
        end
      end

      def persist_row(row)
        # use the bulk api for *much* faster inserts
        if @current_batch.length < 1000
          @current_batch << {
            index: {_id: row["mid"], data: row}
          }
        else
          @client.bulk body: @current_batch, index: @index
          @current_batch = []
        end
      end

      def finalize
        # flush any remaining
        unless @current_batch.empty?
          @client.bulk body: @current_batch, index: @index, refresh: true
        end
        puts "Loaded #{@client.count(index: @index)["count"]} records"
      end
    end
  end
end
