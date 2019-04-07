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

# It's useful to augment raw.data with extra columns:
# - vote name which is just the string Aye or No (reduced from the URI)
# - vote title to indicate not just the title of the motion, but also whether it's Aye or No version
# - vote id to give an id to the vote title

vote.uri.to.name <- function(uri) {
  if (uri == "http://data.parliament.uk/schema/parl#AyeVote" ) {
    return( "Aye" )
  } else if (uri == "http://data.parliament.uk/schema/parl#NoVote" ) {
    return( "No" )
  } else {
    return( "???" )
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
    return( division.number * 10 + 9 )
  }
}

v.get.vote.id = Vectorize(get.vote.id)

raw.data$vote.id = v.get.vote.id( raw.data$division.number, raw.data$vote.name )

get.vote.title <- function( title, vote.name ) {
  vote.title = paste( title, " (", vote.name, ")", sep = "" )
}

v.get.vote.title = Vectorize(get.vote.title)

raw.data$vote.title = v.get.vote.title( raw.data$title, raw.data$vote.name )

# Get a data frame with just the motions and the vote for each

voted.motions = unique( data.frame(
  id = raw.data$vote.id
  , title = raw.data$vote.title
  , name = raw.data$vote.name
  ))

# Get combinations of all pairs of voted motions.
# This has columns id.x, title.x, name.x, id.y, title.y, name.y

cross.votes = merge(voted.motions, voted.motions, by = NULL)

stop("Premature stop 3")

cross.votes.fn <- function() {
  results = data.frame(
    id1 = integer()
    , vote.name1 = factor()
    , id2 = integer()
    , vote.name2 = factor()
    , count = integer()
    )
  for (i1 in 1:nrow(motions)) {
    vote1 = motions[i1,]
    for (i2 in 1:nrow(motions)) {
      vote2 = motions[i2,]
      voters = raw.data[
        (raw.data$division.number == vote1$division.number & raw.data$vote...type...uri == vote1$vote...type...uri)
        | (raw.data$division.number == vote2$division.number & raw.data$vote...type...uri == vote2$vote...type...uri)
        , "vote...member.printed"
        ]
      count = length(unique(voters))
      print(paste("vote1", vote1$id, "as", vote1$vote.name, "vote2", vote2$id, "as", vote2$vote.name, "count", count))
      row = c(vote1$id, vote1$vote.name, vote2$id, vote2$vote.name, count)
      results = rbind(results, row)
    }
  }
}
