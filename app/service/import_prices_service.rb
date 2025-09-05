require 'csv'

module Service
  class ImportPricesService

    def initialize
      @category_repo = Repository::CategoryRepository.new
      @rental_location_repo = Repository::RentalLocationRepository.new
      @rate_type_repo = Repository::RateTypeRepository.new
      @season_repo = Repository::SeasonRepository.new
      @crlrt_repo = Repository::CategoryRentalLocationRateTypeRepository.new
      @price_repo = Repository::PriceRepository.new
      @price_definition_repo = Repository::PriceDefinitionRepository.new
    end

    def import(csv_content)
      errors = []
      CSV.parse(csv_content, headers: true) do |row|
        begin
          process_row(row)
        rescue => e
          errors << "Error in row #{row.inspect}: #{e.message}"
        end
      end
      errors
    end

    private

    def process_row(row)
      rental_location_id = row['rental_location'].to_i
      rate_type_id = row['rate_type'].to_i
      season_definition_id = row['season_definition'].to_i
      time_measurement_int = row['time_measurement'].to_i
      units = row['units'].to_i
      price_value = row['price'].to_f
      included_km = row['included_km'].to_i
      extra_km_price = row['extra_km_price'].to_f
      price_definition_id = row['price_definition_id'].to_i
      season_id = row['season_id'].to_i
      season_id = nil if season_id == 0

      # Convert time_measurement integer to symbol for DataMapper
      time_measurement = case time_measurement_int
                         when 1 then :months
                         when 2 then :days
                         when 3 then :hours
                         when 4 then :minutes
                         else :days
                         end

      # Validate that price_definition_id exists
      pd = @price_definition_repo.find_by_id(price_definition_id)
      raise "PriceDefinition with id #{price_definition_id} not found" unless pd

      # Validate units based on time_measurement and price_definition configuration
      case time_measurement_int
      when 1 # months
        if pd.units_management_value_months_list
          allowed_units = pd.units_management_value_months_list.split(',').map(&:to_i)
          raise "Units #{units} not allowed for months in price definition #{price_definition_id}" unless allowed_units.include?(units)
        end
      when 2 # days
        if pd.units_management_value_days_list
          allowed_units = pd.units_management_value_days_list.split(',').map(&:to_i)
          raise "Units #{units} not allowed for days in price definition #{price_definition_id}" unless allowed_units.include?(units)
        end
      when 3 # hours
        if pd.units_management_value_hours_list
          allowed_units = pd.units_management_value_hours_list.split(',').map(&:to_i)
          raise "Units #{units} not allowed for hours in price definition #{price_definition_id}" unless allowed_units.include?(units)
        end
      when 4 # minutes
        if pd.units_management_value_minutes_list
          allowed_units = pd.units_management_value_minutes_list.split(',').map(&:to_i)
          raise "Units #{units} not allowed for minutes in price definition #{price_definition_id}" unless allowed_units.include?(units)
        end
      else
        raise "Invalid time_measurement: #{time_measurement_int}"
      end

      # Find or create Price
      existing_price = @price_repo.find_all(conditions: { 
        price_definition_id: price_definition_id, 
        season_id: season_id, 
        time_measurement: time_measurement, 
        units: units 
      }).first

      if existing_price
        # Update existing price
        existing_price.price = price_value
        existing_price.included_km = included_km
        existing_price.extra_km_price = extra_km_price
        result = @price_repo.save(existing_price)
        unless result
          raise "Failed to update price: #{existing_price.errors.full_messages.join(', ')}" if existing_price.respond_to?(:errors) && existing_price.errors.any?
          raise "Model::Price#save returned false, Model::Price was not saved"
        end
      else
        # Create new price
        new_price = Model::Price.new(
          price_definition_id: price_definition_id,
          season_id: season_id,
          time_measurement: time_measurement,
          units: units,
          price: price_value,
          included_km: included_km,
          extra_km_price: extra_km_price
        )
        result = @price_repo.save(new_price)
        unless result
          raise "Failed to create price: #{new_price.errors.full_messages.join(', ')}" if new_price.respond_to?(:errors) && new_price.errors.any?
          raise "Model::Price#save returned false, Model::Price was not saved"
        end
      end
    end
  end
end

