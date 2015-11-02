panel.hist <- function(x, ...)
{ usr <- par("usr"); on.exit(par(usr))
par(usr = c(usr[1:2], 0, 1.5) )
h <- hist(x, plot = FALSE, col ="lightblue")
breaks <- h$breaks; nB <- length(breaks)
y <- h$counts; y <- y/max(y)
rect(breaks[-nB], 0, breaks[-1], y, col="cyan", ...)
}
panel.blank <- function(x, y)
{ }
panel.cor <- function(x, y, digits=2, prefix="", cex.cor)
{
    usr <- par("usr"); on.exit(par(usr))
    par(usr = c(0, 1, 0, 1))
    r <- abs(cor(x, y))
    txt <- format(c(r, 0.123456789), digits=digits)[1]
    txt <- paste(prefix, txt, sep="")
    if(missing(cex.cor)) cex <- 1.2/strwidth(txt)
    text(0.5, 0.5, txt, cex = cex * r)
   #     text(0.5, 0.5, txt, cex = cex)
}
pannel.lm <- function(x, y)
{
    points(x,y)
    abline(lm(y~x))
    lines(lowless(y,x),col="red")
}
