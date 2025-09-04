module Controller
  module Api
    module SampleController

      def self.registered(app)

        #
        # Sample of a REST API end-point
        #
        app.get '/api/sample' do

          use_case = UseCase::Sample::SampleUseCase.new(Repository::CategoryRepository.new, logger)
          result = use_case.perform(params)

          if result.success?
            content_type :json
            # Use the serializer to create a basic object with no dependencies on the ORM
            serializer = Controller::Serializer::BaseSerializer.new
            data = serializer.serialize(result.data)
            data.to_json
          elsif !result.authorized?
            halt 401
          else
            halt 400, result.message.to_json
          end
        end

        #
        # Sample of a REST API end-point using a service with an SQL Query
        #
        app.get '/api/sample-service' do

          service = Service::ListPricesService.new
          use_case = UseCase::Sample::SampleServiceUseCase.new(service, logger)
          result = use_case.perform(params)

          if result.success?
            content_type :json
            result.data.to_json
          elsif !result.authorized?
            halt 401
          else
            halt 400, result.message.to_json
          end
        end

        #
        # API endpoint for prices
        #
        app.get '/api/prices' do
          rental_location_id = params[:rental_location_id]
          rate_type_id = params[:rate_type_id]
          season_definition_id = params[:season_definition_id]
          season_id = params[:season_id]
          duration = params[:duration]

          if rental_location_id && rate_type_id && season_definition_id && season_id && duration
            # Map duration to time_measurement
            time_measurement = case duration
            when 'days' then 1
            when 'month' then 0
            when 'hours' then 2
            when 'minutes' then 3
            else 1
            end

            service = Service::ListActualPricesService.new
            data = service.retrieve(
              rental_location_id: rental_location_id,
              rate_type_id: rate_type_id,
              season_definition_id: season_definition_id,
              season_id: season_id,
              time_measurement: time_measurement
            )

            # Format the data similar to the page use case
            price_periods = generate_price_periods(data)
            formatted_prices = format_prices_by_category(data, price_periods)

            content_type :json
            {
              price_periods: price_periods,
              prices: formatted_prices.map { |p| { category: p.category, prices: p.prices } }
            }.to_json
          else
            halt 400, { error: 'Missing required parameters' }.to_json
          end
        end

        #
        # Helper method to generate price periods
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
        # Helper method to format prices by category
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


      end

    end
  end
end
