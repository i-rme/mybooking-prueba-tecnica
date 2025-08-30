module Service
  class ListRateTypesForRentalLocationService

    def retrieve(rental_location_id)
      sql = <<-SQL
        select distinct rt.id, rt.name
        from rate_types rt
        join category_rental_location_rate_types crlrt on rt.id = crlrt.rate_type_id
        where crlrt.rental_location_id = ?
        order by rt.name;
      SQL

      Infraestructure::Query.run(sql, rental_location_id)
    end

  end
end
