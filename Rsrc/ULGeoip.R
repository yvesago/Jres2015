#
# Usage:
#  source("ULGeoip.R")
#  tt <- lg[V3 == login]
#  tt[,speed := ULspeed(tt)]
#

library(sp)

ULspeed <- function(x) {
 goodrow <- 1
 res_speed <- c(0)
 res_speed[1] <- 0
 old_ip <- ""
 for(row in 2:dim(x)[1]) {
    if (is.na(x[row,c(long)]) | is.na(x[goodrow,c(long)]) ) {
      res_speed[row] <- 0
      goodrow <- goodrow + 1
    } else
    {
    res_speed[row] <-
       round( 3600 * spDistsN1(matrix(x[c(goodrow,row),c(long,lat)], ncol=2),
                      x[row,c(long,lat)], longlat = T)[1]/(x[row,diff]+0.001),0)
      goodrow<-row
    }
    old_ip <- x[row,V4]
    }
 rm(x)
 return(res_speed)
}
