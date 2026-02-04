extends StateMachine


#state init
#state loading
#state matching
#state matched
#state completed

# state loading
# init vars
# go to matching state

#state matching:
#if the sentence button is clicked and it matches the pronoun
#	state transition to matched
#if the sentence button is clicked and it doesn't match
#	increase error count

# state matched:
# change colors of sentence buttons
# if continue button is clicked: transition to exit state

# exit state:
# emit complete_exercise signal
# transition to init state
