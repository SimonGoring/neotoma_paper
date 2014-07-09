compile_it <-function(x){
  
  if(class(x) == 'list'){
    
    if(is.null(x$metadata$site.data$SiteName)) x$metadata$site.data$SiteName <- paste('NoName_ID', i)
    if(is.null(x$sample.meta$depths)) x$sample.meta$depths <- NA
    if(is.null(x$sample.meta$Age)) x$sample.meta$Age <- NA
    if(is.null(x$metadata$site.data$LatitudeNorth)) x$metadata$site.data$LatitudeNorth <- NA
    if(is.null(x$metadata$site.data$LongitudeWest)) x$metadata$site.data$LongitudeWest <- NA
    
    site.info <- data.frame(sitename = x$metadata$site.data$SiteName,
                            depth = x$sample.meta$depths,
                            age = x$sample.meta$Age,
                            ageold = x$sample.meta$AgeOlder,
                            ageyoung = x$sample.meta$AgeYounger,                            
                            date.type = x$sample.meta$AgeType,
                            lat = x$metadata$site.data$LatitudeNorth,
                            long = x$metadata$site.data$LongitudeWest,
                            dataset = x$metadata$site.data$SiteName,
                            x$counts)
    
  }
  if(!class(x) == 'list'){
    site.info <- data.frame(sitename = NA,
                            depth = NA,
                            age = NA,
                            ageold = x$sample.meta$AgeOlder,
                            ageyoung = x$sample.meta$AgeYounger,
                            date.type = NA,
                            lat = NA,
                            long = NA,
                            dataset = NA,
                            PINUSX = NA)
  }
  return(site.info)
}