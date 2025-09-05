module Service
  class ListSeasonsService

    def retrieve(season_definition_id = nil)
      if season_definition_id && !season_definition_id.empty?
        sql = <<-SQL
          select s.id, s.name, s.season_definition_id, sd.name as season_definition_name
          from seasons s
          join season_definitions sd on s.season_definition_id = sd.id
          where s.season_definition_id = ?
          order by sd.name, s.name;
        SQL

        Infraestructure::Query.run(sql, season_definition_id)
      else
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
end
