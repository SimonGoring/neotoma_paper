
## ----setup-knitr, echo = FALSE, message = FALSE--------------------------
# Simon: Note that these are global options that apply to all chunks below.
knitr::opts_chunk$set(
  comment = " ",
  error = FALSE,
  # Note: I have set EVAL to false just to make the bib work. 
  # Once the bib is fixed, you'll set this to TRUE or just delete this line.
  eval = TRUE,
  cache = TRUE,
  tidy = FALSE
  # Note to @gavinsimpson, I think this is now a knitr issue.
  # I'll file a bug PR with knitr
)



library("pander")
library("plyr")
panderOptions('table.style', 'rmarkdown')


## ----load-pkgs-1-code, echo = FALSE, warning = FALSE, message = FALSE----
library("neotoma")
suppressPackageStartupMessages(library("analogue"))


## ----load-pkgs-1---------------------------------------------------------
library("neotoma")
marion <- get_site(sitename = 'Marion Lake%')
louise <- get_site(sitename = 'Louise Pond%')
louise


## ----get-dataset-simple--------------------------------------------------
western.sites <- rbind(marion, louise)
western.data  <- get_dataset(western.sites)


## ----print-dataset-simple------------------------------------------------
western.data
western.data[[1]]


## ----download-western.data-----------------------------------------------
western.dl <- get_download(western.data)
western.dl
western.dl[[1]]


## ----kable-western-codeonly, results='asis', eval = FALSE----------------
## head(western.dl[[1]]$taxon.list)


## ----kable-western, results = 'asis', echo = FALSE-----------------------
df <- unrowname(western.dl[[1]]$taxon.list)
pandoc.table(head(df), justify = "left")


## ----compile-taxa-western, echo = TRUE, message = FALSE, warning = FALSE----
western.comp <- compile_taxa(western.dl, list.name = 'P25')
names(western.comp) <- c("marion", "louise")


## ----kable-wstern-2-codeonly, results = 'asis', echo = TRUE, eval = FALSE----
## head(western.comp[[1]]$taxon.list[,c(1, 5, 6)])

## ----kable-wstern-2, results = 'asis', echo = FALSE----------------------
# The previous block shows just the code necesssary but skips the formatting parts needed to make the table play nice with pandoc
pandoc.table(head(western.comp[[1]]$taxon.list[,c(1, 5, 6)]), justify = "left")


## ----fig-3alnus-data-plot, dpi=300, dev=c('png','postscript','tiff')-----
library("analogue")

marion.alnus <- tran(x = western.comp$marion$counts, method = 'percent')[,'Alnus']
louise.alnus <- tran(x = western.comp$louise$counts, method = 'percent')[,'Alnus']

alnus.df <- data.frame(alnus = c(marion.alnus, louise.alnus),
                       ages  = c(western.comp$marion$sample.meta$age,
                                 western.comp$louise$sample.meta$age),
                       site = c(rep('Marion', length(marion.alnus)),
                                rep('Louise', length(louise.alnus))))

plot(alnus ~ ages, data = alnus.df, col = alnus.df$site, pch = 19,
     xlab = 'Years Before Present', ylab = 'Percent Alnus')


## ----, fig-4marion-plot, fig.height=6, fig.width=6, echo=TRUE, message=FALSE, warning=FALSE, dpi=300, dev=c('png','postscript','tiff')----
core.pct <- data.frame(tran(western.comp[[1]]$counts, method = "percent"))
core.pct$age <- western.comp[[1]]$sample.meta$age
#  Eliminate taxa with no samples greater than 4%.
core.pct <- chooseTaxa(core.pct, max.abun = 4)
Stratiplot(age ~ ., core.pct, sort = 'wa', type = 'poly',
           ylab = "Years Before Present")


## ----load-pkgs-example-2, echo = TRUE, message=FALSE, warning = FALSE----
#install.packages('ggmap', 'ggplot2', 'reshape2', 'Bchron', 'gridExtra')
library("ggmap")
library("ggplot2")
library("reshape2")
library("Bchron")
library("gridExtra")

all.sites <- get_site(loc = c(-140, 45, -110, 65))


## ----all-datasets-pinus, echo = TRUE, message = FALSE, warning = FALSE----
all.datasets <- get_dataset(loc = c(-140, 45, -110, 65),
                            datasettype = 'pollen',
                            taxonname = 'Pinus%')


## ----fig-5-map-pinus-example, echo = TRUE, message = FALSE, warning = FALSE, dpi=300, dev=c('png','postscript','tiff')----
map <- map_data('world')
ggplot(data = data.frame(map), aes(long, lat)) + 
  geom_polygon(aes(group=group), color = 'steelblue', alpha = 0.2) +
  geom_point(data = all.sites, aes(x = long, y = lat)) +
  geom_point(data = get_site(all.datasets),
  aes(x = long, y = lat), color = 2) +
  xlab('Longitude West') + 
  ylab('Latitude North') +
  coord_map(projection = 'albers', lat0 = 40, lat1 = 65, 
            xlim = c(-140, -110), ylim = c(45, 70))


## ----get-downloads-pinus, echo = TRUE, message = FALSE, warning = FALSE----
all.downloads <- get_download(all.datasets, verbose = FALSE)


## ----pinus-compile, message = FALSE, warning = FALSE---------------------
compiled.cores <- compile_taxa(all.downloads, 'P25')


## ----pinus-first-occur, echo = TRUE, warning = FALSE---------------------
top.pinus <- function(x) {
  x.pct <- tran(x$counts, method = "proportion")
  #  Cores must span at least the last 5000 years (and have no missing dates):
  old.enough <- max(x$sample.meta$age) > 5000 & !all(is.na(x$sample.meta$age))
  #  Find the highest row index associated with Pinus presence over 5%
  oldest.row <- ifelse(any(x.pct[, 'Pinus'] > .05 & old.enough),
                       max(which(x.pct[, 'Pinus'] > .05)),
                       0)
  #  return a data.frame with site name & location, and the age and date type
  #  (since some records have ages in radiocarbon years) for the oldest Pinus.
  out <- if (oldest.row > 0) {
      data.frame(site = x$dataset$site.data$site.name,
                 lat = x$dataset$site.data$lat,
                 long = x$dataset$site.data$long,
                 age = x$sample.meta$age[oldest.row],
                 date = x$sample.meta$age.type[oldest.row])
  } else {
      NULL
  }
  out
}

#  Apply the function 'top.pinus' to each core using lapply and rbind:
summary.pinus <- do.call("rbind.data.frame", lapply(compiled.cores, top.pinus))


## ----fig-6-pinus-recal-plot, echo = TRUE, fig.width = 7, fig.height = 4, warning = FALSE, dpi=300, dev=c('png','postscript','tiff')----
radio.years <- summary.pinus$date %in% 'Radiocarbon years BP'
sryears <- sum(radio.years, na.rm = TRUE)
# BChronCalibrate is in the BChron package:
calibrated <- BchronCalibrate(summary.pinus$age[radio.years],
                              ageSds = rep(100, sryears),
                              calCurves = rep('intcal13', sryears))

#  we want the weighted means from 'calibrated'
wmean.date <- function(x) sum(x$ageGrid*x$densities / sum(x$densities))

summary.pinus$age[radio.years] <- sapply(calibrated, wmean.date)
summary.pinus <- na.omit(summary.pinus)
summary.pinus <- subset(summary.pinus, subset=!(age < 2000 & long < -130))

#  A loess curve is straightforward, but not the best model:
regress <- ggplot(summary.pinus, aes(x = lat, y = age)) +
                  geom_point(aes(color = age), size = 2) +
                  scale_y_reverse(expand = c(0, 100)) +
                  xlab('Latitude North') + 
                  ylab('Years Before Present') +
                  geom_smooth(n = 40, method = 'loess') +
                  geom_rect(aes(xmin = 59, xmax = 60, ymin = 7000, ymax = 10000), 
                  color = 2, fill = 'blue', alpha = 0.01)

mapped <- ggplot(data = data.frame(map), aes(long, lat)) + 
                 geom_polygon(aes(group = group), color = 'steelblue', alpha = 0.2) +
                 geom_point(data = summary.pinus, 
                 aes(x = long, y = lat, colour = age), size = 3) +
                 coord_map(projection = 'albers', lat0 = 40, lat1 = 65, 
                 xlim = c(-140, -110), ylim = c(40, 70)) +
                 theme(legend.position = 'none')

grid.arrange(mapped, regress, nrow=1)


## ----mammal-example, message = FALSE, warning = FALSE, echo = TRUE-------
#  Bounding box is effectively the continental USA, excluding Alaska
mam.set <- get_dataset(datasettype= 'vertebrate fauna',
                       loc = c(-125, 24, -66, 49.5))
#  Retrieving this many sites can be very time consuming
mam.dl <- get_download(mam.set)


## ----mammal-example-compile, echo = TRUE, message = FALSE, warning = FALSE----
compiled.mam <- compile_downloads(mam.dl)
time.bins <- c(500, 4000, 10000, 15000, 20000)
mean.age <- rowMeans(compiled.mam[,c('age.old', 'age.young', 'age')],
                     na.rm = TRUE)
interval <- findInterval(mean.age, time.bins)
periods <- c('Modern', 
             'Late Holocene', 
             'Early-Mid Holocene', 
             'Late Glacial', 
             'Full Glacial', 
             'Late Pleistocene')
compiled.mam$ageInterval <- periods[interval + 1]
mam.melt <- melt(compiled.mam,
                 measure.vars = 10:(ncol(compiled.mam)-1),
                 na.rm = TRUE,
                 factorsAsStrings = TRUE)
mam.melt <- transform(mam.melt, ageInterval = factor(ageInterval, levels = periods))
mam.lat <- dcast(data = mam.melt, variable ~ ageInterval, value.var = 'lat',
                 fun.aggregate = mean, drop = TRUE)[,c(1, 3, 5, 6)]
#  We only want taxa that appear at all time periods:
mam.lat <- mam.lat[rowSums(is.na(mam.lat)) == 0, ]
#  Group the samples based on the range & direction (N vs S) of migration.
#  A shift of only 1 degree is considered stationary.
mam.lat$grouping <- factor(findInterval(mam.lat[,2] - mam.lat[, 4],
                                        c(-11, -1, 1, 20)),
                           labels = c('Southward', 'Stationary', 'Northward'))
mam.lat.melt <- melt(mam.lat)
colnames(mam.lat.melt)[2:3] <- c('cluster', 'Era')


## ----fig-7-mammal-example-plot, fig.width = 7, fig.height = 4, echo = TRUE, warning = FALSE, dpi=300, dev = c('png','postscript','tiff')----
ggplot(mam.lat.melt, aes(x = Era, y = value)) + 
  geom_path(aes(group = variable, color = cluster)) + 
  facet_wrap(~ cluster) +
  scale_x_discrete(expand = c(.1,0)) +
  ylab('Mean Latitude of Occurrance') +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


