module IndicatorBinance
  MA   = Struct.new(:start_time, :value)
  SMA  = Struct.new(:current, :previous)
  DSMA = Struct.new(:start_time, :small, :big)

  class Sma < Indicator
    def self.indicator_symbol
      "sma"
    end

    def self.indicator_name
      "Simple Moving Average"
    end

    def self.valid_options
      %i(period price_key date_time_key)
    end

    def self.validate_options(options)
      Validation.validate_options(options, valid_options)
    end

    def self.min_data_size(period: 30, **params)
      period.to_i
    end

    def self.single_sma(data: [], period: 30, price_key: :close_price, date_time_key: :start_time)
      period        = period.to_i
      price_key     = price_key.to_sym
      date_time_key = date_time_key.to_sym
      data          = data.reverse
      data_current  = data[0, period]
      data_perivous = data[1, period]

      SMA.new(
        sma_value(data_current, date_time_key, price_key),
        sma_value(data_perivous, date_time_key, price_key)
      )
    end

    def self.double_sma(data = [], small_period = 5, big_period = 10)
      sma_small = single_sma(data: data, period: small_period)
      sma_big   = single_sma(data: data, period: big_period)
      current   = DSMA.new(sma_small.current.start_time, sma_small.current.value, sma_big.current.value)
      pervious  = DSMA.new(sma_small.previous.start_time, sma_small.previous.value, sma_big.previous.value)

      SMA.new(current, pervious)
    end

    def self.sma_value(data, date_time_key, price_key)
      start_time = Time.at(data.first[date_time_key] / 1000).to_s
      value_sma  = ArrayHelper.average(data.map { |i| i[price_key]})
    
      MA.new(start_time, value_sma)
    end
  end
end
