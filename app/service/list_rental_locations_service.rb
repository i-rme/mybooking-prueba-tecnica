module Service
  class ListRentalLocationsService

    def retrieve

      sql = <<-SQL
        select id, name
        from rental_locations
        order by name;
      SQL

      Infraestructure::Query.run(sql)

    end

  end
end
