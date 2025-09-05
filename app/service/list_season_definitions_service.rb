module Service
  class ListSeasonDefinitionsService

    def retrieve(rental_location_id = nil)
      if rental_location_id && !rental_location_id.empty?
        sql = <<-SQL
          SELECT DISTINCT sd.id, sd.name
          FROM season_definitions sd
          JOIN season_definition_rental_locations sdl ON sd.id = sdl.season_definition_id
          WHERE sdl.rental_location_id = ?
          ORDER BY sd.name;
        SQL

        Infraestructure::Query.run(sql, rental_location_id)
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
