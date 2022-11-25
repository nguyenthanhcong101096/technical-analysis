module IndicatorBinance
  # Ease of Movement
  class Eom < Indicator

    # Returns the symbol of the technical indicator
    #
    # @return [String] A string of the symbol of the technical indicator
    def self.indicator_symbol
      "eom"
    end

    # Returns the name of the technical indicator
    #
    # @return [String] A string of the name of the technical indicator
    def self.indicator_name
      "Ease of Movement"
    end

    # Returns an array of valid keys for options for this technical indicator
    #
    # @return [Array] An array of keys as symbols for valid options for this technical indicator
    def self.valid_options
      %i(period)
    end

    # Validates the provided options for this technical indicator
    #
    # @param options [Hash] The options for the technical indicator to be validated
    #
    # @return [Boolean] Returns true if options are valid or raises a ValidationError if they're not
    def self.validate_options(options)
      Validation.validate_options(options, valid_options)
    end

    # Calculates the minimum number of observations needed to calculate the technical indicator
    #
    # @param options [Hash] The options for the technical indicator
    #
    # @return [Integer] Returns the minimum number of observations needed to calculate the technical
    #    indicator based on the options provided
    def self.min_data_size(period: 14)
      period.to_i + 1
    end

    # Calculates the ease of movement (EoM) for the data over the given period
    # https://en.wikipedia.org/wiki/Ease_of_movement
    #
    # @param data [Array] Array of hashes with keys (:date_time, :high, :low, :volume)
    # @param period [Integer] The given period to calculate the EoM
    #
    # @return [Array<Hash>] An array of EomValue instances
    def self.calculate(data, period: 14)
      period = period.to_i
      Validation.validate_numeric_data(data, :high, :low, :volume)
      Validation.validate_length(data, min_data_size(period: period))
      Validation.validate_date_time_key(data)

      data = data.sort_by { |row| row[:date_time] }

      output = []
      period_values = []
      prev_price = data.shift

      data.each do |v|
        distance_moved = ((v[:high] + v[:low]) / 2) - ((prev_price[:high] + prev_price[:low]) / 2)
        box_ratio = (v[:volume] / 100_000_000.00) / (v[:high] - v[:low])
        emv = distance_moved / box_ratio

        period_values << emv

        if period_values.size == period
          output << EomValue.new(date_time: v[:date_time], eom: ArrayHelper.average(period_values))
          period_values.shift
        end

        prev_price = v
      end

      output.sort_by(&:date_time).reverse
    end

  end

  # The value class to be returned by calculations
  class EomValue

    # @return [String] the date_time of the obversation as it was provided
    attr_accessor :date_time

    # @return [Float] the eom calculation value
    attr_accessor :eom

    def initialize(date_time: nil, eom: nil)
      @date_time = date_time
      @eom = eom
    end

    # @return [Hash] the attributes as a hash
    def to_hash
      { date_time: @date_time, eom: @eom }
    end

  end
end
