module Controller
  module Admin
    module PricesController

      def self.registered(app)

        #
        # Prices page
        #
        app.get '/prices' do

          use_case = PageUseCase::Prices::PagePricesUseCase.new(logger)
          result = use_case.perform(params)

          @title = "Prices page"

          if result.success?
            @rental_locations = result.data.rental_locations
            @rate_types = result.data.rate_types
            @season_definitions = result.data.season_definitions
            @seasons = result.data.seasons
            @price_periods = result.data.price_periods
            @prices = result.data.prices
            @message = result.data.message
            erb :prices
          else
            @message = result.message
            erb :error_page
          end

        end

      end
    end
  end
end
