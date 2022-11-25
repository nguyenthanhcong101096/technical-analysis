module IndicatorBinance
  class Indicator

    CALCULATIONS = [
      :indicator_name,
      :indicator_symbol,
      :min_data_size,
      :technicals,
      :valid_options,
      :validate_options,
    ].freeze

    private_constant :CALCULATIONS

    # Returns an array of IndicatorBinance modules
    #
    # @return [Array] A list of IndicatorBinance::Class
    def self.roster
      [
        IndicatorBinance::Adi,
        IndicatorBinance::Adtv,
        IndicatorBinance::Adx,
        IndicatorBinance::Ao,
        IndicatorBinance::Atr,
        IndicatorBinance::Bb,
        IndicatorBinance::Cci,
        IndicatorBinance::Cmf,
        IndicatorBinance::Cr,
        IndicatorBinance::Dc,
        IndicatorBinance::Dlr,
        IndicatorBinance::Dpo,
        IndicatorBinance::Dr,
        IndicatorBinance::Eom,
        IndicatorBinance::Fi,
        IndicatorBinance::Ichimoku,
        IndicatorBinance::Kc,
        IndicatorBinance::Kst,
        IndicatorBinance::Macd,
        IndicatorBinance::Mfi,
        IndicatorBinance::Mi,
        IndicatorBinance::Nvi,
        IndicatorBinance::Obv,
        IndicatorBinance::ObvMean,
        IndicatorBinance::Rsi,
        IndicatorBinance::Sma,
        IndicatorBinance::Sr,
        IndicatorBinance::Trix,
        IndicatorBinance::Tsi,
        IndicatorBinance::Uo,
        IndicatorBinance::Vi,
        IndicatorBinance::Vpt,
        IndicatorBinance::Vwap,
        IndicatorBinance::Wr,
      ]
    end

    def self.roster_hash
      {
        IndicatorBinance::Adi.indicator_symbol => IndicatorBinance::Adi,
        IndicatorBinance::Adtv.indicator_symbol => IndicatorBinance::Adtv,
        IndicatorBinance::Adx.indicator_symbol => IndicatorBinance::Adx,
        IndicatorBinance::Ao.indicator_symbol => IndicatorBinance::Ao,
        IndicatorBinance::Atr.indicator_symbol => IndicatorBinance::Atr,
        IndicatorBinance::Bb.indicator_symbol => IndicatorBinance::Bb,
        IndicatorBinance::Cci.indicator_symbol => IndicatorBinance::Cci,
        IndicatorBinance::Cmf.indicator_symbol => IndicatorBinance::Cmf,
        IndicatorBinance::Cr.indicator_symbol => IndicatorBinance::Cr,
        IndicatorBinance::Dc.indicator_symbol => IndicatorBinance::Dc,
        IndicatorBinance::Dlr.indicator_symbol => IndicatorBinance::Dlr,
        IndicatorBinance::Dpo.indicator_symbol => IndicatorBinance::Dpo,
        IndicatorBinance::Dr.indicator_symbol => IndicatorBinance::Dr,
        IndicatorBinance::Eom.indicator_symbol => IndicatorBinance::Eom,
        IndicatorBinance::Fi.indicator_symbol => IndicatorBinance::Fi,
        IndicatorBinance::Ichimoku.indicator_symbol => IndicatorBinance::Ichimoku,
        IndicatorBinance::Kc.indicator_symbol => IndicatorBinance::Kc,
        IndicatorBinance::Kst.indicator_symbol => IndicatorBinance::Kst,
        IndicatorBinance::Macd.indicator_symbol => IndicatorBinance::Macd,
        IndicatorBinance::Mfi.indicator_symbol => IndicatorBinance::Mfi,
        IndicatorBinance::Mi.indicator_symbol => IndicatorBinance::Mi,
        IndicatorBinance::Nvi.indicator_symbol => IndicatorBinance::Nvi,
        IndicatorBinance::Obv.indicator_symbol => IndicatorBinance::Obv,
        IndicatorBinance::ObvMean.indicator_symbol => IndicatorBinance::ObvMean,
        IndicatorBinance::Rsi.indicator_symbol => IndicatorBinance::Rsi,
        IndicatorBinance::Sma.indicator_symbol => IndicatorBinance::Sma,
        IndicatorBinance::Sr.indicator_symbol => IndicatorBinance::Sr,
        IndicatorBinance::Trix.indicator_symbol => IndicatorBinance::Trix,
        IndicatorBinance::Tsi.indicator_symbol => IndicatorBinance::Tsi,
        IndicatorBinance::Uo.indicator_symbol => IndicatorBinance::Uo,
        IndicatorBinance::Vi.indicator_symbol => IndicatorBinance::Vi,
        IndicatorBinance::Vpt.indicator_symbol => IndicatorBinance::Vpt,
        IndicatorBinance::Vwap.indicator_symbol => IndicatorBinance::Vwap,
        IndicatorBinance::Wr.indicator_symbol => IndicatorBinance::Wr,
      }
    end

    # Finds the applicable indicator and returns an instance
    #
    # @param indicator_symbol [String] Downcased string of the indicator symbol
    #
    # @return IndicatorBinance::ClassName
    def self.find(indicator_symbol)
      if roster_hash.key?(indicator_symbol)
        roster_hash[indicator_symbol]
      else
        nil
      end
    end

    # Find the applicable indicator and looks up the value
    #
    # @param indicator_symbol [String] Downcased string of the indicator symbol
    # @param data [Array] Array of hashes of price data to perform calcualtion on
    # @param calculation [Symbol] The calculation to be performed on the requested indicator and params
    # @param options [Hash] A hash containing options for the requested calculation
    #
    # @return Returns the requested calculation
    def self.calculate(indicator_symbol, data, calculation, options={})
      return nil unless CALCULATIONS.include? calculation

      indicator = find(indicator_symbol)
      raise "Indicator not found!" if indicator.nil?

      case calculation
      when :indicator_name; indicator.indicator_name
      when :indicator_symbol; indicator.indicator_symbol
      when :technicals; indicator.calculate(data, options)
      when :min_data_size; indicator.min_data_size(options)
      when :valid_options; indicator.valid_options
      when :validate_options; indicator.validate_options(options)
      else nil
      end
    end

    # Calculates the minimum number of observations needed to calculate the technical indicator
    #
    # @param options [Hash] The options for the technical indicator
    #
    # @return [Integer] Returns the minimum number of observations needed to calculate the technical
    #    indicator based on the options provided
    def self.min_data_size(indicator_symbol, options)
      raise "#{self.name} did not implement min_data_size"
      nil
    end

    # Validates the provided options for this technical indicator
    #
    # @param options [Hash] The options for the technical indicator to be validated
    #
    # @return [Boolean] Returns true if options are valid or raises a ValidationError if they're not
    def self.validate_options(options)
      raise "#{self.name} did not implement validate_options"
      false
    end

    # Returns an array of valid keys for options for this technical indicator
    #
    # @return [Array] An array of keys as symbols for valid options for this technical indicator
    def self.valid_options
      raise "#{self.name} did not implement valid_options"
      []
    end

    # Returns the symbol of the technical indicator
    #
    # @return [String] A string of the symbol of the technical indicator
    def self.indicator_symbol
      raise "#{self.name} did not implement indicator_symbol"
    end

    # Returns the name of the technical indicator
    #
    # @return [String] A string of the name of the technical indicator
    def self.indicator_name
      raise "#{self.name} did not implement indicator_name"
    end

  end
end
