module IndicatorBinance
  # Donchian Channel
  class Dc < Indicator

    # Returns the symbol of the technical indicator
    #
    # @return [String] A string of the symbol of the technical indicator
    def self.indicator_symbol
      "dc"
    end

    # Returns the name of the technical indicator
    #
    # @return [String] A string of the name of the technical indicator
    def self.indicator_name
      "Donchian Channel"
    end

    # Returns an array of valid keys for options for this technical indicator
    #
    # @return [Array] An array of keys as symbols for valid options for this technical indicator
    def self.valid_options
      %i(period price_key)
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
    def self.min_data_size(period: 20, **params)
      period.to_i
    end

    # Calculates the donchian channel (DC) for the data over the given period
    # https://en.wikipedia.org/wiki/Donchian_channel
    #
    # @param data [Array] Array of hashes with keys (:date_time, :value)
    # @param period [Integer] The given period to calculate the DC
    # @param price_key [Symbol] The hash key for the price data. Default :value
    #
    # @return [Array<DcValue>] An array of DcValue instances
    def self.calculate(data, period: 20, price_key: :value)
      period = period.to_i
      price_key = price_key.to_sym
      Validation.validate_numeric_data(data, price_key)
      Validation.validate_length(data, min_data_size(period: period))
      Validation.validate_date_time_key(data)

      data = data.sort_by { |row| row[:date_time] }

      output = []
      period_values = []

      data.each do |v|
        period_values << v[price_key]

        if period_values.size == period
          output << DcValue.new(
            date_time: v[:date_time],
            upper_bound: period_values.max,
            lower_bound: period_values.min
          )

          period_values.shift
        end
      end

      output.sort_by(&:date_time).reverse
    end

  end

  # The value class to be returned by calculations
  class DcValue

    # @return [String] the date_time of the obversation as it was provided
    attr_accessor :date_time

    # @return [Float] the upper_bound calculation value
    attr_accessor :upper_bound

    # @return [Float] the lower_bound calculation value
    attr_accessor :lower_bound

    def initialize(date_time: nil, upper_bound: nil, lower_bound: ninl)
      @date_time = date_time
      @upper_bound = upper_bound
      @lower_bound = lower_bound
    end

    # @return [Hash] the attributes as a hash
    def to_hash
      { date_time: @date_time, upper_bound: @upper_bound, lower_bound: @lower_bound }
    end

  end
end
