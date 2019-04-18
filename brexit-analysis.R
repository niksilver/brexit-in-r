source( "create-data-frames.R" )
source( "write-graph-files.R" )

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
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105759"  # Ext to 12 April
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105403"  # Ind
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105533"  # Ind, Cont pref arr
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105532"  # Ind, Conf pub vote
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105530"  # Ind, Revoke if ND
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105529"  # Ind, Labour alt
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105527"  # Ind, Customs U
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105526"  # Ind, EFTA and EEA
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105524"  # Ind, C Mkt 2.0
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1105521"  # Ind, ND
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1107737"  # MV 2.5
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1108907"  # Ind 2, Parl decides
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1108906"  # Ind 2, Conf pub vote
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1108905"  # Ind 2, Customs U
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1108904"  # Ind 2, C Mkt 2.0
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1108643"  # Ind 2
     
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1109326"  # 3 Apr, (Cooper BofH) MPs ext
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1109325"  # 3 Apr, more ind votes
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1109591"  # 3 Apr (Cooper main)
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1109553"  # 3 Apr, no vote on other ext'n
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1109554"  # 3 Apr, Gvt, Brex Sec free
     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1109556"  # 3 Apr, ext limited to 22/5

     , "http://explore.data.parliament.uk/?endpoint=commonsdivisions/id/1110514"  # Ext to 30 June
  )

# Create raw data

raw.data = create.raw.data( pretty.urls )

# Get a data frame with just the motions and the vote for each

voted.motions = unique( data.frame(
  id = raw.data$vote.id
  , title = raw.data$vote.title
  , name = raw.data$vote.name
  , count = raw.data$vote.count
  , meaningful = raw.data$meaningful
  , pms = raw.data$pms
  , indicative = raw.data$indicative
  , markets = raw.data$markets
  , topic = raw.data$topic
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
  , Meaningful = voted.motions$meaningful
  , PMs = voted.motions$pms
  , Indicative = voted.motions$indicative
  , Markets = voted.motions$markets
  , Topic = voted.motions$topic
)

# Divisions are numbered in the sequence in which they actually occurred, so
# we can express an "earlier" and "later" sequence between id.x and id.y

filtered.votes.edges =
  cross.votes[ cross.votes$id.x < cross.votes$id.y & cross.votes$count.both > 0, ]

votes.edges = data.frame(
  Source = filtered.votes.edges$id.x
  , Target = filtered.votes.edges$id.y
  , Type = v.directedness(filtered.votes.edges$id.x, filtered.votes.edges$id.y, voted.motions)
  , Weight = filtered.votes.edges$affinity
  , CountEither = filtered.votes.edges$count.either
  , CountBoth = filtered.votes.edges$count.both
)

# Write everything

write.graph.files(votes.nodes, votes.edges)

# Write just the meaningful votes

write.graph.files(
  votes.nodes[ votes.nodes$Meaningful == TRUE, ]
  , votes.edges
  , suffix = "meaningful-"
)

# Write just the PM's votes

write.graph.files(
  votes.nodes[ votes.nodes$PMs == TRUE, ]
  , votes.edges
  , suffix = "pms-"
)

# Write just the indicative votes

write.graph.files(
  votes.nodes[ votes.nodes$Indicative == TRUE, ]
  , votes.edges
  , suffix = "indicative-"
)

# Write just the votes about market arrangements

write.graph.files(
  votes.nodes[ votes.nodes$Markets == TRUE, ]
  , votes.edges
  , suffix = "markets-"
)

# Write just the votes about market arrangements, without connecting MV nodes to each other.
# This to ensure the disagreement over MVs don't influence the other relationships.

mv.node.ids = votes.nodes[ votes.nodes$Meaningful == TRUE, ][[ "Id" ]]
write.graph.files(
  votes.nodes[ votes.nodes$Markets == TRUE, ]
  , votes.edges[ !(votes.edges$Source %in% mv.node.ids) | !(votes.edges$Target %in% mv.node.ids), ]
  , suffix = "markets-with-unconnected-mvs-"
)
