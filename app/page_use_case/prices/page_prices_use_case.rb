module PageUseCase
  module Prices
    #
    # Page use case for prices
    #
    class PagePricesUseCase

      Result = Struct.new(:success?, :authorized?, :data, :message, keyword_init: true)

      #
      # Initialize the use case
      #
      # @param [Logger] logger
      #
      def initialize(logger)
        @logger = logger
      end

      #
      # Perform the use case
      #
      # @param [User] user
      # @param [Integer] booking_id
      #
      # @return [Result]
      #
      def perform(params)

        processed_params = process_params(params)

        # Check valid
        unless processed_params[:valid]
          return Result.new(success?: false, authorized?: true, message: processed_params[:message])
        end

        # Check authorization
        unless processed_params[:authorized]
          return Result.new(success?: true, authorized?: false, message: 'Not authorized')
        end

        # Return the result
        return Result.new(success?: true, authorized?: true, data: "Prices page content")

      end

      private

      #
      # Process the parameters
      #
      # @return [Hash]
      #
      def process_params(params)

        return { valid: true, authorized: true }

      end

    end
  end
end
