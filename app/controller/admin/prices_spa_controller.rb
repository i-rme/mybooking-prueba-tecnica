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

          erb :prices_spa
        end

      end
    end
  end
end