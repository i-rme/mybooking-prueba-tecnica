module Controller
  module Admin
    module PricesSpaController

      def self.registered(app)

        #
        # Prices SPA page
        #
        app.get '/prices_spa' do

          @title = "Prices SPA page"
          @message = "Select options to load prices"

          # Initialize empty data
          @rental_locations = []
          @rate_types = []
          @season_definitions = []
          @seasons = []
          @price_periods = []
          @prices = []
          @selected_rental_location = ''
          @selected_rate_type = ''
          @selected_season_definition = ''
          @selected_season = ''
          @selected_duration = ''

          erb :prices_spa
        end

      end
    end
  end
end