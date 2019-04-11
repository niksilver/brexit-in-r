# Write out files for gephi. Parameters are:
#   voted.motions - All the nodes (motion A Aye, motion A No, motion B Aye, etc)
#   cross.votes - All the edges

write.graph.files <- function (
    votes.nodes
    , votes.edges
    , nodes.filter = function(votes.nodes) { TRUE }
    , suffix = ""
    ) {
  
  filtered.votes.nodes = votes.nodes[ nodes.filter(votes.nodes), ]
  nodes.file.name = paste("votes-nodes", suffix, ".csv", sep = "")
  
  node.ids = filtered.votes.nodes[["Id"]]
  filtered.votes.edges =
    votes.edges[ votes.edges$Source %in% node.ids & votes.edges$Target %in% node.ids, ]
  edges.file.name = paste("votes-edges", suffix, ".csv", sep = "")
  
  cat("Writing files...\n")
  
  write.csv(filtered.votes.nodes, file = nodes.file.name, row.names = FALSE)
  write.csv(filtered.votes.edges, file = edges.file.name, row.names = FALSE)
  
}