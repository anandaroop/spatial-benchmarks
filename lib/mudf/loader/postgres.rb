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
          discipline varchar(256),
          weburl varchar(256)
          )
      SQL

      INSERT_ROW = <<~SQL
        INSERT INTO orgs (mid, commonname, latitude, longitude, adstreet, adcity, adstate, adzip, discipline, weburl)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      SQL

      ADD_LOCATION_COL = <<~SQL
        SELECT AddGeometryColumn('orgs', 'location', 4326, 'POINT', 2)
      SQL

      UPDATE_LOCATION_COL = <<~SQL
        UPDATE orgs SET location = ST_GeomFromText('POINT( ' || longitude || ' ' || latitude || ')', 4326)
      SQL

      INDEX_COL = <<~SQL
        CREATE INDEX orgs_location_idx ON orgs USING GIST ( location )
      SQL

      CLUSTER_TABLE_PHYSICALLY = <<~SQL
        CLUSTER orgs USING orgs_location_idx
      SQL

      def initialize
        super
        config = YAML.load_file("./config/databases.yml")["postgresql"]
        host, port, database, user, password = config.values_at("host", "port", "database", "user", "password")

        conn = ::PG::Connection.new(
          host:,
          port:,
          dbname: "postgres",
          user:,
          password:
        )
        conn.exec("DROP DATABASE IF EXISTS #{database}")
        conn.exec("CREATE DATABASE #{database}")

        @client = ::PG::Connection.new(
          host:,
          port:,
          dbname: database,
          user:,
          password:
        )

        prepare_db!
      end

      def title
        "Postgres"
      end

      def prepare_db!
        @client.exec(DDL)
        @client.prepare("org_insert", INSERT_ROW)
      end

      def transform_row!(input_row)
        input_row.tap do |row|
          row["mid"] = row["mid"].to_i
          row["latitude"] = row["latitude"].to_f
          row["longitude"] = row["longitude"].to_f
        end
      end

      def persist_row(row)
        @client.exec_prepared("org_insert", row.values)
      rescue PG::UniqueViolation
        puts "Skipping duplicate record: #{row["mid"]}"
      end

      def finalize
        enable_postgis!

        res = @client.exec("select count(*) from orgs")
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
        @client.exec("CREATE EXTENSION postgis")
        @client.exec(ADD_LOCATION_COL)
      end

      def update_spatial_cols!
        @client.exec(UPDATE_LOCATION_COL)
      end

      def index_spatial_cols!
        @client.exec(INDEX_COL)
        @client.exec(CLUSTER_TABLE_PHYSICALLY)
        @client.exec("VACUUM ANALYZE orgs")
      end
    end
  end
end
