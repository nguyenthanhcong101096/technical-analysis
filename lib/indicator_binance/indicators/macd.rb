module IndicatorBinance
  MACD = Struct.new(:current, :previous)

  class Macd < Indicator
    def self.indicator_symbol
      "macd"
    end

    def self.indicator_name
      "Moving Average Convergence Divergence"
    end

    def self.valid_options
      %i(fast_period slow_period signal_period price_key)
    end

    def self.validate_options(options)
      Validation.validate_options(options, valid_options)
    end

    def self.min_data_size(slow_period: 26, signal_period: 9, **params)
      slow_period.to_i + signal_period.to_i - 1
    end

    def self.calculate(data: , fast_period: 12, slow_period: 26, signal_period: 9, price_key: :close_price, date_time_key: :start_time, precision: 2)
      fast_period = fast_period.to_i
      slow_period = slow_period.to_i
      signal_period = signal_period.to_i
      price_key = price_key.to_sym
      Validation.validate_numeric_data(data, price_key)
      Validation.validate_length(data, min_data_size(slow_period: slow_period, signal_period: signal_period))

      data = data.sort_by { |row| row[date_time_key] }

      macd_values = []
      output = []
      period_values = []
      prev_fast_ema = nil
      prev_signal = nil
      prev_slow_ema = nil

      data.each do |v|
        period_values << v[price_key]

        if period_values.size >= fast_period
          fast_ema = StockCalculation.ema(v[price_key], period_values, fast_period, prev_fast_ema)
          prev_fast_ema = fast_ema

          if period_values.size == slow_period
            slow_ema = StockCalculation.ema(v[price_key], period_values, slow_period, prev_slow_ema)
            prev_slow_ema = slow_ema

            macd = fast_ema - slow_ema
            macd_values << macd
            
            if macd_values.size == signal_period
              signal = StockCalculation.ema(macd, macd_values, signal_period, prev_signal)
              prev_signal = signal

              output << MacdValue.new(
                start_time: Time.at(v[date_time_key] / 1000).to_s,
                macd_line: macd,
                signal_line: signal,
                macd_histogram: macd - signal,
              )

              macd_values.shift
            end

            period_values.shift
          end
        end
      end

      output = output.sort_by(&date_time_key).reverse

      MACD.new(
        output[0],
        output[1],
      )
    end
  end

  class MacdValue
    attr_accessor :start_time, :macd_line, :macd_histogram, :signal_line

    def initialize(start_time: nil, macd_line: nil, macd_histogram: nil, signal_line: nil)
      @start_time = start_time
      @macd_line = macd_line
      @macd_histogram = macd_histogram
      @signal_line = signal_line
    end

    def to_hash
      {
        start_time: @start_time,
        macd_line: @macd_line,
        macd_histogram: @macd_histogram,
        signal_line: @signal_line
      }
    end
  end
end
