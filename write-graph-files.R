# Write out files for gephi. Parameters are:
#   voted.motions - All the nodes (motion A Aye, motion A No, motion B Aye, etc)
#   cross.votes - All the edges

write.graph.files <- function (votes.nodes, filtered.votes.edges) {
  
  cat("Writing files...\n")
  
  write.csv(votes.nodes, file = "votes-nodes.csv", row.names = FALSE)
  write.csv(votes.edges, file = "votes-edges.csv", row.names = FALSE)
  
}