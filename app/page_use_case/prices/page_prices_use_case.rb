module PageUseCase
  module Prices
    #
    # Page use case for prices
    #
    class PagePricesUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param [Logger] logger
      #
      def initialize(logger)
        @logger = logger
      end

      #
      # Perform the use case
      #
      # @param [User] user
      # @param [Integer] booking_id
      #
      # @return [Result]
      #
      def perform(params)

        processed_params = process_params(params)

        # Check valid
        unless processed_params[:valid]
          return Result.new(success?: false, authorized?: true, message: processed_params[:message])
        end

        # Check authorization
        unless processed_params[:authorized]
          return Result.new(success?: true, authorized?: false, message: 'Not authorized')
        end

        # Get data from services
        rental_locations = Service::ListRentalLocationsService.new.retrieve
        rate_types = Service::ListRateTypesService.new.retrieve
        season_definitions = Service::ListSeasonDefinitionsService.new.retrieve
        seasons = Service::ListSeasonsService.new.retrieve
        actual_prices = Service::ListActualPricesService.new.retrieve

        # Transform data to match expected format
        price_periods = generate_price_periods(actual_prices)
        formatted_prices = format_prices_by_category(actual_prices, price_periods)

        data = OpenStruct.new(
          rental_locations: rental_locations.map { |rl| OpenStruct.new(id: rl.id, name: rl.name) },
          rate_types: rate_types.map { |rt| OpenStruct.new(id: rt.id, name: rt.name) },
          season_definitions: season_definitions.map { |sd| OpenStruct.new(id: sd.id, name: sd.name) },
          seasons: seasons.map { |s| OpenStruct.new(id: s.id, name: s.name) },
          price_periods: price_periods,
          prices: formatted_prices,
          message: "Precios cargados correctamente"
        )

        # Return the result
        return Result.new(success?: true, authorized?: true, data: data)

      end

      private

      #
      # Generate price periods from actual prices data
      #
      # @param [Array] actual_prices
      # @return [Array] Array of period strings
      #
      def generate_price_periods(actual_prices)
        units = actual_prices.map { |p| p.units }.uniq.sort
        units.map do |unit|
          case unit
          when 1 then "1 día"
          when 2 then "2 días"
          when 4 then "4 días"
          when 8 then "8 días"
          when 15 then "15 días"
          when 30 then "30 días"
          else "#{unit} días"
          end
        end
      end

      #
      # Format prices by category for display
      #
      # @param [Array] actual_prices
      # @param [Array] price_periods
      # @return [Array] Formatted prices by category
      #
      def format_prices_by_category(actual_prices, price_periods)
        # Group prices by category
        prices_by_category = actual_prices.group_by { |p| "#{p.category_code} - #{p.category_name}" }

        prices_by_category.map do |category_key, category_prices|
          # Get all unique units for this category
          category_units = category_prices.map { |p| p.units }.uniq.sort

          # Create price array matching the periods
          price_values = price_periods.map do |period|
            unit = period.match(/(\d+)/)[1].to_i
            price_record = category_prices.find { |p| p.units == unit }
            price_record ? format("%.2f€", price_record.price) : "0.00€"
          end

          OpenStruct.new(category: category_key, prices: price_values)
        end
      end

      #
      # Process the parameters
      #
      # @return [Hash]
      #
      def process_params(params)

        return { valid: true, authorized: true }

      end

    end
  end
end
