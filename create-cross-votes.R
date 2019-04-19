# Create the links between voted motions

get.cross.votes = function( raw.data, voted.motions ) {
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
  
  return( cross.votes )
}
