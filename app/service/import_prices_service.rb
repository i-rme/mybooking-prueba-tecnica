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
      category_id = row['category_id'].to_i
      rental_location_id = row['rental_location_id'].to_i
      rate_type_id = row['rate_type_id'].to_i
      season_id = row['season_id'] && !row['season_id'].empty? ? row['season_id'].to_i : nil
      time_measurement = case row['time_measurement'].to_i
                         when 1 then :months
                         when 2 then :days
                         when 3 then :hours
                         when 4 then :minutes
                         else :days
                         end
      units = row['units'].to_i
      price_value = row['price'].to_f
      included_km = row['included_km'].to_i
      extra_km_price = row['extra_km_price'].to_f

      # Find category_rental_location_rate_type
      crlrt = @crlrt_repo.find_all(conditions: { category_id: category_id, rental_location_id: rental_location_id, rate_type_id: rate_type_id }).first
      raise "CategoryRentalLocationRateType not found" unless crlrt

      price_definition_id = crlrt.price_definition_id

      # Get price_definition to validate units
      pd = @price_definition_repo.find_by_id(price_definition_id)
      raise "PriceDefinition not found" unless pd

      # Assuming time_measurement 2 (days), check units_management_value_days_list
      if time_measurement == 2
        allowed_units = pd.units_management_value_days_list.split(',').map(&:to_i)
        raise "Units #{units} not allowed for this price definition" unless allowed_units.include?(units)
      end

      # Find or create Price
      existing_price = @price_repo.find_all(conditions: { price_definition_id: price_definition_id, season_id: season_id, time_measurement: time_measurement, units: units }).first

      if existing_price
        existing_price.price = price_value
        existing_price.included_km = included_km
        existing_price.extra_km_price = extra_km_price
        existing_price.time_measurement = time_measurement
        @price_repo.save(existing_price)
      else
        new_price = Model::Price.new(
          price_definition_id: price_definition_id,
          season_id: season_id,
          time_measurement: time_measurement,
          units: units,
          price: price_value,
          included_km: included_km,
          extra_km_price: extra_km_price
        )
        @price_repo.save(new_price)
      end
    end
  end
end

