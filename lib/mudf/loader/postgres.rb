# frozen_string_literal: true

module MUDF
  module Loader
    class Postgres < Base
      DDL = <<~SQL
        CREATE TABLE orgs(
          mid bigint primary key,
          commonname varchar(256),
          latitude numeric(8,5),
          longitude numeric(8,5),
          adstreet varchar(256),
          adcity varchar(256),
          adstate varchar(256),
          adzip varchar(256),
          discipl varchar(256),
          weburl varchar(256)
          )
      SQL

      INSERT_ROW = <<~SQL
        INSERT INTO orgs (mid, commonname, latitude, longitude, adstreet, adcity, adstate, adzip, discipl, weburl)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      SQL

      ADD_LOCATION_COL_1 = <<~SQL
        SELECT AddGeometryColumn('orgs', 'location', 4326, 'POINT', 2)
      SQL

      ADD_LOCATION_COL_2 = <<~SQL
        SELECT AddGeometryColumn('orgs', 'location_indexed', 4326, 'POINT', 2)
      SQL

      UPDATE_LOCATION_COL_1 = <<~SQL
        UPDATE orgs SET location = ST_GeomFromText('POINT( ' || longitude || ' ' || latitude || ')', 4326)
      SQL

      UPDATE_LOCATION_COL_2 = <<~SQL
        UPDATE orgs SET location_indexed = ST_GeomFromText('POINT( ' || longitude || ' ' || latitude || ')', 4326)
      SQL

      INDEX_COL = <<~SQL
        CREATE INDEX orgs_location_indexed_idx ON orgs USING GIST ( location_indexed )
      SQL

      def initialize
        super
        config = YAML.load_file('./config/databases.yml')['postgresql']
        host, port, database = config.values_at('host', 'port', 'database')
        @client = ::PG::Connection.new(host: host, port: port, dbname: database)
        prepare_db!
      end

      def title
        'Postgres'
      end

      def prepare_db!
        @client.exec('DROP TABLE IF EXISTS orgs')
        @client.exec(DDL)
        @client.prepare('org_insert', INSERT_ROW)
      end

      def transform_row!(input_row)
        input_row.tap do |row|
          row['mid'] = row['mid'].to_i
          row['latitude'] = row['latitude'].to_f
          row['longitude'] = row['longitude'].to_f
        end
      end

      def persist_row(row)
        @client.exec_prepared('org_insert', row.values)
      end

      def finalize
        enable_postgis!

        res = @client.exec('select count(*) from orgs')
        count = res.values[0][0]
        puts "Loaded #{count} records"
        @client.close
      end

      def enable_postgis!
        create_spatial_cols!
        update_spatial_cols!
        index_spatial_cols!
      end

      def create_spatial_cols!
        @client.exec('DROP EXTENSION IF EXISTS postgis')
        @client.exec('CREATE EXTENSION postgis')
        @client.exec(ADD_LOCATION_COL_1)
        @client.exec(ADD_LOCATION_COL_2)
      end

      def update_spatial_cols!
        @client.exec(UPDATE_LOCATION_COL_1)
        @client.exec(UPDATE_LOCATION_COL_2)
      end

      def index_spatial_cols!
        @client.exec(INDEX_COL)
        @client.exec('VACUUM ANALYZE orgs')
      end
    end
  end
end
