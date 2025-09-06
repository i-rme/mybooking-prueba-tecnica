# Solución

## Tarea 1
- Resultado accesible en /prices
- Se implementa en forma de API REST de modo que /prices cargue dinamicamente con JavaScript los criterios de filtrado adecuados
- Endpoint /api/rental_locations
- Endpoint /api/rate_types
- Endpoint /api/season_definitions
- Endpoint /api/seasons
- Endpoint /api/durations
- Endpoint /prices

### Decisiones de diseño
- Utilizar sample_task.html como diseño base para la solución
- Respetar arquitectura actual de Controllers, Views, UseCases, Services
- Utilizar un modelo Single Page Application en vez de un Server Side Rendering
- Devolver y enseñar todas las columnas de Prices en la tabla resultado
- Hacer que "Sin temporada" sea devuelto por el endpoint /api/seasons por homogeneizar
- Hacer que las "Duraciones" sean devueltas por el endpoint /api/durations por homogeneizar
- Que los parámetros de filtrado sean ids 
- Que los parámetros de filtrado sean opcionales

## Tarea 2
- Endpoint /api/import-prices que acepta multipart upload

### Decisiones de diseño
- Q: ¿Planterías la importación siguiendo estos filtros o añadirías las columnas de sucursal, tipo de tarifa y temporada?
- A: Bajo mi criterio, la importación debería no seguir los filtros seleccionados, ya que, por ejemplo si no hay precios para un tipo de tarifa no aparecerá en el desplegable por lo que no se podrá realizar la importación. Lo correcto sería añadir las columnas de sucursal, tipo de tarifa y temporada.
