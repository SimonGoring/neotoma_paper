compile_it <-function(x){
  
#   if(class(x) == 'list'){
  if ('list' %in% class(x)) {
    
    if(is.null(x$metadata$site.data$sitename)) x$metadata$site.data$sitename <- paste('NoName_ID', i)
    if(is.null(x$sample.meta$depths)) x$sample.meta$depths <- NA
    if(is.null(x$sample.meta$Age)) x$sample.meta$Age <- NA
    if(is.null(x$metadata$site.data$lat)) x$metadata$site.data$lat <- NA
    if(is.null(x$metadata$site.data$long)) x$metadata$site.data$long <- NA
    
    site.info <- data.frame(sitename = x$metadata$site.data$sitename,
                            depth = x$sample.meta$depths,
                            age = x$sample.meta$Age,
                            ageold = x$sample.meta$AgeOlder,
                            ageyoung = x$sample.meta$AgeYounger,                            
                            date.type = x$sample.meta$AgeType,
                            lat = x$metadata$site.data$lat,
                            long = x$metadata$site.data$long,
                            dataset = x$metadata$site.data$siteid,
                            x$counts)
    
  }
#   if(class(x) != 'list'){
  if(!('list' %in% !class(x))){
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