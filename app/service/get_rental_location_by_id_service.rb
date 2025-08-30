module Service
  class GetRentalLocationByIdService

    def retrieve(id)
      sql = <<-SQL
        select id, name
        from rental_locations
        where id = ?;
      SQL

      results = Infraestructure::Query.run(sql, id)
      results.first
    end

  end
end
