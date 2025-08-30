module Service
  class ListActualPricesService

    def retrieve(rental_location_name: 'Barcelona', rate_type_name: 'Estándar', season_definition_id: '1', season_id: '0')

      sql = <<-SQL
        select p.id, p.price_definition_id, p.season_id, p.time_measurement, p.units,
                  p.price, p.included_km, p.extra_km_price,
                  s.name as season_name,
                  c.code as category_code, c.name as category_name,
                  rl.name as rental_location_name,
                  rt.name as rate_type_name
            from prices p
            left join seasons s on p.season_id = s.id
            join category_rental_location_rate_types crlrt on p.id = crlrt.price_definition_id
            join categories c on crlrt.category_id = c.id
            join rental_locations rl on crlrt.rental_location_id = rl.id
            join season_definition_rental_locations sdrl on rl.id = sdrl.rental_location_id
            join rate_types rt on crlrt.rate_type_id = rt.id
        where rental_location_name = ? --sucursal
        and rate_type_name = ? --tipo de tarifa
        and sdrl.season_definition_id = ? -- grupo de temporadas
        and p.season_id = ? -- temporada:
        -- duracion falta
        order by rl.name, rt.name, c.code, s.name, p.units;
      SQL

      Infraestructure::Query.run(sql, rental_location_name, rate_type_name, season_definition_id, season_id)

    end

  end
end
