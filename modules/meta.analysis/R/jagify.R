#-------------------------------------------------------------------------------
# Copyright (c) 2012 University of Illinois, NCSA.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the 
# University of Illinois/NCSA Open Source License
# which accompanies this distribution, and is available at
# http://opensource.ncsa.illinois.edu/license.html
#-------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------#
##'
##' Convert queried data to format required by JAGS meta-analysis model 
##'
##' @name jagify
##' @title Prepare trait data for JAGS meta-analysis
##' @param result input trait data
##' @return result transformed to meet requirements of PEcAn meta-analysis model
##' @export
##' @author David LeBauer
jagify <- function(result){
  
  ## Rename 'name' column from 'treatment' table to trt_id.
  ## Remove NAs. Assign treatments.
  ## Finally, summarize the results by calculating summary statistics from experimental 
  ## replicates
  
  length.data = length(result)
  for (i in 1:length.data){
    names(result[[i]])[which(names(result[[i]])=="name")] <- 'trt_id'
    result[[i]] <- transform.nas(result[[i]])
    result[[i]] <- assign.treatments(result[[i]])
    result[[i]] <- summarize.result(result[[i]])
    
    # HACK.  Not sure why but root respiration rate for late.hardwood has one queried
    # value with all columns NA?  As if there is blank line in the database.  This
    # will remove that bad data for now.  However we should probably figure out
    # why this is happening. SPS
    remove = which(is.na(result[[i]]$mean))
    if(length(remove)>=1){
      result[[i]] = result[[i]][-remove,1:length(result[[i]])]
      warning.message <- paste('There was at least one mean value of "NA" in the trait.data \n',
                               'of ',names(result)[i],'.', ' Row with bad data has been removed.',sep="")
      warning(warning.message)
    } # End if
    
  } # End for loop
  rm(i)
  
  ### Assign a unique sequential integer to site and trt; for trt, all controls == 0 
  for (i in 1:length.data){
    result[[i]]$greenhouse[is.na(result[[i]]$greenhouse)] <- 0
    result[[i]] <- subset(transform(result[[i]],
                               stat = as.numeric(stat),
                               n    = as.numeric(n),
                               site_id = as.integer(factor(site_id, unique(site_id))),
                               greenhouse = as.integer(factor(greenhouse, unique(greenhouse))),
                               mean = mean,
                               citation_id = citation_id), 
                     select = c('stat', 'n', 'site_id', 'trt_id', 'mean', 'citation_id', 'greenhouse'))
  } # End for loop
  rm(i)

  for (i in 1:length.data){
    if(length(result[[i]]$stat[!is.na(result[[i]]$stat) & result[[i]]$stat <= 0.0]) > 0) {
      citationswithbadstats <- unique(result[[i]]$citation_id[which(result[[i]]$stat <= 0.0)])
      warning.message <- paste('there are implausible values of SE: SE <= 0 \n',
                               'for', names(result)[i], 'result from citation',
                               citationswithbadstats,'\n',
                               'SE <=0 set to NA \n')
      warning(warning.message)
      print(result[[i]])
      result[[i]]$stat[result[[i]]$stat <= 0.0] <- NA
    } ### End of if statement
    
  } # End for loop
  rm(i)

  return(result)
  
} ### End of function
#==================================================================================================#


####################################################################################################
### EOF.  End of R script file.      				
####################################################################################################
