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
            @message = result.data
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
