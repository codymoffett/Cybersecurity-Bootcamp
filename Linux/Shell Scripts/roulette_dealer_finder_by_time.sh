#!/bin/bash
cat $2_Dealer_schedule | sed s/:00:00" "AM/AM/ | sed s/:00:00" "PM/PM/ >> temp_file 
(echo $2 && grep $1 temp_file | awk -F[" ""\t"] '{print $1, $4, $5}')
rm temp_file

# $1 = (TimeAM/PM) example: (12AM) or (03PM) , $2 = Dealer schedule Month/Day in mmdd format example: March 10 = 0310

