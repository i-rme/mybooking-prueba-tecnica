require 'csv'

module Controller
  module Api
    module ImportController

      def self.registered(app)

        app.post '/api/import-prices' do
          unless params[:file] && params[:file][:tempfile]
            content_type :json
            halt 400, { error: 'No file provided' }.to_json
          end

          begin
            csv_content = params[:file][:tempfile].read

            service = Service::ImportPricesService.new
            errors = service.import(csv_content)

            if errors.empty?
              content_type :json
              { success: true, message: 'Prices imported successfully' }.to_json
            else
              content_type :json
              halt 422, { success: false, errors: errors }.to_json
            end
          rescue => e
            content_type :json
            halt 500, { success: false, error: "Import failed: #{e.message}" }.to_json
          end
        end

      end

    end
  end
end
