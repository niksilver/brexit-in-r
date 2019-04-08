# Convert the "pretty" URLs, which presents a nice page of data, into the URLs for CSV files.

pretty.urls =
  c( "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1041567"  # PM's MV 1
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1041564"  # Baron (f)
     #, "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1042258"  # No confidence
     #, "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1050712"  # Brady(n)
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
  stop(paste( "No theme data for this motion: '", problem.motions, "'", sep = "" ))
}


# Check we've got the number of motions that we expect

if ( length(pretty.urls) != nrow(motion.themes) ) {
  stop(paste( "Got", length(pretty.urls), "downloads but", nrow(motion.themes), "motions"))
}


# Get a data frame with just the motions and the vote for each

voted.motions = unique( data.frame(
  id = raw.data$vote.id
  , title = raw.data$vote.title
  , name = raw.data$vote.name
  , count = raw.data$vote.count
  ))


# Get combinations of all pairs of voted motions.
# This has columns id.x, title.x, name.x, count.x ... and the same for .y

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

# Output the nodes and edges for Gephi

votes.nodes = data.frame(
  Id = voted.motions$id
  , Label = voted.motions$title
  , VoteName = voted.motions$name
  , Count = voted.motions$count
)

filtered.votes.edges =
  cross.votes[ cross.votes$id.x < cross.votes$id.y & cross.votes$count.both > 0, ]

votes.edges = data.frame(
  Source = filtered.votes.edges$id.x
  , Target = filtered.votes.edges$id.y
  , Weight = filtered.votes.edges$affinity
  , CountEither = filtered.votes.edges$count.either
  , CountBoth = filtered.votes.edges$count.both
)

print("Writing files...")

write.csv(votes.nodes, file = "~/../Desktop/votes-nodes.csv", row.names = FALSE)
write.csv(votes.edges, file = "~/../Desktop/votes-edges.csv", row.names = FALSE)
