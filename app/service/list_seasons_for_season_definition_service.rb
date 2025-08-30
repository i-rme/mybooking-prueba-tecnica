module Service
  class ListSeasonsForSeasonDefinitionService

    def retrieve(season_definition_id)
      sql = <<-SQL
        select s.id, s.name
        from seasons s
        where s.season_definition_id = ?
        order by s.name;
      SQL

      Infraestructure::Query.run(sql, season_definition_id)
    end

  end
end
