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

        # Process params with the data
        filter_params = process_filter_params(processed_params, rental_locations, rate_types, season_definitions, seasons)

        actual_prices = Service::ListActualPricesService.new.retrieve(
          rental_location_name: filter_params[:rental_location_name],
          rate_type_name: filter_params[:rate_type_name],
          season_definition_id: filter_params[:season_definition_id],
          season_id: filter_params[:season_id]
        )

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
          selected_rental_location: filter_params[:selected_rental_location],
          selected_rate_type: filter_params[:selected_rate_type],
          selected_season_definition: filter_params[:selected_season_definition],
          selected_season: filter_params[:selected_season],
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
        selected_rental_location = params[:rental_location] || ''
        selected_rate_type = params[:rate_type] || ''
        selected_season_definition = params[:season_definition_id] || ''
        selected_season = params[:season_id] || ''

        { valid: true, authorized: true, selected_rental_location: selected_rental_location, selected_rate_type: selected_rate_type, selected_season_definition: selected_season_definition, selected_season: selected_season }
      end

      #
      # Process filter parameters with data
      #
      # @param [Hash] processed_params
      # @param [Array] rental_locations
      # @param [Array] rate_types
      # @param [Array] season_definitions
      # @param [Array] seasons
      # @return [Hash]
      #
      def process_filter_params(processed_params, rental_locations, rate_types, season_definitions, seasons)
        # Find names from ids
        rental_location = rental_locations.find { |rl| rl.id.to_s == processed_params[:selected_rental_location] }
        rate_type = rate_types.find { |rt| rt.id.to_s == processed_params[:selected_rate_type] }
        season_definition = season_definitions.find { |sd| sd.id.to_s == processed_params[:selected_season_definition] }
        season = seasons.find { |s| s.id.to_s == processed_params[:selected_season] }

        # Use names if found, else defaults
        rental_location_name = rental_location ? rental_location.name : 'Barcelona'
        rate_type_name = rate_type ? rate_type.name : 'Estándar'
        season_definition_id = season_definition ? season_definition.id.to_s : '1'
        season_id = season ? season.id.to_s : '0'

        {
          rental_location_name: rental_location_name,
          rate_type_name: rate_type_name,
          season_definition_id: season_definition_id,
          season_id: season_id,
          selected_rental_location: processed_params[:selected_rental_location],
          selected_rate_type: processed_params[:selected_rate_type],
          selected_season_definition: processed_params[:selected_season_definition],
          selected_season: processed_params[:selected_season]
        }
      end

    end
  end
end
