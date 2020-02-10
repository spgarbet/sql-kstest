-- This returns the category, units and count for each 
-- It assume NULL units are FALSE (reflects real world case)
SELECT category,
       COALESCE(units,FALSE) AS units,
       COUNT(*) AS N
  FROM measurements
 GROUP BY category,
          COALESCE(units,FALSE)
;

-- This uses the results of the previous to compute weights
SELECT m.category,
       m.value,
       COALESCE(m.units,FALSE) AS units,
       c.N AS N,
       CASE WHEN c.units THEN c.N ELSE 0   END AS Nx,
       CASE WHEN c.units THEN 0   ELSE c.N END AS Ny,
       (CASE WHEN m.units THEN 1.0 ELSE -1.0 END)/CAST(c.N AS NUMERIC) AS weight
  FROM measurements m
 INNER JOIN (SELECT category,
                    COALESCE(units,FALSE) AS units,
                    COUNT(*) AS N
               FROM measurements
              GROUP BY category,
                       COALESCE(units,FALSE)
             ) c 
       ON m.category=c.category AND
          COALESCE(m.units,FALSE)=c.units
;

-- Now for using the previous to compute the running weight and N values.
SELECT category,
       SUM(weight) OVER (PARTITION BY category ORDER BY value) AS w,
       Nx,
       Ny
  FROM (SELECT m.category AS category,
               m.value,
               CASE WHEN c.units THEN c.N ELSE 0   END AS Nx,
               CASE WHEN c.units THEN 0   ELSE c.N END AS Ny,
               --COALESCE(m.units,FALSE) AS units,
               (CASE WHEN m.units THEN 1.0 ELSE -1.0 END)/CAST(c.N AS NUMERIC) AS weight
          FROM measurements m
         INNER JOIN (SELECT category,
                            COALESCE(units,FALSE) AS units,
                            COUNT(*) AS N
                       FROM measurements
                      GROUP BY category,
                               COALESCE(units,FALSE)
                     ) c 
               ON m.category=c.category AND
                  COALESCE(m.units,FALSE)=c.units
       ) ks
;

-- Bring it together to compute the D statistic by category
SELECT category,
       MAX(ABS(w)) AS D,
       MAX(Nx)     AS Nx,
       MAX(Ny)     AS Ny
  FROM
(
SELECT category,
       SUM(weight) OVER (PARTITION BY category ORDER BY value) AS w,
       Nx,
       Ny
  FROM (SELECT m.category AS category,
               m.value,
               CASE WHEN c.units THEN c.N ELSE 0   END AS Nx,
               CASE WHEN c.units THEN 0   ELSE c.N END AS Ny,
               --COALESCE(m.units,FALSE) AS units,
               (CASE WHEN m.units THEN 1.0 ELSE -1.0 END)/CAST(c.N AS NUMERIC) AS weight
          FROM measurements m
         INNER JOIN (SELECT category,
                            COALESCE(units,FALSE) AS units,
                            COUNT(*) AS N
                       FROM measurements
                      GROUP BY category,
                               COALESCE(units,FALSE)
                     ) c 
               ON m.category=c.category AND
                  COALESCE(m.units,FALSE)=c.units
       ) ks
) ws
 GROUP BY category
;