module UseCase
  module PricesApi
    class ListSeasonDefinitionsUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      def initialize(logger)
        @logger = logger
      end

      def perform(params)
        rate_type_id = params['rate_type_id']
        rental_location_id = params['rental_location_id']

        if rate_type_id.nil? || rate_type_id.empty? || rental_location_id.nil? || rental_location_id.empty?
          return Result.new(success?: false, authorized?: true, message: 'rate_type_id and rental_location_id are required')
        end

        season_definitions = Service::ListSeasonDefinitionsForRateTypeService.new.retrieve(rate_type_id, rental_location_id)

        data = season_definitions.map { |sd| { id: sd.id, name: sd.name } }

        Result.new(success?: true, authorized?: true, data: data)
      end
    end
  end
end
