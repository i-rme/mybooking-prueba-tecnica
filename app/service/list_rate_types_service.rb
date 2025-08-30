module Service
  class ListRateTypesService

    def retrieve

      sql = <<-SQL
        select id, name
        from rate_types
        order by name;
      SQL

      Infraestructure::Query.run(sql)

    end

  end
end
