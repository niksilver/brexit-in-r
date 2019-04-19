# Write out files for gephi. Parameters are:
#   votes.nodes - The nodes for Gephi
#   votes.edges - The edges for the nodes
#   suffix - Suffix for the nodes and edges filenames.

write.graph.files <- function (
    votes.nodes
    , votes.edges
    , suffix = "all-"
    ) {
  
  nodes.file.name = paste("graph-data/", suffix, "nodes.csv", sep = "")
  
  node.ids = votes.nodes[["Id"]]
  votes.edges =
    votes.edges[ votes.edges$Source %in% node.ids & votes.edges$Target %in% node.ids, ]
  edges.file.name = paste("graph-data/", suffix, "edges.csv", sep = "")
  
  write.csv(votes.nodes, file = nodes.file.name, row.names = FALSE)
  write.csv(votes.edges, file = edges.file.name, row.names = FALSE)
  
}


# Determine if an edge between two nodes is directed. It will be unless
# both nodes are from the same round of indicative votes, as the motions
# in each round of indicative votes took place simultaneously.

directedness = function( source.id, target.id, voted.motions ) {
  source.prefix = substring( voted.motions[voted.motions$id == source.id, "title"], 1, 5 )
  target.prefix = substring( voted.motions[voted.motions$id == target.id, "title"], 1, 5 )
  both.ind1 = (source.prefix == target.prefix & source.prefix == "Ind 1")
  both.ind2 = (source.prefix == target.prefix & source.prefix == "Ind 2")
  if (both.ind1 | both.ind2) {
    "Undirected"
  } else {
    "Directed"
  }
}

v.directedness = Vectorize(
  directedness
  , vectorize.args = c("source.id", "target.id")
)
