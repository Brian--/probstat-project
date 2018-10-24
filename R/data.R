library(magrittr)

LARGE <- 20
SMALL <- 5

conditions <- expand.grid(attack.armies = c(LARGE, SMALL),
                          defend.armies = c(LARGE, SMALL),
                          attack.strategy = 3:1,
                          defend.strategy = 2:1,
                          n = 50)


#' Trial
#' Runs a sequence of attacks, and returns TRUE if the attacker wins, FALSE
#' when attacker loses
#'
#' @param attack.armies Total armies attacker has
#' @param defend.armies Total armies defender has
#' @param attack.strategy Max number of armies/dice attacker will use
#' @param defend.strategy Max number of armies/dice defender will use
#' @return Attacker wins?
#'
#' @examples
#' trial(LARGE, SMALL, 3, 2)
#' 
#' @seealso trials
#' @author Brian
trial <- function(attack.armies, defend.armies, attack.strategy, defend.strategy)
{
	if (attack.armies <= 1)
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
			head(total) # Take top n rolls
		
		defend.rolls <- sample.int(6, defend.strategy, replace = TRUE) %>%
			sort(decreasing = TRUE) %>%
			head(total) # Take top n rolls
		
		# result is vector of outcomes, TRUE if attacker wins, FALSE otherwise
		result <- mapply(is_greater_than, attack.rolls, defend.rolls)
		attack.wins <- sum(result) # TRUE is 1, FALSE is 0. Sum gives number of attacker wins
		defend.wins <- total - attack.wins
		
		# Call trial again with updated army sizes
		trial(attack.armies - defend.wins, defend.armies - attack.wins, attack.strategy, defend.strategy)
	}
}

#' Trials
#' Run multiple trials of an attack, vectorized for multiple parameters
#' @param attack.armies 
#' @param defend.armies 
#' @param attack.strategy 
#' @param defend.strategy 
#' @param n 
#'
#' @return a list of the result of trials
#'
#' @examples trials(LARGE, SMALL, 3, 2, 20)
#' @examples trials(c(LARGE, SMALL), c(LARGE, SMALL), 3:1, 2:1, 20)
#' 
#' @seealso trial
#' @author Brian
trials <- Vectorize(function(attack.armies, defend.armies, attack.strategy, defend.strategy, n)
	# Replicate is black magic, do not simplify...
	replicate(n, trial(attack.armies, defend.armies, attack.strategy, defend.strategy)))
trials.df <- data.frame(do.call(trials, conditions))

trials.total.df <- colSums(trials.df)
trials.total.df <- cbind(trials.total.df, sapply(trials.total.df, purrr::partial(`-`, 50)))

(function(){
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


trials.names <- do.call(condition.str, subset(conditions, select = -n))
rownames(trials.total.df) <<- trials.names
colnames(trials.total.df) <<- c("Attacker Wins", "Defender Wins")
colnames(trials.df) <<- do.call(condition.str, subset(conditions, select = -n))
})()

save(trials.df, trials.total.df, file="trials.Rdata")
