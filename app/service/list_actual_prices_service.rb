module Service
  class ListActualPricesService

    def retrieve

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
        join rate_types rt on crlrt.rate_type_id = rt.id
        order by rl.name, rt.name, c.code, s.name, p.units;
      SQL

      Infraestructure::Query.run(sql)

    end

  end
end
