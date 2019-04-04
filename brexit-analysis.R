# Convert the "pretty" URLs, which presents a nice page of data, into the URLs for CSV files.

pretty.urls =
  c( "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1041567"
     ,"http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1041564"
  )
url.ids = sub( ".*/", "", pretty.urls )
csv.urls = paste( "http://lda.data.parliament.uk/commonsdivisions/id/", url.ids, ".csv", sep = "" )

# Get all the CSV files needed and bind them together

raw.data = data.frame()

for ( url in csv.urls ) {
  csv = read.csv( url )
  raw.data = rbind( raw.data, csv )
}

vote.uri.to.name <- function(uri) {
  if (uri == "http://data.parliament.uk/schema/parl#AyeVote" ) {
    return( "Aye" )
  } else if (uri == "http://data.parliament.uk/schema/parl#NoVote" ) {
    return( "No" )
  } else {
    return( "???" )
  }
}

motion.id.and.vote.title <- function( division.number, title, vote.name ) {
  vote.title = paste( title, " (", vote.name, ")", sep = "" )
  if (vote.name == "Aye") {
    return( c( division.number * 10 + 1, vote.title ))
  } else if (vote.name == "No") {
    return( c( division.number * 10 + 0, vote.title ))
  } else {
    return( c( division.number * 10 + 9, vote.title ))
  }
}

motions = unique( raw.data[ c(  "division.number", "vote...type...uri", "title" )])
motions$vote.name = lapply( motions$vote...type...uri, vote.uri.to.name)
motions[ c("id", "vote.title")]  =
  t(
    mapply( motion.id.and.vote.title
          , motions$division.number
          , motions$title
          , motions$vote.name
          )
  )
