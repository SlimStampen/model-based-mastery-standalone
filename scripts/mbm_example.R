#' Copyright MemoryLab
#' Maarten van der Velde
#' 2024

# Lood MBM functions
source("mbm_funs.R")

# Generate some example data
responses <- data.table(
  start_time = c(0, 10000, 45000, 120000),    # presentation start time (ms)
  study_trial = c(TRUE, FALSE, FALSE, FALSE), # is this a study trial? (logical)
  correct = c(TRUE, FALSE, TRUE, TRUE),       # is response correct? (logical)
  rt = c(1500, 2000, 3000, 2000)              # reaction time (ms)
)

# Calculate activation 24h in the future, directly after the last response
# (similar to how it is used during practice to determine mastery)
calculate_mbm_activation(responses)

# Calculate activation 24h in the future, directly after each response
# (similar to how it is used during practice to determine mastery)
map_dbl(1:nrow(responses), ~calculate_mbm_activation(responses[1:.x]))

# Calculate activation 24h in the future, 3h after the last response
calculate_mbm_activation(responses, mastery_lookahead_time = h_to_ms(24 + 3))


# Calculate MBM activation (in 24h) at various time points in the week following practice
ts <- seq(1, 7*24, 1)
act <- data.table(
  t = ts,
  mbm_act = map_dbl(ts, ~calculate_mbm_activation(responses, mastery_lookahead_time = h_to_ms(24 + .x)))
)
plot(act$t, act$mbm_act, type = "l", xlab = "Time since the end of practice (hours)", ylab = "MBM activation (in 24h)")