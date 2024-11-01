# frozen_string_literal: true

require "ruby-progressbar"

module MUDF
  module Loader
    class Base
      extend Forwardable

      CSV_PATHS = [
        "MuseumFile2018_File1_Nulls.csv",
        "MuseumFile2018_File2_Nulls.csv",
        "MuseumFile2018_File3_Nulls.csv"
      ]

      FIELDS_TO_KEEP = %w[
        MID
        COMMONNAME
        LATITUDE
        LONGITUDE
        ADSTREET
        ADCITY
        ADSTATE
        ADZIP
        DISCIPLINE
        WEBURL
      ].freeze

      def initialize(paths = CSV_PATHS)
        @paths = paths
        @bar = ProgressBar.create title: format("%10s", title),
          total: total_line_count,
          format: "%t %J%% [%B] %e ",
          throttle_rate: 0.1
      end

      def each_row
        n = 0
        @paths.each do |path|
          @file = File.open(path)
          @file.set_encoding "ISO-8859-1:UTF-8"
          @csv = CSV.new(@file, headers: true)
          @csv.each do |raw_row|
            n += 1
            row = FIELDS_TO_KEEP.each_with_object({}) do |k, memo|
              memo[k.downcase] = raw_row[k]&.downcase if raw_row.key?(k)
            end
            yield row, n
          end
        end
      end

      def total_line_count
        @paths.reduce(0) { |count, path| count + File.readlines(path).size }
      end

      def load
        each_row do |row, n|
          transform_row!(row)
          persist_row(row)
          @bar.progress = n
          # puts row.inspect
          # break if @file.lineno >= 10000
        end
        finalize
      end

      # must override
      def title
        raise "Must be defined in subclass"
      end

      # must override
      def persist_row(_row)
        raise "Must be defined in subclass"
      end

      # must override
      def transform_row!(_input_row)
        raise "Must be defined in subclass"
      end

      # optionally override
      def finalize
        puts "Finished"
      end

      def_delegator :@file, :rewind, :reset
    end
  end
end
