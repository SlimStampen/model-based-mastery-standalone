# require(dplyr)
require(data.table)
require(purrr)

#' Calculate activation from encounters
#' 
#' @param encounters A list of timestamps (in ms)
#' @param time The time (in ms) at which to calculate activation
#' 
#' @return The calculated activation (a double)
#' 
calculate_activation_from_encounters <- function (encounters, time) {
  sum <- 0
  if (length(encounters) > 0) {
    for (i in 1:length(encounters)) {
      if (encounters[[i]]$time < time) {
        sum <- sum + ((time - encounters[[i]]$time) / 1000) ^ -encounters[[i]]$decay
      }
    }
  }
  return (log(sum))
}

#' Calculate decay
#' 
#' @param activation The activation value (a double)
#' @param alpha The alpha parameter (a double)
#' 
#' @return The calculated decay (a double)
#' 
calculate_decay <- function (activation, alpha) {
  return (0.25 * exp(activation) + alpha)
}

#' Convert hours to milliseconds
#' 
#' @param h The number of hours
#' 
#' @return The equivalent time in milliseconds (a double)
#' 
h_to_ms <- function (h) {
  h * 60 * 60 * 1000
}



#' Calculate Model-Based Mastery activation
#' 
#' @param responses
#' @param include_last
#' @param mastery_lookahead_time
#' @param mastery_alpha
#' 
#' @return The calculated Model-Based Mastery activation (a double)
#' 
calculate_mbm_activation <- function (responses,
                                      mastery_lookahead_time = h_to_ms(24),
                                      mastery_alpha = .45) {
  
  act <- NA
  alpha <- mastery_alpha
  encounters <- list()
  
  if (nrow(responses) == 0) {
    act <- -Inf
  } else {
    for (i in 1:nrow(responses)) {
      activation <- calculate_activation_from_encounters(encounters, responses[i, start_time])
      
      encounters[[i]] <- list(activation = activation, 
                              time = responses[i, start_time],
                              correct = responses[i, correct],
                              decay = NA)
      
      
      for (j in 1:length(encounters)) {
        encounters[[j]]$decay <- calculate_decay(encounters[[j]]$activation, alpha)
      }
    }
    
    encounters_correct <- encounters[map_lgl(encounters, ~.$correct == TRUE)]
    
    act <- calculate_activation_from_encounters(encounters_correct, responses[.N, start_time + rt] + mastery_lookahead_time)
    
  }
  
  return (act)
}


