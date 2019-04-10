source( "create-data-frames.R" )

# Here's where the data comes from...

pretty.urls =
  c( "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1041567"  # PM's MV 1
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1041564"  # Baron (f)
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1042258"  # No confidence
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1050712"  # Brady(n)
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1050644"  # Spelman (i)
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1050642"  # Reeves (j)
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1050641"  # Cooper (b)
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1050640"  # Grieve (g)
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1050639"  # Blackford (o)
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1050638"  # Corbyn (a)
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1061010"  # Main, 14 Feb
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1061009"  # Blackford
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1061008"  # Corbyn
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1078392"  # Cooper, 27 Feb
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1078391"  # Blackford, 27 Feb
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1078390"  # Corbyn, 27 Feb
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1086876"  # MV 2
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1087778"  # No ND, amdd
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1087777"  # ND Spelman (ND ever)
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1087775"  # ND Malthouse
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1088679"  # Ext A50, 14 Mar
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1088675"  # Ext A50, Corbyn (e)
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1088674"  # Ext A50, Benn
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1088673"  # Ext A50, Powell-Benn
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1088670"  # Ext A50, Wollaston
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1104689"  # Stmt, amdd
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1104688"  # Stmt, Beckett
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1104623"  # Stmt, Letwin
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105759"  # ???
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105403"  # Ind
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105533"  # Ind, Cont pref arr
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105532"  # Ind, Conf pub vote
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105530"  # Ind, Revoke if ND
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105529"  # Ind, Labour alt
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105527"  # Ind, Customs U
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105526"  # Ind, EFTA and EEA
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105524"  # Ind, C Mkt 2.0
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105521"  # Ind, ND
  )

# Create raw data

raw.data = create.raw.data( pretty.urls )

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
  , Type = "Undirected"
  , Weight = filtered.votes.edges$affinity
  , CountEither = filtered.votes.edges$count.either
  , CountBoth = filtered.votes.edges$count.both
)

cat("Writing files...\n")

write.csv(votes.nodes, file = "votes-nodes.csv", row.names = FALSE)
write.csv(votes.edges, file = "votes-edges.csv", row.names = FALSE)
