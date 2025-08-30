module Service
  class ListSeasonsService

    def retrieve

      sql = <<-SQL
        select s.id, s.name, s.season_definition_id, sd.name as season_definition_name
        from seasons s
        join season_definitions sd on s.season_definition_id = sd.id
        order by sd.name, s.name;
      SQL

      Infraestructure::Query.run(sql)

    end

  end
end
