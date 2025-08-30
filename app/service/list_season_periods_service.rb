module Service
  class ListSeasonPeriodsService

    def retrieve

      sql = <<-SQL
        select sp.id, sp.season_id, sp.start_date, sp.end_date, s.name as season_name
        from season_periods sp
        join seasons s on sp.season_id = s.id
        order by sp.start_date;
      SQL

      Infraestructure::Query.run(sql)

    end

  end
end
