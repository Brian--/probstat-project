library(magrittr)

LARGE <- 20
SMALL <- 5

conditions <- expand.grid(attack.armies = c(LARGE, SMALL),
                          defend.armies = c(LARGE, SMALL),
                          attack.strategy = 3:1,
                          defend.strategy = 2:1,
                          n = 50)


#' Trial
#'
#' @param attack.armies Total armies attacker has
#' @param defend.armies Total armies defender has
#' @param attack.strategy Max number of armies attacker will use
#' @param defend.strategy Max number of armies defender will use
#' @return Attacker wins?
#'
#' @examples
#' trial(LARGE, SMALL, 3, 2)
#' 
#' @seealso wrapper
#' @seealso trials
#' @author Brian
trial <- function(attack.armies, defend.armies, attack.strategy, defend.strategy)
{
	if (attack.armies < defend.armies || attack.armies <= 1)
	{
		FALSE
	} else if (defend.armies <= 0) {
		TRUE
	} else {
		attack.strategy <- min(attack.strategy, attack.armies)
		defend.strategy <- min(defend.strategy, defend.armies)
		total <- min(attack.strategy, defend.strategy)
		attack.rolls <- sample.int(6, attack.strategy, replace = TRUE) %>%
			sort(decreasing = TRUE) %>%
			head(total)
		
		defend.rolls <- sample.int(6, defend.strategy, replace = TRUE) %>%
			sort(decreasing = TRUE) %>%
			head(total)
		
		result <- mapply(is_greater_than, attack.rolls, defend.rolls)
		attack.wins <- sum(result)
		defend.wins <- total - attack.wins
		
		trial(attack.armies - defend.wins, defend.armies - attack.wins, attack.strategy, defend.strategy)
	}
}

#' Trials
#'
#' @param attack.armies 
#' @param defend.armies 
#' @param attack.strategy 
#' @param defend.strategy 
#' @param n 
#'
#' @return a list of the result of trials
#'
#' @examples trials(LARGE, SMALL, 3, 2, 20)
#' 
#' @seealso wrapper
#' @seealso trial
#' @author Brian
trials <- function(attack.armies, defend.armies, attack.strategy, defend.strategy, n)
{
	# TODO return closure instead
	replicate(n, trial(attack.armies, defend.armies, attack.strategy, defend.strategy))
}

wrapper <- Vectorize(trials)

size.str <- function(size) ifelse(size<=SMALL, "SMALL", "LARGE")

#' Condition String
#'
#' @return A mapping from df of conditions to strings for names
#'
#' @author Brian
condition.str <- Vectorize(function(attack.armies, defend.armies,
                                    attack.strategy, defend.strategy)
{
	paste(size.str(attack.armies),  "v.", size.str(defend.armies),
	              "rolling",
	               attack.strategy, "v.", defend.strategy )
})

trials.df <- data.frame(do.call(wrapper, conditions))

trials.total.df <- colSums(trials.df)
trials.total.df <- cbind(trials.total.df, sapply(trials.total.df, function(a) 50-a))

trials.names <- do.call(condition.str, subset(conditions, select = -n))
rownames(trials.total.df) <- trials.names
colnames(trials.total.df) <- c("Attacker Wins", "Defender Wins")
colnames(trials.df) <- do.call(condition.str, subset(conditions, select = -n))
