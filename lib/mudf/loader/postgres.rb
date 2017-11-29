# frozen_string_literal: true

module MUDF
  module Loader
    class Postgres < Base

      DDL = <<~EOF
        create table orgs(
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
      EOF

      def initialize
        super
        config = YAML.load_file('./config/databases.yml')['postgresql']
        host, port, database = config.values_at('host', 'port', 'database')
        @client = ::PG::Connection.new(host: host, port: port, dbname: database)

        @client.exec( "drop table if exists orgs" )
        @client.exec(DDL)
        @client.prepare('org_insert', 'insert into orgs (mid, commonname, latitude, longitude, adstreet, adcity, adstate, adzip, discipl, weburl) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)')
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
        res = @client.exec( "select count(*) from orgs" )
        count = res.values[0][0]
        puts "Loaded #{count} records"
        @client.close
      end
    end
  end
end
