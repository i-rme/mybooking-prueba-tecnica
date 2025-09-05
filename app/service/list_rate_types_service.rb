module Service
  class ListRateTypesService

    def retrieve(rental_location_id = nil)
      if rental_location_id && !rental_location_id.empty?
        sql = <<-SQL
          SELECT DISTINCT rt.id, rt.name
          FROM rate_types rt
          JOIN category_rental_location_rate_types crlrt ON rt.id = crlrt.rate_type_id
          WHERE crlrt.rental_location_id = ?
          ORDER BY rt.name;
        SQL

        Infraestructure::Query.run(sql, rental_location_id)
      else
        sql = <<-SQL
          select id, name
          from rate_types
          order by name;
        SQL

        Infraestructure::Query.run(sql)
      end
    end

  end
end
