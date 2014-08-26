can_map <- get_map(location=c(-140, 45, -110, 65))
ggmap(can_map) + geom_point(data = all.sites, aes(x = long, y = lat))

plot(all.sites$x, all.sites$y)


cc1 <- read.csv("intcal13.txt", header=FALSE, sep=' ')


Bchroncal <- function (ages, ageSds, ids = NULL, positions = NULL, 
          pathToCalCurves = system.file("data", package = "Bchron"), 
          eps = 1e-05, dfs = rep(100, length(ages))) 
{
  calCurve = as.matrix(read.table("intcal13.txt"))
  
  if (is.null(ids)) 
    ids = paste("date", 1:length(ages), sep = "")
  if (!all(as.integer(ages) == ages)) {
    ages = round(ages, 0)
    warning("ages not given as whole numbers - rounding occurred")
  }
  if (!all(as.integer(ageSds) == ageSds)) {
    ageSds = pmax(round(ageSds, 0), 1)
    warning("ageSds not given as whole numbers - rounding occurred")
  }
  calBP = calCurve[, 1]
  c14BP = calCurve[, 2]
  calSd = calCurve[, 3]
  ageGrid = seq(min(calBP), max(calBP), by = 1)
  mu = approx(calBP, c14BP, xout = ageGrid)$y
  tau1 = approx(calBP, calSd, xout = ageGrid)$y
  
  out = list()
  for (i in 1:length(ages)) {
    
    if (ages[i] > max(ageGrid) | ages[i] < min(ageGrid)) 
      stop(paste("Date", ids[i], "outside of calibration range"))
    
    tau = ageSds[i]^2 + tau1
    dens = dt((ages[i] - mu)/sqrt(tau), df = dfs[i])
    dens = dens/sum(dens)
    out[[i]] = list(ages = ages[i], ageSds = ageSds[i], ageGrid = ageGrid[dens > eps], densities = dens[dens > eps])
  }

  names(out) = ids
  class(out) = "BchronCalibratedDates"
  return(out)
}


calibrated <- Bchroncal(ages=summary.pinus$age[radio.years],
                              ageSds = rep(100, sum(radio.years, na.rm=TRUE)))
