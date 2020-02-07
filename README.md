# sql-ksttest
SQL code to compute the Kolmogorov–Smirnov test statistic

This repository is geared at computing the Kolmogorov-Smirnov test statistic directly
from SQL.

# FAQ

1) Why would anyone in their right mind attempt such a thing?

Round trips to the database are very expensive, and the dataset the test is required on is a massive set of data. The operation required are not that terrible, and the hope is that the SQL optimizer will be able to do this more effectively than round-tripping huge sets of data with the KS algorithm in code.

# Example R Code 

This is the method proposed. The output needed is n.x, n.y, and the D-statistic (max(abs(z)) for a two-sample test.

    set.seed(12345)     
    x <- rnorm(10)
    y <- rnorm(10)
    ks.test(x, y) # D=0.3
    
    n <- length(x)
    n.x <- as.double(n)
    n.y <- length(y)
    
    n <- n.x * n.y/(n.x + n.y)
    w <- c(x, y)
    z <- cumsum(ifelse(order(w) <= n.x, 1/n.x, -1/n.y))
    max(abs(z))


