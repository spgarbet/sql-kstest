set.seed(12345)     

x <- rnorm(10)
y <- rnorm(10)



cat(paste0("('A',",x,',TRUE),\n'), sep='')
cat(paste0("('A',",y,',NULL),\n'), sep='')

u <- rnorm(7)
v <- rexp(11)

cat(paste0("('B',",x,',TRUE),\n'), sep='')
cat(paste0("('B',",y,',NULL),\n'), sep='')

print(ks.test(x,y))
print(ks.test(u,v))

