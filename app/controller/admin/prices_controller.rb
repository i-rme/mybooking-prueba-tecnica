module Controller
  module Admin
    module PricesController

      def self.registered(app)

        #
        # Prices SPA page
        #
        app.get '/prices' do

          @title = "Prices"
          @message = "Select options to load prices"

          erb :prices
        end

      end
    end
  end
end