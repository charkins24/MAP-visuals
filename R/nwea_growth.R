#' @title Create a data frame of all requested NWEA MAP growth norms. 
#'
#' @description
#' \code{nwea_growth} takes three vectors for grade-level, (starting) RIT Score, and Measurement Scale
#'  (usually from a CDF) and return a returns data.frame of typical growth
#'  calculations from the NWEA 2011 MAP Norms tables for each grade-RIT-measurement scale triplet. 
#'  
#' @details 
#' User can indicate which calculted nomrs (typical mean, reported mean, and standard deviation) and 
#'  any growth period by using the letter+two digit NWEA 2011 Growth Norms indicator (i.e. for 
#'  Reported spring to spring growth user will provide R22, for typical fall to winter growth user provides
#'  T41, and for the the standard deviation of fall to spring growth user will provide S42). Providing no list
#'  of norms indicators results in every norm and season returned. All passed vectors must be the same length
#'
#' 
#' @param start.grade vector of student start (or pre-test) grade levels
#' @param start.rit vector of student start (or pre-test) RIT scores
#' @param measurementscale vector of measurement scales for the RIT scores in \code{start.rit}
#' @param \code{...} arguments passed to dplyr:select, used to select the requested norms data.  You pass indicators like 
#' T42, S22, R12 as unevaluated args (i.e. as unquoted strings).  For examples, passing R42 causes the 
#' function to return a single vector of reported fall-to-spring growth norms; passing R42, S42, R22 would 
#' return a data.frame with 3 columns for reported fall-to-spring growth, the standard deviation of fall-to-spring
#' growth and reported spring-spring-growth, respectively
#' 
#' @return a vector of \code{length(start.grade)} or data.frame with \code{nrow(start.grade)} and \code{ncols(x)==length(...)}.
#' @export
#' @examples 
#' nwea_growth()

nwea_growth<- function(start.grade, 
                       start.rit, 
                       measurementscale, 
                       ...){
  
  stopifnot(all.equal(length(start.grade), 
                      length(start.rit), 
                      length(measurementscale)
  )
  )
  
  subs<-dots(...)
  
  data(norms_students_2011, envir=environment())
  
  norms<-select(norms_students_2011, 
                Grade=StartGrade,
                TestRITScore=StartRIT,
                MeasurementScale,
                T41:S12)
  
  df<-data.frame(Grade=as.integer(start.grade), 
                 TestRITScore=as.integer(start.rit), 
                 MeasurementScale=as.character(measurementscale),
                 stringsAsFactors = FALSE)
  
  df2 <- left_join(df, 
                   norms, 
                   by=c("MeasurementScale", "Grade", "TestRITScore")) %.%
    select(-Grade, -TestRITScore, -MeasurementScale)
  
  df2<-df2[,names(df2)[order(names(df2))]]
  
  if(length(subs)>=1) df2<-select(df2, ...)
  
  df2
}