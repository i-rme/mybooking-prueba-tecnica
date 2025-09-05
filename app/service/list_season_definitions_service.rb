module Service
  class ListSeasonDefinitionsService

    def retrieve(rental_location_id = nil, rate_type_id = nil)
      if rental_location_id && !rental_location_id.empty?
        if rate_type_id && !rate_type_id.empty?
          # Filter by rental location and rate type, only show season definitions with prices
          sql = <<-SQL
            SELECT DISTINCT sd.id, sd.name
            FROM season_definitions sd
            JOIN season_definition_rental_locations sdl ON sd.id = sdl.season_definition_id
            JOIN seasons s ON sd.id = s.season_definition_id
            JOIN prices p ON s.id = p.season_id
            JOIN price_definitions pd ON p.price_definition_id = pd.id
            JOIN category_rental_location_rate_types crlrt ON pd.id = crlrt.price_definition_id
            WHERE sdl.rental_location_id = ? AND crlrt.rate_type_id = ?
            ORDER BY sd.name;
          SQL

          Infraestructure::Query.run(sql, rental_location_id, rate_type_id)
        else
          # Filter only by rental location
          sql = <<-SQL
            SELECT DISTINCT sd.id, sd.name
            FROM season_definitions sd
            JOIN season_definition_rental_locations sdl ON sd.id = sdl.season_definition_id
            WHERE sdl.rental_location_id = ?
            ORDER BY sd.name;
          SQL

          Infraestructure::Query.run(sql, rental_location_id)
        end
      else
        sql = <<-SQL
          select id, name
          from season_definitions
          order by name;
        SQL

        Infraestructure::Query.run(sql)
      end
    end

  end
end
