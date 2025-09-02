require 'csv'

module Controller
  module Api
    module ImportController

      def self.registered(app)

        app.post '/api/import-prices' do
          unless params[:file] && params[:file][:tempfile]
            halt 400, { error: 'No file provided' }.to_json
          end

          csv_content = params[:file][:tempfile].read

          service = Service::ImportPricesService.new
          errors = service.import(csv_content)

          if errors.empty?
            content_type :json
            { success: true, message: 'Import completed successfully' }.to_json
          else
            content_type :json
            halt 400, { success: false, errors: errors }.to_json
          end
        end

      end

    end
  end
end
