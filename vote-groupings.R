# Some experiments with dplyr and tidyr

library("tidyverse")

member.votes <-
  raw.data %>%
  select(vote...member.printed, short.title, vote.name) %>%    # Need reduce columns to ensure proper indexing
  spread(key = vote.name, value = vote.name)

duplicate.votes <-
  member.votes %>%
  select(vote...member.printed, short.title, Aye, No) %>%
  mutate(duplicate.vote = (!is.na(Aye) & !is.na(No))) %>%
  filter(duplicate.vote == TRUE)
