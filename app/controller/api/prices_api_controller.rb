module Controller
  module Api
    module PricesApiController

      def self.registered(app)

        #
        # Get rental locations
        #
        app.get '/api/rental_locations' do
          use_case = UseCase::PricesApi::ListRentalLocationsUseCase.new(logger)
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
        # Get rate types - filtered by rental location if provided
        #
        app.get '/api/rate_types' do
          service = Service::ListRateTypesService.new
          data = service.retrieve(params[:rental_location_id])
          content_type :json
          data.map { |rt| { id: rt.id, name: rt.name } }.to_json
        end

        #
        # Get season definitions - filtered by rental location if provided
        #
        app.get '/api/season_definitions' do
          service = Service::ListSeasonDefinitionsService.new
          data = service.retrieve(params[:rental_location_id])
          content_type :json
          data.map { |sd| { id: sd.id, name: sd.name } }.to_json
        end

        #
        # Get seasons - filtered by season definition if provided
        #
        app.get '/api/seasons' do
          service = Service::ListSeasonsService.new
          data = service.retrieve(params[:season_definition_id])
          content_type :json
          data.map { |s| { id: s.id, name: s.name, season_definition_id: s.season_definition_id } }.to_json
        end

        #
        # Get durations - static list
        #
        app.get '/api/durations' do
          service = Service::ListDurationsService.new
          data = service.retrieve
          content_type :json
          data.to_json
        end

        #
        # Get prices
        #
        app.get '/api/prices' do
          use_case = UseCase::PricesApi::ListPricesUseCase.new(logger)
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

      end
    end
  end
end
