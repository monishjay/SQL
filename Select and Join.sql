
-- Description: SQL Problem sets using SELECT and JOIN statements


 -- problem 1
 -- returns all customer cardholder information 
select cardholder_first_name, cardholder_last_name, card_type, expiration_date
    from customer_payment
    order by expiration_date;

-- problem 2
-- returns all customer names with first names starting with A,B,C
select first_name || ' ' || last_name
    from customer
    where substr(first_name,1,1) in ('A','B','C')
    order by last_name;

-- problem 3
-- returns upcoming reservation info within this year
select customer_id, confirmation_nbr, date_created, check_in_date, number_of_guests
    from reservation
    where status = 'U' and check_in_date >= sysdate and check_in_date <= '31-December-2021';

-- problem 4a
-- returns upcoming reservation info within this year
(select customer_id, confirmation_nbr, date_created, check_in_date, number_of_guests
    from reservation
    where status = 'U' and check_in_date between sysdate and '31-December-2021');

-- problem 4b
-- returns difference in result sets between both above queries
(select customer_id, confirmation_nbr, date_created, check_in_date, number_of_guests
    from reservation
    where status = 'U' and check_in_date >= sysdate and check_in_date <= '31-December-2021') 
    
minus
    
(select customer_id, confirmation_nbr, date_created, check_in_date, number_of_guests
            from reservation
            where status = 'U' and check_in_date between sysdate and '31-December-2021');

--problem 5
-- returns first 10 rows of completed reservations info
select customer_id, location_id, (check_out_date - check_in_date) as length_of_stay 
    from reservation
    where status = 'C' and ROWNUM <= 10
    order by length_of_stay desc, customer_id;
    

-- problem 6
-- returns customers with at least 10 credits available
select first_name, last_name, email, stay_credits_earned - stay_credits_used as credits_available
    from customer
        where stay_credits_earned - stay_credits_used >= 10
    order by credits_available;

-- problem 7
-- returns customer cardholder info for those who have a middle name
select cardholder_first_name, cardholder_mid_name, cardholder_last_name
    from customer_payment
    where cardholder_mid_name is not null
    order by 2,3;

-- problem 8
-- returns formatted and unformatted dates with test data in dual table
select sysdate as today_unformatted,
       to_char (sysdate, 'MM/DD/YYYY') as today_formatted,
       25 as Credits_Earned,
       25/10 as Stays_Earned,
       Floor(25/10) as Redeemable_stays,
       Round(25/10) as Next_Stay_to_earn
    from dual;
    
-- problem 9
-- returns first 20 rows of completed reservation info at location 2
select customer_id, location_id, check_out_date - check_in_date as length_of_stay
    from reservation
    where status = 'C' and location_id = 2
    order by length_of_stay desc, customer_id
    fetch first 20 rows only;

-- problem 10 
-- returns customer and reservation info of completed reservations
select first_name, last_name, confirmation_nbr, date_created, check_in_date, check_out_date
    from reservation r JOIN customer c
        ON r.customer_id = c.customer_id
    where r.status = 'C'
    order by c.customer_id, r.check_out_date desc; 
    
    
-- problem 11
-- return matching customer, upcoming reservation and details, and room information
select first_name || ' ' || last_name as "Name", l.location_id, confirmation_nbr, check_in_date, room_number
    from customer c
        join reservation r
            on c.customer_id = r.customer_id
        join location l
            on l.location_id = r.location_id
        join reservation_details rd
            on rd.reservation_id = r.reservation_id
        join room ro
            on ro.room_id = rd.room_id
    where r.status = 'U' and c.stay_credits_earned > 40;
    

-- problem 12
-- returns customers who've never had a reservation
select first_name, last_name, confirmation_nbr, date_created, check_in_date, check_out_date
    from customer c
        left join reservation r
            on c.customer_id = r.customer_id
        where r.customer_id is null;
    
-- problem 13
-- returns status levels of customers
    select '1-Gold Member' as "Status_level", first_name, last_name, email, stay_credits_earned
        from customer
        where stay_credits_earned < 10
UNION
    select '2-Platinum Member' as "Status_level", first_name, last_name, email, stay_credits_earned
        from customer
        where stay_credits_earned >= 10 and stay_credits_earned < 40
UNION
    select '3-Diamond Club' as "Status_level", first_name, last_name, email, stay_credits_earned
        from customer
        where stay_credits_earned >= 40
    order by 1,3;
    

    



