module Service
  class ListActualPricesService

    def retrieve(rental_location_id: 1, rate_type_id: 1, season_definition_id: 1, season_id: 0, time_measurement: 1)

sql = <<-SQL
-- Parámetros: :rental_location_id, :rate_type_id, :season_definition_id, :season_id, :time_measurement
SELECT
  c.code  AS category_code,
  c.name  AS category_name,
  rl.name AS rental_location_name,
  rt.name AS rate_type_name,
  COALESCE(s.name, 'Sin temporada') AS season_name,
  p.time_measurement,
  p.units,
  p.price,
  p.included_km,
  p.extra_km_price,
  pd.deposit,
  pd.excess,
  pd.id AS price_definition_id,
  p.id  AS price_id
FROM category_rental_location_rate_types crlrt
JOIN price_definitions pd  ON pd.id = crlrt.price_definition_id
JOIN prices p              ON p.price_definition_id = pd.id
LEFT JOIN seasons s        ON s.id = p.season_id
JOIN categories c          ON c.id = crlrt.category_id
JOIN rental_locations rl   ON rl.id = crlrt.rental_location_id
JOIN rate_types rt         ON rt.id = crlrt.rate_type_id
LEFT JOIN season_definition_rental_locations sdrl
  ON sdrl.rental_location_id = rl.id
 AND sdrl.season_definition_id = COALESCE(pd.season_definition_id, s.season_definition_id)
WHERE rl.id = ? -- rental_location_id
  AND rt.id = ? -- rate_type_id
  AND (
        -- SIN temporada (compat: season_definition_id=0 y season_id=0)
        (CAST(? AS UNSIGNED)=0 -- season_definition_id
         AND pd.season_definition_id IS NULL
         AND (p.season_id IS NULL OR CAST(? AS UNSIGNED)=0)) -- season_id

        -- CON temporada (si season_id=0, trae TODAS; acepta pd.sd_id NULL si la season del precio pertenece al conjunto)
        OR (CAST(? AS UNSIGNED)<>0 -- season_definition_id
            AND COALESCE(pd.season_definition_id, s.season_definition_id) = CAST(? AS UNSIGNED) -- season_definition_id
            AND (CAST(? AS UNSIGNED)=0 OR p.season_id = CAST(? AS UNSIGNED)) -- season_id, season_id
            AND sdrl.id IS NOT NULL) -- el conjunto de temporadas aplica en la sucursal
      )
  AND p.time_measurement = ? -- time_measurement
ORDER BY c.code, COALESCE(s.name,'ZZZ'), p.units;
      SQL

      args = [rental_location_id, rate_type_id,
              season_definition_id, season_id,
              season_definition_id, season_definition_id,
              season_id, season_id,
              time_measurement]
       Infraestructure::Query.run(sql, *args)

    end

  end
end
