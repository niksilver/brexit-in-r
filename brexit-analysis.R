# Convert the "pretty" URLs, which presents a nice page of data, into the URLs for CSV files.

pretty.urls =
  c( "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1041567"
     ,"http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1041564"
  )
url.ids = sub( ".*/", "", pretty.urls )
csv.urls = paste( "http://lda.data.parliament.uk/commonsdivisions/id/", url.ids, ".csv", sep = "" )

# Get all the CSV files needed and bind them together

raw.data = data.frame()

print("Downloading data...")

for ( url in csv.urls ) {
  csv = read.csv( url )
  raw.data = rbind( raw.data, csv )
}

print("Making calculations...")

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

# Add the count of members who voted (i) for either of the pair, and (ii) for both.
# Then add the proportion

get.count.either = function(id.x, id.y) {
  length(unique(
    raw.data[
      raw.data$vote.id == id.x | raw.data$vote.id == id.y
      , "vote...member.printed"
    ]
  ))
}

v.get.count.either = Vectorize(get.count.either)

cross.votes$count.either = v.get.count.either( cross.votes$id.x, cross.votes$id.y )

get.count.both = function(id.x, id.y) {
  length(intersect(
    raw.data[ raw.data$vote.id == id.x, "vote...member.printed" ]
    , raw.data[ raw.data$vote.id == id.y, "vote...member.printed" ]
  ))
}

v.get.count.both = Vectorize(get.count.both)

cross.votes$count.both = v.get.count.both( cross.votes$id.x, cross.votes$id.y )

cross.votes$affinity = cross.votes$count.both / cross.votes$count.either
