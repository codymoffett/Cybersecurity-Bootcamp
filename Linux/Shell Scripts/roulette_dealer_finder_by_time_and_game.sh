#!/bin/bash
cat $2_Dealer_schedule | sed s/:00:00" "AM/AM/ | sed s/:00:00" "PM/PM/ >> temp_file_any_game

# $1 = TimeAM/PM) example: (12AM) or (03PM) , $2 = Dealer schedule Month/Day in mmdd format. Example: March 10 = 0310

if [ $3 -eq 1 ]
then
	(echo $2 && grep $1 temp_file_any_game | awk -F[" ""\t"] '{print $1, $2, $3}')
	rm temp_file_any_game
fi

# first if / then is for BlackJack 

if [ $3 -eq 2 ]
then
	(echo $2 && grep $1 temp_file_any_game | awk -F[" ""\t"] '{print $1, $4, $5}')
	rm temp_file_any_game
fi

# second if / then is for Roulette

if [ $3 -eq 3 ] 
then
	(echo $2 && grep $1 temp_file_any_game | awk -F[" ""\t"] '{print $1, $6, $7}')
	rm temp_file_any_game
fi

# third if / then is for Texas Hold Em

if [ $3 -ge 4 ]
then
	(echo "Invalid Game Type Entry! 1 = BlackJack , 2 = Roulette , 3 = Texas Hold Em")
	rm temp_file_any_game
fi

# fourth if / then deals with invalid game type enteries

if [ $3 -le 0 ]
then
	(echo "Invalid Game Type Entry! 1 = BlackJack , 2 = Roulette , 3 = Texas Hold Em")
	rm temp_file_any_game
fi

# fifth if / then  deals with invalid game type enteries

