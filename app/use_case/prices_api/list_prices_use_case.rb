module UseCase
  module PricesApi
    class ListPricesUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      def initialize(logger)
        @logger = logger
      end

      def perform(params)
        rental_location_id = params['rental_location_id']
        rate_type_id = params['rate_type_id']
        season_definition_id = params['season_definition_id']
        season_id = params['season_id']
        duration = params['duration']

        if [rental_location_id, rate_type_id, season_definition_id, season_id, duration].any? { |p| p.nil? || p.empty? }
          return Result.new(success?: false, authorized?: true, message: 'All parameters are required')
        end

        time_measurement = case duration
                          when 'month' then 0
                          when 'days' then 2
                          when 'hours' then 1
                          when 'minutes' then 3
                          else nil
                          end

        actual_prices = Service::ListActualPricesService.new.retrieve(
          rental_location_id: rental_location_id,
          rate_type_id: rate_type_id,
          season_definition_id: season_definition_id,
          season_id: season_id,
          time_measurement: time_measurement
        )

        # Transform to the format expected
        prices = actual_prices.map do |p|
          {
            category_code: p.category_code,
            category_name: p.category_name,
            rental_location_name: p.rental_location_name,
            rate_type_name: p.rate_type_name,
            season_name: p.season_name,
            time_measurement: p.time_measurement,
            units: p.units,
            price: "%.2f€" % p.price,
            included_km: p.included_km,
            extra_km_price: p.extra_km_price,
            deposit: p.deposit,
            excess: p.excess,
            price_definition_id: p.price_definition_id,
            price_id: p.price_id
          }
        end

        data = {
          prices: prices
        }

        Result.new(success?: true, authorized?: true, data: data)
      end

      private
    end
  end
end
