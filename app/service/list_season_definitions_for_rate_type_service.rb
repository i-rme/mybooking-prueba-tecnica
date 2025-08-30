module Service
  class ListSeasonDefinitionsForRateTypeService

    def retrieve(rate_type_id, rental_location_id)
      sql = <<-SQL
        select distinct sd.id, sd.name
        from season_definitions sd
        join price_definitions pd on sd.id = pd.season_definition_id
        join season_definition_rental_locations sdrl on sd.id = sdrl.season_definition_id
        where pd.rate_type_id = ? and sdrl.rental_location_id = ?
        order by sd.name;
      SQL

      Infraestructure::Query.run(sql, rate_type_id, rental_location_id)
    end

  end
end
