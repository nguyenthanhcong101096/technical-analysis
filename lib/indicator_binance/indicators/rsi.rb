module IndicatorBinance
  OBJECT = Struct.new(:start_time, :period, :value)

  class Rsi < Indicator
    def self.indicator_symbol
      "rsi"
    end

    def self.indicator_name
      "Relative Strength Index"
    end

    def self.valid_options
      %i(period price_key date_time_key)
    end

    def self.validate_options(options)
      Validation.validate_options(options, valid_options)
    end

    def self.min_data_size(period: 14, **params)
      period.to_i + 1
    end

    def self.calculate(data: [], period: 14, price_key: :close_price, date_time_key: :start_time, precision: 2)
      period           = period.to_i
      price_key        = price_key.to_sym
      data             = data.sort_by { |row| row[date_time_key] }
      output           = []
      prev_price       = data.shift[price_key]
      prev_avg         = nil
      price_changes    = []
      smoothing_period = period - 1

      data.each do |v|
        break if output.size >= 1
  
        price_change = (v[price_key] - prev_price)
        price_changes << price_change

        if price_changes.size == period
          if prev_avg.nil?
            avg_gain = ArrayHelper.average(price_changes.map { |pc| pc.positive? ? pc : 0 })
            avg_loss = ArrayHelper.average(price_changes.map { |pc| pc.negative? ? pc.abs : 0 })
          else
            if price_change > 0
              current_loss = 0
              current_gain = price_change
            elsif price_change < 0
              current_loss = price_change.abs
              current_gain = 0
            else
              current_loss = 0
              current_gain = 0
            end

            avg_gain = (((prev_avg[:gain] * smoothing_period) + current_gain) / period.to_f)
            avg_loss = (((prev_avg[:loss] * smoothing_period) + current_loss) / period.to_f)
          end

          if avg_loss == 0
            rsi = 100
          else
            rs = avg_gain / avg_loss
            rsi = (100.00 - (100.00 / (1.00 + rs)))
          end

          start_time = Time.at(v[date_time_key] / 1000).to_s

          output << OBJECT.new(start_time, period, rsi.round(precision))

          prev_avg = { gain: avg_gain, loss: avg_loss }
          price_changes.shift
        end

        prev_price = v[price_key]
      end

      output.sort_by(&:start_time).reverse.first
    end
  end
end
