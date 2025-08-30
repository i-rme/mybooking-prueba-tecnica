module UseCase
  module PricesApi
    class ListRentalLocationsUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      def initialize(logger)
        @logger = logger
      end

      def perform(params)
        # No authorization check for now
        rental_locations = Service::ListRentalLocationsService.new.retrieve

        data = rental_locations.map { |rl| { id: rl.id, name: rl.name } }

        Result.new(success?: true, authorized?: true, data: data)
      end
    end
  end
end
