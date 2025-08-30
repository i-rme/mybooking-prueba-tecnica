module Service
  class ListSeasonDefinitionsService

    def retrieve

      sql = <<-SQL
        select id, name
        from season_definitions
        order by name;
      SQL

      Infraestructure::Query.run(sql)

    end

  end
end
