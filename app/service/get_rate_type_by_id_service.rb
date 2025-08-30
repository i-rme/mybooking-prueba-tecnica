module Service
  class GetRateTypeByIdService

    def retrieve(id)
      sql = <<-SQL
        select id, name
        from rate_types
        where id = ?;
      SQL

      results = Infraestructure::Query.run(sql, id)
      results.first
    end

  end
end
