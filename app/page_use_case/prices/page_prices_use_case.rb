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
        filter_params = process_filter_params(processed_params)

        actual_prices = Service::ListActualPricesService.new.retrieve(
          rental_location_id: filter_params[:rental_location_id],
          rate_type_id: filter_params[:rate_type_id],
          season_definition_id: filter_params[:season_definition_id],
          season_id: filter_params[:season_id],
          time_measurement: filter_params[:time_measurement]
        )

        # Transform data to match expected format
        prices = actual_prices.map do |p|
          OpenStruct.new(
            category_code: p.category_code,
            category_name: p.category_name,
            rental_location_name: p.rental_location_name,
            rate_type_name: p.rate_type_name,
            season_name: p.season_name,
            time_measurement: p.time_measurement,
            units: p.units,
            price: format("%.2f€", p.price),
            included_km: p.included_km,
            extra_km_price: p.extra_km_price,
            deposit: p.deposit,
            excess: p.excess,
            price_definition_id: p.price_definition_id,
            price_id: p.price_id
          )
        end

        data = OpenStruct.new(
          rental_locations: rental_locations.map { |rl| OpenStruct.new(id: rl.id, name: rl.name) },
          rate_types: rate_types.map { |rt| OpenStruct.new(id: rt.id, name: rt.name) },
          season_definitions: season_definitions.map { |sd| OpenStruct.new(id: sd.id, name: sd.name) },
          seasons: seasons.map { |s| OpenStruct.new(id: s.id, name: s.name) },
          prices: prices,
          selected_rental_location: filter_params[:selected_rental_location],
          selected_rate_type: filter_params[:selected_rate_type],
          selected_season_definition: filter_params[:selected_season_definition],
          selected_season: filter_params[:selected_season],
          selected_duration: filter_params[:selected_duration],
          message: "Precios cargados correctamente"
        )

        # Return the result
        return Result.new(success?: true, authorized?: true, data: data)

      end

      private

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
        selected_duration = params[:season_duration] || ''

        { valid: true, authorized: true, selected_rental_location: selected_rental_location, selected_rate_type: selected_rate_type, selected_season_definition: selected_season_definition, selected_season: selected_season, selected_duration: selected_duration }
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
      def process_filter_params(processed_params)
        # Set defaults for ids
        rental_location_id = processed_params[:selected_rental_location].empty? ? '1' : processed_params[:selected_rental_location]
        rate_type_id = processed_params[:selected_rate_type].empty? ? '1' : processed_params[:selected_rate_type]
        season_definition_id = processed_params[:selected_season_definition].empty? ? '1' : processed_params[:selected_season_definition]
        season_id = processed_params[:selected_season].empty? ? '0' : processed_params[:selected_season]

        # Map duration to time_measurement
        time_measurement = case processed_params[:selected_duration]
        when 'days' then 2
        when 'month' then 0
        when 'hours' then 1
        when 'minutes' then 3
        else nil
        end

        {
          rental_location_id: rental_location_id,
          rate_type_id: rate_type_id,
          season_definition_id: season_definition_id,
          season_id: season_id,
          time_measurement: time_measurement,
          selected_rental_location: processed_params[:selected_rental_location],
          selected_rate_type: processed_params[:selected_rate_type],
          selected_season_definition: processed_params[:selected_season_definition],
          selected_season: processed_params[:selected_season],
          selected_duration: processed_params[:selected_duration]
        }
      end

    end
  end
end
