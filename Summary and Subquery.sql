
-- Description: SQL Problem sets using Summaries and Subqueries

-- #1
-- returns count of customers and max and min stay credits earned
select count(customer_id) as "count_of_customers",
    min(stay_credits_earned) as "min_credits",
    max(stay_credits_earned) as "max_credits"
    from customer;
 
-- #2
-- returns number of reservations and earliest check in for each customer
select c.customer_id, count(reservation_id) as "Number_of_Reservations",
    min(check_in_date) as "earliest_check_in"
    from customer c join reservation r
        on c.customer_id = r.customer_id
    group by c.customer_id;

-- #3
-- returns avg earned stay credits by state and city
select city, state, round(avg(stay_credits_earned)) as avg_credits_earned
    from customer
    group by state, city
    order by state, avg_credits_earned desc;

-- #4
-- returns count of customers in rooms with count > 1
select c.customer_id, c.last_name, ro.room_number, 
    count(r.reservation_id) as "stay_count"
    from customer c 
        join reservation r
            on c.customer_id = r.customer_id
        join reservation_details rd
            on rd.reservation_id = r.reservation_id
        join room ro
            on rd.room_id = ro.room_id
    where r.location_id = 1
    group by c.customer_id, c.last_name, ro.room_number
    having count(r.reservation_id) > 1
    order by customer_id, "stay_count" desc;

-- #5
-- returns count of customers in rooms with count > 2 and completed reservations
select c.customer_id, c.last_name, ro.room_number, 
    count(r.reservation_id) as "stay_count"
    from customer c 
        join reservation r
            on c.customer_id = r.customer_id
        join reservation_details rd
            on rd.reservation_id = r.reservation_id
        join room ro
            on rd.room_id = ro.room_id
    where r.location_id = 1 and r.status = 'C'
    group by c.customer_id, c.last_name, ro.room_number
    having count(r.reservation_id) > 2
    order by customer_id, "stay_count" desc;

-- helper function to check #5 answer
-- checks individual status of each customer and their room reservations
/*
select customer_id, r.reservation_id, ro.room_number, status
    from reservation r 
        join reservation_details rd
            on r.reservation_id = rd.reservation_id
        join room ro
            on rd.room_id = ro.room_id
    where customer_id = 100016 and r.location_id = 1 and
        ro.room_number = 112
    order by ro.room_number;
*/

-- #6 Part A
-- returns sum of guests for each location and check_in_date
select location_name, check_in_date, sum(number_of_guests)
    from reservation r join location l
        on r.location_id = l.location_id
    where check_in_date > sysdate
    group by ROLLUP(location_name, check_in_date);

-- #6 Part B
-- ROLLUP provides a summary column based on each location_name as well as a total summary
-- at the bottom of the result set. CUBE provides these summary columns in addition to 
-- a summary column based on each check_in_date. Compared to ROLLUP, CUBE essentially adds 
-- a new summary column for every combination of groups given in the GROUP BY clause.

-- #7
-- returns feature names of features at all 3 locations
select feature_name, count(l.location_id) as "count_of_locations"
    from location l 
        join location_features_linking lf
            on l.location_id = lf.location_id
        join features f
            on lf.feature_id = f.feature_id
    group by feature_name
    having count(l.location_id) > 2;

-- #8
-- returns customers who haven't had a reservation 
select customer_id, first_name, last_name, email
    from customer
    where customer_id not in 
        (select customer_id from reservation);

-- #9
-- returns customers with greater than average stay_credits earned
select first_name, last_name, email, phone, stay_credits_earned
    from customer
    where stay_credits_earned > 
        (select avg(stay_credits_earned) from customer)
    order by stay_credits_earned desc;
    
-- #10
-- returns customers' sum of stay credits used and earned by state and city
select city, state, sum(stay_credits_earned) as total_earned, 
    sum(stay_credits_used) as total_used
    from customer
    group by state, city
    order by state, city;

-- returns customers' total remaining stay credits by state and city
select city, state, (tab.total_earned - tab.total_used) as credits_remaining
from (select city, state, sum(stay_credits_earned) as total_earned, 
    sum(stay_credits_used) as total_used
    from customer
    group by state, city) tab
    order by credits_remaining desc;

-- #11
-- returns reservation info for rooms that have historically been reserved < 5 times
select confirmation_nbr, date_created, check_in_date, status, room_id
    from reservation r 
        join reservation_details rd 
            on r.reservation_id = rd.reservation_id
    where rd.room_id in
    (select room_id 
        from reservation_details 
        group by room_id
    having count(reservation_id) < 5)
    and status <> 'C';
    
-- #12
--returns customer card information of those using Mastercard and have completed only 1 reservation
select cardholder_first_name, cardholder_last_name, card_number, 
        expiration_date, cc_id
    from customer_payment cp 
        join 
        ( select customer_id, count(reservation_id)
            from reservation
            where status = 'C' 
            group by customer_id
            having count(reservation_id) = 1 ) r
        on cp.customer_id = r.customer_id
        where card_type = 'MSTR';
    








