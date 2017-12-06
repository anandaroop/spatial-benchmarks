# frozen_string_literal: true

require 'ruby-progressbar'

module MUDF
  module Loader
    class Base
      extend Forwardable

      CSV_PATH = './mudf15q3pub_csv.csv'

      FIELDS_TO_KEEP = %w[
        MID
        COMMONNAME
        LATITUDE
        LONGITUDE
        ADSTREET
        ADCITY
        ADSTATE
        ADZIP
        DISCIPL
        WEBURL
      ].freeze

      def initialize(path = CSV_PATH)
        @file = File.open(path)
        @file.set_encoding 'ISO-8859-1:UTF-8'
        @csv = CSV.new(@file, headers: true)
        @bar = ProgressBar.create title: format('%10s', title),
                                  total: @file.size,
                                  format: '%t %J%% [%B] %e ',
                                  throttle_rate: 0.1
      end

      def each_row
        @csv.each do |raw_row|
          row = FIELDS_TO_KEEP.each_with_object({}) do |k, memo|
            memo[k.downcase] = raw_row[k]&.downcase if raw_row.key?(k)
          end
          yield row
        end
      end

      def load
        each_row do |row|
          transform_row!(row)
          persist_row(row)
          @bar.progress = @file.pos
          # puts row.inspect
          # break if @file.lineno >= 10000
        end
        finalize
      end

      # must override
      def title
        raise 'Must be defined in subclass'
      end

      # must override
      def persist_row(_row)
        raise 'Must be defined in subclass'
      end

      # must override
      def transform_row!(_input_row)
        raise 'Must be defined in subclass'
      end

      # optionally override
      def finalize
        puts 'Finished'
      end

      def_delegator :@file, :rewind, :reset
    end
  end
end
