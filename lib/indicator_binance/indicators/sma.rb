module IndicatorBinance
  OBJECT = Struct.new(:start_time, :period, :value)
  SMA    = Struct.new(:current, :previous)
  DSMA   = Struct.new(:sma_small, :sma_big)

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

    def self.single_sma(data: [], period: 30, price_key: :close_price, date_time_key: :start_time, precision: 2)
      period        = period.to_i
      price_key     = price_key.to_sym
      date_time_key = date_time_key.to_sym
      data          = data.reverse
      data_current  = data[0, period]
      data_perivous = data[1, period]

      SMA.new(
        sma_object(data_current, period, date_time_key, price_key, precision),
        sma_object(data_perivous, period, date_time_key, price_key, precision)
      )
    end

    def self.double_sma(data: [], small_period: 5, big_period: 10, precision: 2)
      sma_small = single_sma(data: data, period: small_period, precision:precision)
      sma_big   = single_sma(data: data, period: big_period, precision: precision)
      current   = DSMA.new(sma_small.current, sma_big.current)
      pervious  = DSMA.new(sma_small.previous, sma_big.previous)

      SMA.new(current, pervious)
    end

    def self.sma_object(data, period, date_time_key, price_key, precision)
      start_time = Time.at(data.first[date_time_key] / 1000).to_s
      value_sma  = ArrayHelper.average(data.map { |i| i[price_key]}).to_f.round(precision)
    
      OBJECT.new(start_time, period, value_sma)
    end
  end
end
