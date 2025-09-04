module Controller
  module Api
    module SampleController

      def self.registered(app)

        #
        # Sample of a REST API end-point
        #
        app.get '/api/sample' do

          use_case = UseCase::Sample::SampleUseCase.new(Repository::CategoryRepository.new, logger)
          result = use_case.perform(params)

          if result.success?
            content_type :json
            # Use the serializer to create a basic object with no dependencies on the ORM
            serializer = Controller::Serializer::BaseSerializer.new
            data = serializer.serialize(result.data)
            data.to_json
          elsif !result.authorized?
            halt 401
          else
            halt 400, result.message.to_json
          end
        end

        #
        # Sample of a REST API end-point using a service with an SQL Query
        #
        app.get '/api/sample-service' do

          service = Service::ListPricesService.new
          use_case = UseCase::Sample::SampleServiceUseCase.new(service, logger)
          result = use_case.perform(params)

          if result.success?
            content_type :json
            result.data.to_json
          elsif !result.authorized?
            halt 401
          else
            halt 400, result.message.to_json
          end
        end

      end

    end
  end
end
