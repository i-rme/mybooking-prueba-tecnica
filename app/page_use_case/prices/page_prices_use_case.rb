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

        # Mock data
        data = OpenStruct.new(
          rental_locations: [
            OpenStruct.new(id: 1, name: "Centro Madrid"),
            OpenStruct.new(id: 2, name: "Aeropuerto Barajas"),
            OpenStruct.new(id: 3, name: "Estación Atocha"),
            OpenStruct.new(id: 4, name: "Plaza Castilla")
          ],
          rate_types: [
            OpenStruct.new(id: 1, name: "Diaria"),
            OpenStruct.new(id: 2, name: "Semanal"),
            OpenStruct.new(id: 3, name: "Mensual"),
            OpenStruct.new(id: 4, name: "Anual")
          ],
          season_definitions: [
            OpenStruct.new(id: 1, name: "Temporada Alta"),
            OpenStruct.new(id: 2, name: "Temporada Media"),
            OpenStruct.new(id: 3, name: "Temporada Baja")
          ],
          seasons: [
            OpenStruct.new(id: 1, name: "Verano 2024"),
            OpenStruct.new(id: 2, name: "Invierno 2024"),
            OpenStruct.new(id: 3, name: "Primavera 2024"),
            OpenStruct.new(id: 4, name: "Otoño 2024")
          ],
          price_periods: [
            "1 día", "2-3 días", "4-7 días", "8-15 días", "16-30 días", "31+ días"
          ],
          prices: [
            OpenStruct.new(category: "Económico", prices: ["15.00€","13.50€","12.00€","10.50€","9.00€","8.00€"]),
            OpenStruct.new(category: "Estándar",  prices: ["25.00€","22.50€","20.00€","17.50€","15.00€","13.00€"]),
            OpenStruct.new(category: "Premium",   prices: ["35.00€","31.50€","28.00€","24.50€","21.00€","18.00€"]),
            OpenStruct.new(category: "Lujo",      prices: ["50.00€","45.00€","40.00€","35.00€","30.00€","25.00€"]),
            OpenStruct.new(category: "SUV",       prices: ["40.00€","36.00€","32.00€","28.00€","24.00€","20.00€"])
          ],
          message: "Precios cargados correctamente"
        )

        # Return the result
        return Result.new(success?: true, authorized?: true, data: data)

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
