module UseCase
  module PricesApi
    class ListSeasonsUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      def initialize(logger)
        @logger = logger
      end

      def perform(params)
        season_definition_id = params['season_definition_id']

        if season_definition_id.nil? || season_definition_id.empty?
          return Result.new(success?: false, authorized?: true, message: 'season_definition_id is required')
        end

        seasons = Service::ListSeasonsForSeasonDefinitionService.new.retrieve(season_definition_id)

        data = seasons.map { |s| { id: s.id, name: s.name } }

        Result.new(success?: true, authorized?: true, data: data)
      end
    end
  end
end
