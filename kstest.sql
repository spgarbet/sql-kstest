SELECT D,
       Nx,
       Ny
  FROM (SELECT MAX(ABS(cumsum)) AS D
          FROM (SELECT SUM(weight) OVER (ORDER BY value) AS cumsum
                  FROM (
                        SELECT value,
                               (SELECT 1.0/CAST(COUNT(*) AS NUMERIC)
                                  FROM measurements
                                 WHERE category='A') AS weight
                          FROM measurements
                         WHERE category = 'A'
                         UNION 
                        SELECT value,
                               (SELECT -1.0/CAST(COUNT(*) AS NUMERIC)
                                  FROM measurements
                                 WHERE category='B') AS weight
                          FROM measurements
                         WHERE category = 'B'
                        ) AS w
                 ORDER BY value
                ) AS z
        ) AS d,
        (SELECT COUNT(*) AS Nx
           FROM measurements
          WHERE category='A'
        ) AS nx,
        (SELECT COUNT(*) AS Ny
           FROM measurements
          WHERE category='B'
        ) AS ny
        