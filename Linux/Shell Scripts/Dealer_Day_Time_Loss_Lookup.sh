#!/bin/bash
(echo $2 && grep $1 $2_Dealer_schedule | grep $3 |  awk -F[:" ""\t"] '{print $1, $4, $7, $8}') >> Dealer_working_during_losses 

# $1 = Time (hour of day) , $3 = AM/PM , $2 = Dealer schedule Month/Day in mmdd form (ex: March 10 = 0310)

