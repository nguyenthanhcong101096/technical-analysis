module IndicatorBinance
  BB = Struct.new(:current, :previous)

  class Bb < Indicator
    def self.indicator_symbol
      "bb"
    end

    def self.indicator_name
      "Bollinger Bands"
    end

    def self.valid_options
      %i(period standard_deviations price_key)
    end

    def self.validate_options(options)
      Validation.validate_options(options, valid_options)
    end

    def self.min_data_size(period: 20, **params)
      period.to_i
    end

    def self.calculate(data: , period: 20, standard_deviations: 2, price_key: :close_price, date_time_key: :start_time, precision: 2)
      period              = period.to_i
      standard_deviations = standard_deviations.to_f
      price_key           = price_key.to_sym

      Validation.validate_numeric_data(data, price_key)
      Validation.validate_length(data, min_data_size(period: period))

      data = data.sort_by { |row| row[date_time_key] }.reverse

      BB.new(
        calculate_bb(data[0, period], period, standard_deviations, price_key, date_time_key, precision),
        calculate_bb(data[1, period], period, standard_deviations, price_key, date_time_key, precision)
      )
    end

    def self.calculate_bb(data, period, standard_deviations, price_key, date_time_key, precision)
      period_values = data.map { |i| i[price_key] }

      if period_values.size == period
        mb = ArrayHelper.average(period_values)
        sd = ArrayHelper.standard_deviation(period_values)
        ub = mb + standard_deviations * sd
        lb = mb - standard_deviations * sd

        BbValue.new(
          start_time: Time.at(data.first[date_time_key] / 1000).to_s,
          lower_band: lb.round(precision),
          middle_band: mb.round(precision),
          upper_band: ub.round(precision),
          period: period
        )
      end
    end
  end

  class BbValue
    attr_accessor :start_time, :lower_band, :middle_band, :upper_band, :period

    def initialize(start_time: nil, lower_band: nil, middle_band: nil, upper_band: nil, period: 0)
      @start_time  = start_time
      @lower_band  = lower_band
      @middle_band = middle_band
      @upper_band  = upper_band
      @period      = period
    end

    def to_hash
      {
        start_time: @start_time,
        lower_band: @lower_band,
        middle_band: @middle_band,
        upper_band: @upper_band,
        period: @period
      }
    end
  end
end
