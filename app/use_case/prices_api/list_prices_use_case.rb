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

        # Get names from ids
        rental_location = Service::GetRentalLocationByIdService.new.retrieve(rental_location_id)
        rate_type = Service::GetRateTypeByIdService.new.retrieve(rate_type_id)

        if rental_location.nil? || rate_type.nil?
          return Result.new(success?: false, authorized?: true, message: 'Invalid ids')
        end

        time_measurement = case duration
                          when 'month' then 0
                          when 'days' then 1
                          when 'hours' then 2
                          when 'minutes' then 3
                          else -1
                          end

        actual_prices = Service::ListActualPricesService.new.retrieve(
          rental_location_name: rental_location.name,
          rate_type_name: rate_type.name,
          season_definition_id: season_definition_id,
          season_id: season_id,
          time_measurement: time_measurement
        )

        # Transform to the format expected
        price_periods = generate_price_periods(actual_prices)
        formatted_prices = format_prices_by_category(actual_prices, price_periods)

        data = {
          price_periods: price_periods,
          prices: formatted_prices
        }

        Result.new(success?: true, authorized?: true, data: data)
      end

      private

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

      def format_prices_by_category(actual_prices, price_periods)
        categories = actual_prices.group_by { |p| "#{p.category_code} - #{p.category_name}" }
        categories.map do |category_name, prices|
          price_map = prices.each_with_object({}) do |p, h|
            period = case p.units
                     when 1 then "1 día"
                     when 2 then "2 días"
                     when 4 then "4 días"
                     when 8 then "8 días"
                     when 15 then "15 días"
                     when 30 then "30 días"
                     else "#{p.units} días"
                     end
            h[period] = "%.2f€" % p.price
          end
          {
            category: category_name,
            prices: price_periods.map { |period| price_map[period] || "0.00€" }
          }
        end
      end
    end
  end
end
