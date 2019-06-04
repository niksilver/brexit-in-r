# Some experiments with dplyr and tidyr

library("tidyverse")

# Get separate Aye and No flags for each member against each division,
# because some MPs seem to have voted both Aye and No in some divisions.

member.votes <-
  raw.data %>%
  select(vote...member.printed, short.title, vote.name) %>%    # Need reduce columns to ensure proper indexing
  spread(key = vote.name, value = vote.name, fill = "")

duplicate.voters <-
  member.votes %>%
  select(vote...member.printed, short.title, Aye, No) %>%
  filter(Aye == "Aye" & No == "No")

# Spread out the votes so that we've got one row per member,
# showing all their Ayes and Nos (and some "AyeNo"s)
# and create a single string for each voting pattern.

voting.patterns <-
  member.votes %>%
  mutate(vote.name = paste(Aye, No, sep = "")) %>%    # Duplicate voters will have "AyeNo" recorded
  select(-Aye, -No) %>%
  spread(key = short.title, value = vote.name) %>%
  unite("pattern", -vote...member.printed, remove = FALSE)


