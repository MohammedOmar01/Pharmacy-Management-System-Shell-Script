#!/usr/bin/env bash
                                
INV="inventory.txt"                     # part 1 (cheack the file and auto detect )
CUS="customers.txt"                           # global files name
SAL="sales.txt"
ERR="error.txt"
LOG="logs.txt"
while true; do                                # the mein loop for the outer menu   

if [ ! -f "$INV" ] || [ ! -f "$CUS" ] || [ ! -f "$SAL" ] || [ ! -f "$ERR" ] || [ ! -f "$LOG" ]; then
dialog --msgbox "Error: Required system files are missing!\\nPlease make sure the following files exist,\\n- inventory.txt\\n- customers.txt\\n- sales.txt\\n- error.txt\\n- log.txt" 0 0
  exit 1
fi

printf '[%s] IMPOTANT NOTE : the script launched by [%s]\n' "$(date '+%F %T')" "$(whoami)" >>"$LOG"
###################################################################################################
today=$(date +%s) > tmp.txt

while read -r line; do                      # read each line in the file inventory ( done < .txt ) 

  [ -z "$line" ] && continue                # skip empty line in the inventory and continue 

  name=$(echo "$line" | cut -d'|' -f1)      # split each line into 5 feild that have '|' between them
  qty=$(echo "$line" | cut -d'|' -f2)
  price=$(echo "$line" | cut -d'|' -f3)
  expiry=$(echo "$line" | cut -d'|' -f4)
  category=$(echo "$line" | cut -d'|' -f5)  
    
  exp_seconds=$(date -d "$expiry" +%s)     # we have the date in secaned and we have the expierd date also in secand
                                            
  if [ $? -ne 0 ]; then                  # cheack if our date in secaned is valid 
    echo "the expired data is wrong ! -> $expiry"
    
    echo "$(date '+%F %T') DETECT AN ERROR : invalid expiry date: $expiry" >> error.txt
    
    continue
  fi
                                          # if the data is data is less than our date then it will be removed
  if [ "$exp_seconds" -ge "$today" ]; then # but if not we copy it ro the tmp file so that no data losses
    echo "$name|$qty|$price|$expiry|$category" >> tmp.txt
  else
    echo "$(date '+%F %T') removed expired $name expired $expiry" >> logs.txt
    echo "[EXPIRED]|$name|$qty|$price|$expiry|$category" >> logs.txt     # move the expierd to the logs.txt
  fi

done < inventory.txt

cat tmp.txt > inventory.txt

#################################-----Part 2 : Main Menu-----###################################
              
op=$(dialog --title "-----Main Menu-----" --menu "Pick a choice..." 0 0 0 \
1 "Inventory Management" \
2 "Sales Management" \
3 "Reporting" \
4 "Search" \
0 "Exit" 3>&1 1>&2 2>&3 3>&-)
     
              
              
  
  #################################-----Part 3.1 : Inventory mangment (ADDING)-----###################################
  if [ "$op" = 1 ]; then  
    while true; do    
                                                      # going to the next infinite loop 
op1=$(dialog --title "-----INVENTORY MENU-----" --menu "Pick a choice." 0 0 0 \
1 "Add medicine" \
2 "Update medicine" \
3 "Show inventory" \
4 "Back" 3>&1 1>&2 2>&3 3>&-)                                         
     
      case "$op1" in                                  
   1)  
  n=$(dialog --inputbox "enter medicin name:" 0 0 3>&1 1>&2 2>&3 3>&-) 
                             # adding name 
          
            if [ -z "$n" ]; 
            then                    
          dialog --msgbox "enter a name!" 0 0                     
         echo "$(date '+%F %T') DETECT AN ERROR : invalid Name since it been used : $n" >> error.txt        
           continue
           fi
            f=$(grep -i "^$n|" "$INV")             # start at the beginning of the line to see if it exists or not  
            if [ -n "$f" ]; 
           then
        echo "$(date '+%F %T') DETECT AN ERROR : invalid Name since it been used : $n" >> error.txt        
            dialog --msgbox "already exists...." 0 0
          	  continue
            fi 

    q=$(dialog --inputbox "Quantity:" 0 0 3>&1 1>&2 2>&3 3>&-) 
           
            if [[ ! $q =~ ^[0-9]+$ ]] || [ "$q" -le 0 ];     # check if the qantity is a valid integer only or less that zero
            then
      echo "$(date '+%F %T') DETECT AN ERROR : invalid qantity number : $q" >> error.txt  
      dialog --msgbox "enter an integer number!" 0 0
            
  		continue
	 fi
            
  p=$(dialog --inputbox "Price:" 0 0 3>&1 1>&2 2>&3 3>&-)
            

		if [[ ! $p =~ ^[0-9]+(\.[0-9]{1,2})?$ ]]; 
		then                                                 # the price can be a 1.1 , 2.0 
	  echo "$(date '+%F %T') DETECT AN ERROR : invalid price: $p" >> error.txt        
	  dialog --msgbox "its not a price!..." 0 0
  			
  		    continue
		fi

e=$(dialog --inputbox "Expir date YYYY-MM-DD:" 0 0 3>&1 1>&2 2>&3 3>&-)
           
	   if ! date -d "$e" '+%F'; then                 # the date should be correct according to the date formila
  		dialog --msgbox "it not a correct date! $e"
  		echo "$(date '+%F %T') DETECT AN ERROR : invalid expiry date entered: $e" >> error.txt
  		continue
			fi
C=$(dialog --inputbox "Category:" 0 0 3>&1 1>&2 2>&3 3>&-)

             if [ -z "$C" ]; then                        # category may be any mixed number and word 
             dialog --msgbox "enter a category..." 0 0
           echo "$(date '+%F %T') DETECT AN ERROR : The user not enter the category" >> error.txt 
                                                          
                                                         # so if the user not entiring any thing then detect an error 
  		continue
		fi
            printf '%s|%s|%s|%s|%s\n' "$n" "$q" "$p" "$e" "$C" >>"$INV"                      # printing all the reqirment to the inventory 
            printf '%s IMPORTANT INFORMATION : added %s\n' "$(date '+%F %T')" "$n" >>"$LOG"  # print the adding result to the file
            ;;
#################################-----Part 3.2 : UPDATEING-----################################### 
   2)  
   n1=$(dialog --inputbox "What the medicines name?:" 0 0 3>&1 1>&2 2>&3 3>&-)
	  
	rr=$(grep -i "^$n1|" "$INV")          # serach if there is a name like the user enter it, if yes give me the line       
	if [ -z "$rr" ];
	 then
	 dialog --msgbox "Not found try another name..." 0 0    
        echo "$(date '+%F %T') DETECT AN ERROR : invalid name (Not found) : $rr" >> error.txt         
 	 continue
	fi                                    # every error will printed to the error file
	
	q1=$(echo "$rr" | cut -d'|' -f2)       # cut the line according to the feled f2 f3 f4 f5 and store thim in varible to update thim 
	p1=$(echo "$rr" | cut -d'|' -f3)
	e1=$(echo "$rr" | cut -d'|' -f4)
	c1=$(echo "$rr" | cut -d'|' -f5)

    QQ=$(dialog --inputbox "Qantity before : $q1 | the new qantity:" 0 0 3>&1 1>&2 2>&3 3>&-)
	    # start with the quantity before and after 
	   if [ -z "$QQ" ];
        then
  	QQ="$q1"                                      
	fi
	
	if [[ ! "$QQ" =~ ^[0-9]+$ ]] || [ "$QQ" -le 0 ];       # the same step in part 3.1 for verification 
	 then
	 dialog --msgbox "incorrect quantity!" 0 0
      echo "$(date '+%F %T') DETECT AN ERROR : invalid quantity number : $QQ" >> error.txt        
 	 continue
	fi

PP=$(dialog --inputbox "Old price is : $p1 | the new price:" 0 0 3>&1 1>&2 2>&3 3>&-)
	
	if [ -z "$PP" ];
	 then
 	 PP="$p1"
	fi
	if [[ ! "$PP" =~ ^[0-9]+(\.[0-9]{1,2})?$ ]];
        then
        dialog --msgbox "invalid price!..." 0 0
 	echo "$(date '+%F %T') DETECT AN ERROR : invalid price while updating: $PP" >> error.txt        
 	 continue
	fi
ee=$(dialog --inputbox "The old date expierd is: $e1 | enter the new date expierd:" 0 0 3>&1 1>&2 2>&3 3>&-)

	if [ -z "$ee" ]; then
 	 ee="$e1"
	fi
	if ! date -d "$ee" '+%F';
	 then
	 dialog --msgbox "incorrect date!...." 0 0
    echo "$(date '+%F %T') DETECT AN ERROR : invalid expired date entered: $ee" >> error.txt
 	 continue
	fi
C=$(dialog --inputbox "the old category name : $c1 | The new category name is:" 0 0 3>&1 1>&2 2>&3 3>&-)
	
	if [ -z "$C" ]; then
 	 C="$c1"
	fi
 
                                                # after we have all new value , then update the inventory 
	grep -iv "^$n1|" "$INV" > tmp.txt
	
	printf '%s|%s|%s|%s|%s\n' "$n1" "$QQ" "$PP" "$ee" "$C" >> tmp.txt
	cat tmp.txt > "$INV"             
                                                # print in the file that the name has been updated
	printf '[%s] IMPORTANT INFORAMTION : %s Has updated\n' "$(date '+%F %T')" "$n1" >> "$LOG"

            ;;
#################################-----Part 3.3 : Show the inventory-----################################### 
  3)  
  
  dialog --title "NAME|QTY|PRICE|EXP|CAT:" --textbox "$INV" 0 0
                              # enter 3 to show the inventory
            ;;
#################################-----Part 3.4 : back to the main loop-----################################### 
4)  break                                    
              ;;
*)  break
         ;;
      esac
    done


#################################-----Part 4.1 : Sales Management-----###################################
  elif [ "$op" = 2 ];
   then
   inv="$INV"
   cus="$CUS"
   sal="$SAL"

    while true; do                   # going to the sales system 
  op2=$(dialog --title "-----SALES MENU-----" --menu "Pick a choice." 0 0 0 \
1 "Process sale" \
2 "Back" 3>&1 1>&2 2>&3 3>&-)   
    
    
     case "$op2" in
      
 1)  
  MED=$(dialog --inputbox "Enter the medicine name:" 0 0 3>&1 1>&2 2>&3 3>&-)
   
   
   rec=$(grep -i "^$MED|" "$INV")

  if [ -z "$rec" ];
   then
   dialog --msgbox "No medicine like this name..." 0 0
                       # cheack if the name is name of the product is in inventory 
         echo "$(date '+%F %T') DETECT AN ERROR : invalid name (Not found) : $MED" >> error.txt         
 continue
fi

  n2=$(echo "$rec" | cut -d'|' -f1)                            # cut all feled 
  q2=$(echo "$rec" | cut -d'|' -f2)
   p2=$(echo "$rec" | cut -d'|' -f3)
  e2=$(echo "$rec" | cut -d'|' -f4)
   c2=$(echo "$rec" | cut -d'|' -f5)

qty=$(dialog --inputbox "Quantity to sell:" 0 0 3>&1 1>&2 2>&3 3>&-)
	
                                                               # show many quantity we whant to sell and cheack for the correct numbers 
	if [[ ! "$qty" =~ ^[0-9]+$ ]] || [ "$qty" -le 0 ];
	 then
	 dialog --msgbox "incorrect quantity...." 0 0
 	       echo "$(date '+%F %T') DETECT AN ERROR : invalid qantity number : $qty" >> error.txt        
 	 continue
	fi

	if [ "$qty" -gt "$q2" ];                              # if the quantiity we need to sell is bugger than we have so we can not sell
	 then
	 dialog --msgbox "Only $q2 in stock..." 0 0
 	 
 	 continue
	fi
cname=$(dialog --inputbox "Customer name:" 0 0 3>&1 1>&2 2>&3 3>&-)
	                           # the name of the custumer 
	if [ -z "$cname" ];                    
	 then
	 dialog --msgbox "enter the name again..." 0 0
   echo "$(date '+%F %T') DETECT AN ERROR : invalid name (Not found) : $cname" >> error.txt      
      
      continue
 	 
     fi

ccont=$(dialog --inputbox "Customer contact:" 0 0 3>&1 1>&2 2>&3 3>&-)                      # get the customer contact 
		

	                                        # calculate total price ( for the left side and the right side of the number ex: 1.70)
	int_part=${p2%%.*}
	
	dec_part=${p2#*.}
	
	if [ "$dec_part" = "$p2" ];
     then
  	dec_part=00
	fi
	
	if [ ${#dec_part} -eq 1 ];
	
	 then
	 
 	 dec_part=${dec_part}0
	fi
	
	cents=$((10#$int_part * 100 + 10#$dec_part))
	
	tot=$((cents * qty))
	
	total=$(printf '%d.%02d' $((tot/100)) $((tot%100)))

	                                                          # update inventory 
	new_qty=$((q2 - qty))
	
	grep -iv "^$n2|" "$inv" > tmp.txt
	
	printf '%s|%s|%s|%s|%s\n' "$n2" "$new_qty" "$p2" "$e2" "$c2" >> tmp.txt
	cat tmp.txt > "$inv"
	                                                          # update customer and sales 
	if ! grep -qi "^$cname|$ccont" "$cus";
	 then
 	 printf '%s|%s|\n' "$cname" "$ccont" >> "$cus"
 	 
	fi

	today=$(date +%F)                                        # print all the receipt and save the invoramtion to the sales file
	printf '%s|%s|%s|%s|%s\n' "$today" "$n2" "$qty" "$total" "$cname" >> "$sal"
 
 dialog --msgbox "Sale completed for $cname, total: $total" 0 0
	
dialog --title "------ RECEIPT ------" --msgbox " \\n Date      : $today \\n Customer  :$cname \\n Medicine  : $n2 \\n Quantity  : $qty\\nTotal     : $total" 0 0
            
   

            
 printf '%s IMPORTANT INFORAMTION : sold %s x%s to %s\n' "$(date '+%F %T')" "$med" "$qty" "$cname" >>"$LOG"
            ;;
#################################-----Part 4.2 : back to the main-----###################################
   2)  break
            ;;
        *)  break ;;
      esac
    done
#################################-----Part 5.1 REPORTING-----###################################
  elif [ "$op" = 3 ]; 
  then
   while true;
    do   
  r=$(dialog --title "----- REPORT MENU -----" --menu "Pick a choice..." 0 0 0 \
1 "Low-stock list" \
2 "Show expired medicines" \
3 "Sales report (date range)" \
4 "Top-k medicines by qty sold" \
5 "Back" 3>&1 1>&2 2>&3 3>&-)
  
#################################-----Part 5.2 Low stock-----###################################
  if [ "$r" = "1" ];
   then
  th=$(dialog --inputbox "define your quantity:" 0 0 3>&1 1>&2 2>&3 3>&-)
   

    if [[ ! "$th" =~ ^[0-9]+$ ]] || [ "$th" -le 0 ];
    
     then
        echo "$(date '+%F %T') DETECT AN ERROR : invalid Quantity : $th" >> error.txt      
     dialog --msgbox "its not a quantity!" 0 0
      
      continue
    fi
    
    while read -r line;
     do
      [ -z "$line" ] && continue

      n=$(echo "$line" | cut -d'|' -f1)
      q=$(echo "$line" | cut -d'|' -f2)

      
    if [ "$q" -lt "$th" ]; then
        result+="$n | $q\n"
    fi
done < "$INV"

if [ -n "$result" ]; then
    dialog --title "Medicines Below Threshold" --msgbox "$(echo -e "$result")" 0 0 
else
    dialog --msgbox "All medicine quantities are OK." 6 40
fi

#################################-----Part 5.3 expired medicines-----###################################
  elif [ "$r" = "2" ];
   then
    now=$(date +%s)
    
    while read -r line;
     do
      [ -z "$line" ] && continue

      n=$(echo "$line" | cut -d'|' -f1)
      q=$(echo "$line" | cut -d'|' -f2)
      e=$(echo "$line" | cut -d'|' -f4)

      esec=$(date -d "$e" +%s )
      if [ $? -ne 0 ]; then
      dialog --msgbox "Invalid date..." 0 0 
  
  echo "date/time ERROR: Invalid date ..." >> error.txt
  continue
            fi

      if [ -n "$esec" ] && [ "$esec" -lt "$now" ];
       then
       dialog --msgbox "$n|$q|$e" 0 0
       
      fi

    done < "$INV"

   res=$(grep "\[EXPIRED\]" logs.txt | cut -d'|' -f2-5)
    
dialog --msgbox "$res" 0 0

#################################-----Part 5.4 date range-----###################################
  elif [ "$r" = "3" ];
  then
  start_date=$(dialog --inputbox "Start date in Form : (YYYY-MM-DD):" 0 0 3>&1 1>&2 2>&3 3>&-)
   
  end_date=$(dialog --inputbox "End date in Form : (YYYY-MM-DD):" 0 0 3>&1 1>&2 2>&3 3>&-)
   

    start_sec=$(date -d "$start_date" +%s)
    
    if [ $? -ne 0 ];
     then
     dialog --msgbox "invalid start date format: $start_date" 0 0 
   
      
   echo "$(date '+%F %T') ERROR: invalid start date: $start_date" >> error.txt
      
      continue
      
    fi
    end_sec=$(date -d "$end_date" +%s)
    
  if [ $? -ne 0 ]; 
    then
    dialog --msgbox "invalid end date format: $end_date" 0 0 
     
    echo "$(date '+%F %T') Error: invalid end date $end_date" >> error.txt
       		continue
          fi

    total_sales_cents=0
    report=""
   
    while read -r line;
     do
      [ -z "$line" ] && continue

      sale_date=$(echo "$line" | cut -d'|' -f1)
      medicine=$(echo "$line" | cut -d'|' -f2)
      qty=$(echo "$line" | cut -d'|' -f3)
      total=$(echo "$line" | cut -d'|' -f4)
      customer=$(echo "$line" | cut -d'|' -f5)

      sale_sec=$(date -d "$sale_date" +%s)
      if [ $? -ne 0 ];
       then
       dialog --msgbox "its not a date sale or it not found: $sale_date" 0 0
        
        
        echo "$(date '+%F %T') IMPORTANT ERROR: incorrect sale date: $sale_date" >> error.txt
        
        continue
      fi

      if [ "$sale_sec" -ge "$start_sec" ] && [ "$sale_sec" -le "$end_sec" ];
       then
       report+="\n$sale_date | $medicine | $qty | $total | $customer"
        

        int_part=${total%%.*}
        
        dec_part=${total#*.}
        
        if [ "$dec_part" = "$total" ];
         then
          dec_part=00
        fi
        
        if [ ${#dec_part} -eq 1 ];
         then
          dec_part=${dec_part}0
        fi
        cents=$((10#$int_part * 100 + 10#$dec_part))
        
        total_sales_cents=$((total_sales_cents + cents))
      fi

    done < "$SAL"

  if [ -n "$report" ];
   then
   dialog --title "DATE | MEDICINE | QTY | TOTAL | CUSTOMER" --msgbox "$(echo -e "$report")" 20 70
   else
   dialog --msgbox "No sales found in this range." 0 0
  fi

  total_msg=$(printf "TOTAL SALES = %d.%02d" $((total_sales_cents / 100)) $((total_sales_cents % 100)))
  dialog --title "Sales Summary" --msgbox "$total_msg" 7 40

#################################-----Part 5.5 Top-k medicines by qantity sold-----###################################
  elif [ "$r" = "4" ];
   then
    k=$(dialog --inputbox "Enter k (number of top medicines to show):" 0 0 3>&1 1>&2 2>&3 3>&-)
   
    if [[ ! "$k" =~ ^[0-9]+$ ]] || [ "$k" -eq 0 ];
     then
     dialog --msgbox "Invalid k: $k" 0 0
      echo "Invalid k: $k"
      
      echo "$(date '+%F %T') Invalid top-k entered: $k" >> error.txt
      
      continue
    fi

    tmp_file="tmp_topk.txt" > "$tmp_file"

    while read -r line;
     do
      [ -z "$line" ] && continue

      medicine=$(echo "$line" | cut -d'|' -f2)
      qty=$(echo "$line" | cut -d'|' -f3)

      for _ in $(seq 1 "$qty"); do
            echo "$medicine" >> "$tmp_file"
        done

     

    done < "$SAL"
     top_meds=$(sort "$tmp_file" | uniq -c | sort -nr | head -n "$k")
  dialog --msgbox "$top_meds" 0 0
 
    
    rm -f "$tmp_file"
#################################-----Part 5.6 back to the main-----###################################
  elif [ "$r" = "5" ]; then
    break

  else
    break 
  fi
done



################################### ----SEARCH ----###################################

  elif [ "$op" = 4 ];
   then
  while true; do
  
  z=$(dialog --title "----- SEARCH MENU -----" --menu "Pick a choice..." 0 0 0 \
1 "Medicine by name" \
2 "Medicine by category" \
3 "Customer purchase history" \
4 "Back"  3>&1 1>&2 2>&3 3>&-)
  case $z in
1)
 
    kw=$(dialog --inputbox " the name of med :" 0 0 3>&1 1>&2 2>&3 3>&-)

    if [ -n "$kw" ]; then
        result=$(grep -i "$kw" "$INV")

        if [ -n "$result" ]; then
            dialog --title "Search Result" --msgbox "$result" 0 0
        else
            dialog --msgbox "No matches found." 0 0
        fi
    else
        dialog --msgbox "You didn't enter a name." 0 0
    fi
   ;;

2)
  kw=$(dialog --inputbox "Category : " 0 0 3>&1 1>&2 2>&3 3>&-)
  
  if [ -n "$kw" ]; then
        result=$(grep -i "|.*|.*|.*|.*$kw" "$INV")

        if [ -n "$result" ]; then
            dialog --title "Search Result" --msgbox "$result" 0 0
        else
            dialog --msgbox "No matches found." 0 0
        fi
    else
        dialog --msgbox "You didn't enter a category!..." 0 0
    fi   
    ;;

3)
   kw=$(dialog --inputbox "Customer name : " 0 0 3>&1 1>&2 2>&3 3>&-)
   
   if [ -n "$kw" ]; then
        result=$(grep -i "|.*|.*|.*|$kw" "$SAL")

        if [ -n "$result" ]; then
            dialog --title "Search Result" --msgbox "$result" 0 0
        else
            dialog --msgbox "No matches found." 0 0
        fi
    else
        dialog --msgbox "You did not enter a name!..." 0 0
    fi   
    ;;

4)
    break
    ;;

*)
    break 
    ;;
  esac
done


##############################################################################
  elif [ "$op" = 0 ];
   then

    dialog --msgbox "thanks for using our PMS...." 0 0 
    clear
    exit 1
  else
   clear  
   exit 1
  fi

done
