# Link members to how they voted and output a graph for that

write.member.votes = function( raw.data ) {

  # Get all the members, with the party of each. Since members move parties,
  # always take the last instance of each
  
  # Get a quick list of members and parties, with possible duplicates if a member has switched.
  # We order by division number to ensure the later votes (and parties) appear later.
  
  members.dup = unique( data.frame(
    name = raw.data$vote...member.printed
    , party = raw.data$vote...member.party
    , division = raw.data$division.number
  ))
  
  members.dup = members.dup[ order(members.dup$division), ]
  
  # Now compile a fresh data frame of members with just their latest party.
  # Each row name is the member name
  
  members = data.frame()
  
  for(i in 1:nrow(members.dup)) {
    name = members.dup[i, "name"]
    party = members.dup[i, "party"]
    members[as.character(name), "party"] = party
  }
  
  # Create the nodes of members and voted motions, and edges between members and their votes motions
  
  member.vote.nodes = data.frame(
    Id = rownames(members)
    , Label = rownames(members)
    , Type = "member"
    , TypeNumber = 1  # Member nodes numbered to be smaller
    , Party = members$party
    , Topic = "Member"
    , VoteName = "Member"
  )
  
  member.vote.nodes = rbind(
    member.vote.nodes
    , data.frame(
      Id = voted.motions$title
      , Label = voted.motions$title
      , Type = "Voted Motion"
      , TypeNumber = 1.5  # Voted motion nodes numbered to be larger
      , Party = "Motion"
      , Topic = voted.motions$topic
      , VoteName = voted.motions$name
    )
  )
  
  member.vote.edges = data.frame(
    Source = raw.data$vote...member.printed
    , Target = raw.data$vote.title
    , Type = "Undirected"
  )
  
  # Write out the node and edges files for members to voted motions
  
  cat("Writing files for members' votes...\n")
  
  write.csv(member.vote.nodes, file = "graph-data/member-vote-nodes.csv", row.names = FALSE)
  write.csv(member.vote.edges, file = "graph-data/member-vote-edges.csv", row.names = FALSE)
  
}

