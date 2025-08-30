module UseCase
  module PricesApi
    class ListRateTypesUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      def initialize(logger)
        @logger = logger
      end

      def perform(params)
        rental_location_id = params['rental_location_id']

        if rental_location_id.nil? || rental_location_id.empty?
          return Result.new(success?: false, authorized?: true, message: 'rental_location_id is required')
        end

        rate_types = Service::ListRateTypesForRentalLocationService.new.retrieve(rental_location_id)

        data = rate_types.map { |rt| { id: rt.id, name: rt.name } }

        Result.new(success?: true, authorized?: true, data: data)
      end
    end
  end
end
