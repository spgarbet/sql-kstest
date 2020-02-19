WITH
  Counts (category, units, N) AS
    (SELECT category,
            COALESCE(units,FALSE) AS units,
            COUNT(*) AS N
       FROM measurements
      GROUP BY category, COALESCE(units,FALSE)
    ),
  Weights (category, value, units, N, Nx, Ny, weight) AS
    (SELECT m.category,
            m.value,
            COALESCE(m.units,FALSE) AS units,
            c.N AS N,
            CASE WHEN c.units THEN c.N ELSE 0   END AS Nx,
            CASE WHEN c.units THEN 0   ELSE c.N END AS Ny,
            (CASE WHEN m.units THEN 1.0 ELSE -1.0 END)/CAST(c.N AS NUMERIC) AS weight
       FROM measurements m
      INNER JOIN Counts c ON m.category=c.category AND
                             COALESCE(m.units,FALSE)=c.units
     ),
  CumSum (category, w, Nx, Ny) AS
     (SELECT category,
             SUM(weight) OVER (PARTITION BY category ORDER BY value) AS w,
             Nx,
             Ny
        FROM Weights
     )
SELECT category,
       MAX(ABS(w)) AS D,
       MAX(Nx)     AS Nx,
       MAX(Ny)     AS Ny
  FROM CumSum
 GROUP BY category;