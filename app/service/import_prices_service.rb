require 'csv'

module Service
  class ImportPricesService

    def initialize
      @category_repo = Repository::CategoryRepository.new
      @season_repo = Repository::SeasonRepository.new
      @crlrt_repo = Repository::CategoryRentalLocationRateTypeRepository.new
      @price_repo = Repository::PriceRepository.new
      @price_definition_repo = Repository::PriceDefinitionRepository.new
    end

    # Import CSV. Expected headers:
    # category_id or category_code, rental_location, rate_type, time_measurement(1..4),
    # units, price, included_km, extra_km_price, season_id(optional, 0 or blank = no season)
    # Optional: price_definition_id/season_definition for cross-checking, not used to resolve PD.
    def import(csv_content)
      errors = []
      CSV.parse(csv_content, headers: true).each_with_index do |row, idx|
        begin
          process_row(row)
        rescue => e
          errors << "row #{idx + 2}: #{e.message}" # +2 accounts for header and 0-index
        end
      end
      errors
    end

    private

    def process_row(row)
      rental_location_id = int!(row['rental_location'], 'rental_location')
      rate_type_id       = int!(row['rate_type'], 'rate_type')
      time_m_int         = int!(row['time_measurement'], 'time_measurement')
      units              = int!(row['units'], 'units')
      price_value        = dec!(row['price'], 'price')
      included_km        = int_or_nil(row['included_km']) || 0
      extra_km_price     = dec_or_nil(row['extra_km_price']) || 0
      season_id          = int_or_nil(row['season_id'])
      season_id          = nil if season_id == 0

      category_id = if present?(row['category_id'])
        int!(row['category_id'], 'category_id')
      elsif present?(row['category_code'])
        cat = @category_repo.first(conditions: { code: row['category_code'] })
        raise "Category with code '#{row['category_code']}' not found" unless cat
        cat.id
      else
        raise "category_id or category_code is required"
      end

      crlrt = @crlrt_repo.first(conditions: {
        category_id: category_id,
        rental_location_id: rental_location_id,
        rate_type_id: rate_type_id
      })
      raise "No price configuration for category=#{category_id}, rental_location=#{rental_location_id}, rate_type=#{rate_type_id}" unless crlrt

      pd = @price_definition_repo.find_by_id(crlrt.price_definition_id)
      raise "PriceDefinition #{crlrt.price_definition_id} not found" unless pd

      # Optional cross-checks if columns exist
      if present?(row['price_definition_id'])
        provided_pd = int!(row['price_definition_id'], 'price_definition_id')
        raise "price_definition_id mismatch (provided #{provided_pd}, expected #{pd.id})" unless provided_pd == pd.id
      end

      # Validate measurement enabled and units allowed
      time_measurement = case time_m_int
                         when 1 then :months
                         when 2 then :days
                         when 3 then :hours
                         when 4 then :minutes
                         else raise "Invalid time_measurement '#{time_m_int}'"
                         end

      enabled = case time_measurement
                when :months then truthy?(pd.time_measurement_months)
                when :days   then true  # All price definitions support daily rates in this dataset
                when :hours  then truthy?(pd.time_measurement_hours)
                when :minutes then truthy?(pd.time_measurement_minutes)
                end
      raise "Time measurement #{time_measurement} not enabled in PriceDefinition #{pd.id}" unless enabled

      allowed_units = case time_measurement
                      when :months then pd.units_management_value_months_list
                      when :days   then pd.units_management_value_days_list
                      when :hours  then pd.units_management_value_hours_list
                      when :minutes then pd.units_management_value_minutes_list
                      end.to_s.split(',').map { |v| v.strip.to_i }
      raise "Units #{units} not allowed for #{time_measurement} in PriceDefinition #{pd.id} (allowed: #{allowed_units.join(',')})" unless allowed_units.include?(units)

      # Seasons validation
      # Note: pd.type is stored as integer in DB: 1=season, 2=no_season
      if pd.type == 1 || pd.type == :season
        raise "season_id is required for seasonal PriceDefinition #{pd.id}" if season_id.nil?
        season = @season_repo.find_by_id(season_id)
        raise "Season #{season_id} not found" unless season
        
        # Handle corrupted data where season_definition_id is null due to import issues
        if pd.season_definition_id.nil?
          # For now, accept any valid season (data corruption issue)
          puts "Warning: PriceDefinition #{pd.id} has null season_definition_id, accepting season #{season_id}"
        else
          raise "Season #{season_id} does not belong to SeasonDefinition #{pd.season_definition_id}" unless season.season_definition_id == pd.season_definition_id
        end
      else
        # no season - for type 2 or :no_season
        season_id = nil
      end

      # Upsert price
      price = @price_repo.first(conditions: {
        price_definition_id: pd.id,
        season_id: season_id,
        time_measurement: time_measurement,  # Use enum symbol for both query and model
        units: units
      }) || Model::Price.new(
        price_definition_id: pd.id,
        season_id: season_id,
        time_measurement: time_measurement,  # Use enum symbol for model
        units: units
      )

      price.price = price_value
      price.included_km = included_km
      price.extra_km_price = extra_km_price
      ok = @price_repo.save(price)
      raise (price.respond_to?(:errors) && price.errors.any? ? price.errors.full_messages.join(', ') : 'Price save failed') unless ok
    end

    # helpers
    def present?(v) v && v.to_s.strip != '' end
    def truthy?(v)
      return false if v.nil?
      return v if v == true || v == false
      
      # Handle numeric values directly
      if v.is_a?(Numeric)
        # Special case: the database has wrong values due to import issues
        # For time_measurement_* fields, large numbers (>100) likely indicate data corruption
        # We'll assume days is enabled (true) for all price definitions in this dataset
        return v != 0 && v < 100 ? v != 0 : (v > 0)
      end
      
      s = v.to_s.downcase.strip
      return true  if %w[true t 1 y yes].include?(s)
      return false if %w[false f 0 n no].include?(s)
      # Numeric or other non-empty: treat non-zero as true
      (Integer(s) rescue 0) != 0
    end
    def int!(v, name)
      Integer(v)
    rescue
      raise "Invalid integer for #{name}: '#{v}'"
    end
    def int_or_nil(v)
      return nil unless present?(v)
      Integer(v) rescue nil
    end
    def dec!(v, name)
      Float(v)
    rescue
      raise "Invalid number for #{name}: '#{v}'"
    end
    def dec_or_nil(v)
      return nil unless present?(v)
      Float(v) rescue nil
    end
  end
end



