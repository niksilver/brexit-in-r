# Create a raw.data frame by loading in CSV files and augmenting

create.raw.data = function( pretty.urls ) {
  
  # Convert the "pretty" URLs, which presents a nice page of data, into the URLs for CSV files.
  
  url.ids = sub( ".*/", "", pretty.urls )

  # Get all the CSV files needed and bind them together
  
  raw.data = data.frame()
  
  cat("Fetching data...\n")
  
  for ( i in 1:length(url.ids) ) {
    cat(sprintf( "Fetching %s/%s...", i, length(url.ids) ))
    cached.file.name = paste( "cache/", url.ids[i], ".csv" , sep = "" )
    csv.url = paste( "http://lda.data.parliament.uk/commonsdivisions/id/", url.ids[i], ".csv", sep = "" )
    if (file.exists( cached.file.name )) {
      csv = read.csv( cached.file.name )
      cat(" Fetched from cache\n")
    } else {
      csv = read.csv( csv.url )
      write.csv( csv, cached.file.name, row.names = FALSE )
      cat(sprintf(" Fetched from web and cached as %s\n", cached.file.name ))
    }
    raw.data = rbind( raw.data, csv )
  }

  trim <- function (x) gsub("^\\s+|\\s+$", "", x)
  raw.data$title <- trim( raw.data$title )
  
  cat("Making calculations on raw data...\n")
  
  # It's useful to augment raw.data with extra columns:
  # - vote name which is just the string Aye or No (reduced from the URI)
  # - vote id to give an id to the vote title
  # - count of votes in that lobby for that motion
  
  vote.uri.to.name <- function(uri) {
    if (uri == "http://data.parliament.uk/schema/parl#AyeVote" ) {
      return( "Aye" )
    } else if (uri == "http://data.parliament.uk/schema/parl#NoVote" ) {
      return( "No" )
    } else {
      stop( "Unknown vote URI" )
    }
  }
  
  v.vote.uri.to.name = Vectorize(vote.uri.to.name)
  
  raw.data$vote.name = v.vote.uri.to.name( raw.data$vote...type...uri )
  
  get.vote.id <- function( division.number, vote.name ) {
    if (vote.name == "Aye") {
      return( division.number * 10 + 1 )
    } else if (vote.name == "No") {
      return( division.number * 10 + 0 )
    } else {
      stop( "Unknown vote name" )
    }
  }
  
  v.get.vote.id = Vectorize(get.vote.id)
  
  raw.data$vote.id = v.get.vote.id( raw.data$division.number, raw.data$vote.name )
  
  get.vote.count = function(ayes, noes, vote.name) {
    if (vote.name == "Aye") {
      ayes
    } else if (vote.name == "No") {
      noes
    } else {
      stop("Got a vote which is neither Aye nor No")
    }
  }
  
  v.get.vote.count = Vectorize(get.vote.count)
  
  raw.data$vote.count = v.get.vote.count(
    raw.data$ayes.count, raw.data$noesvotecount, raw.data$vote.name
  )
  
  # Add data about each of the motions.
  # Add it to the raw data, including any gaps (all.x = TRUE), of which there shouldn't be any
  # Stop if there are gaps
  # Add a vote title to indicate not just the title of the motion,
  #   but also whether it's Aye or No version.
  
  motion.themes = read.csv("motion-themes.csv")
  
  raw.data = merge( raw.data, motion.themes, by = c("title", "date"), all.x = TRUE )
  
  get.vote.title <- function( title, vote.name ) {
    vote.title = paste( title, " (", vote.name, ")", sep = "" )
  }
  
  v.get.vote.title = Vectorize(get.vote.title)
  
  raw.data$vote.title = v.get.vote.title( raw.data$short.title, raw.data$vote.name )
  
  if ( nrow( raw.data[ is.na(raw.data$short.title), ]) > 0 ) {
    problem.motions = unique( raw.data[ is.na(raw.data$short.title), "title" ] )
    problem.dates = unique( raw.data[ is.na(raw.data$short.title), "date" ] )
    stop(sprintf( "No theme data for motion '%s' on date '%s'\n", problem.motions, problem.dates ))
  }
  
  
  # Check we've got the number of motions that we expect
  
  if ( length(pretty.urls) != nrow(motion.themes) ) {
    stop(paste( "Got", length(pretty.urls), "downloads but", nrow(motion.themes), "motions"))
  }
  
  return( raw.data )
  
}
