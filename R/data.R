library(tidyverse)

# Conditions under which to run trials. `n` only needs to be modified here now
{
	n <- 50L

	LARGE <- 20L
	SMALL <- 5L
	SIZES <- c(LARGE, SMALL)

	conditions <- list(attack.strategy = 3:1,
	                   defend.strategy = 2:1)
}

#' Trial
#' Runs a sequence of attacks, and returns TRUE if the attacker wins, FALSE
#' if attacker loses
#'
#' @param attack.strategy Max number of armies/dice attacker will use
#' @param defend.strategy Max number of armies/dice defender will use
#' @param attack.armies Total armies attacker has
#' @param defend.armies Total armies defender has
#' @return Attacker wins?
#'
#' @examples
#' trial(3, 2, LARGE, SMALL)
#'
#' @author Brian
trial <-
	function(attack.strategy,
	         defend.strategy,
	         attack.armies,
	         defend.armies) {
		if (attack.armies <= 1)
			FALSE
		else if (defend.armies <= 0)
			TRUE
		else {
			# Make sure we're not rolling more armies than available
			attack.strategy <- min(attack.strategy, attack.armies)
			defend.strategy <- min(defend.strategy, defend.armies)
			total <- min(attack.strategy, defend.strategy)

			# Closure to roll `total` dice with a given strategy
			roll <- . %>%
				sample.int(6, ., replace = TRUE) %>%
				sort(decreasing = TRUE) %>%
				head(total) # Take top n rolls

			attack.rolls <- attack.strategy %>% roll
			defend.rolls <- defend.strategy %>% roll

			# result is vector of outcomes, TRUE if attacker wins, FALSE otherwise
			result <- attack.rolls > defend.rolls
			attack.wins <-
				sum(result) # TRUE is 1, FALSE is 0. Sum gives number of attacker wins
			defend.wins <- total - attack.wins

			# Call trial again with updated army sizes
			trial(
				attack.strategy,
				defend.strategy,
				attack.armies - defend.wins,
				defend.armies - attack.wins
			)
		}
	}


#' Repeatedly
#'
#' Like replicate except using standard evaluation
#'
#' @param n Number of repetitions
#' @param fn Function to apply
#' @param ... Args for fn
#'
#' @return A vector of n repetitions of applying fn to ...
#'
#' @examples `repeatedly(4, sample(1:10, 1))`
#'
#' @author Brian
repeatedly <-
	function(n, fn, ...) {
		sapply(integer(n), function(.)
			fn(...))
	}

#' Size
#'
#' Convenience function to interpret an integer as a size parameter
#'
#' @param size A size to interpret as a string
#'
#' @return String representation of `size`
#'
#' @examples `size.str(LARGE)`
#'
#' @author Brian
size.str <- function(size){
	ifelse(size <= min(SIZES), "SMALL", "LARGE")
}

# Narrow form tibble of trials
trials <<-
	conditions %>%
	expand.grid %>% # All possible combinations
	as_tibble %>%
	list %>% # Wrap in a list so rep expands that instead of the tibble
	rep(n) %>% # N sets of trials
	bind_rows %>% # Bind into big tibble
	rowwise %>% # Group by row
	mutate(
		# Add random size
		attack.armies = sample(SIZES, 1),
		defend.armies = sample(SIZES, 1),
		# Run trial with given conditions
		won = trial(
			attack.strategy,
			defend.strategy,
			attack.armies,
			defend.armies
		)
	)

# Sample view of trials
trials
