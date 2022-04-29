
-- Description: Set of SQL Functions: 

-- #1: Put system date into dual (dummy table), add variations of date for each succeeding row in dual table using SQL functions
-- #2: Query which retrieves a future reservation where the check in date is after today's date and has an "Upcoming" status
-- #3: Pulls list of customer names who have a completed reservation in last 30 days based on check_out_date
-- #4: Returns reservation and customers for specific date (Nov. 5th 2021) with their anticipated total of their reservation 
-- #5: Returns specified columns from customer_payment table
-- #6: Returns specific columns for each customer address
-- #7: Returns list of customers with their "redacted" credit card number on file
-- #8: Returns results which are joined between tables using a CASE statement
-- #9: Returns certain data for each customer in database
-- #10: Updates query from #9 by turning it into an in-line join subuery


-- #1
-- returns set of formatted dates
-- spacing on date_with_hours
select sysdate,
    upper(to_char(sysdate, 'year')) as year,
    upper(to_char(sysdate,'day month')) as day_month,
    to_char(sysdate, 'mm/dd/yy -') || ' hour:' || (to_char(sysdate, 'HH')) as date_with_hours,
    365 - to_char(sysdate, 'ddd') as  days_til_end_of_year,
    lower(to_char(sysdate, 'mon dy yyyy')) as lowercase
from dual;

-- #2
-- returns data for future reservations
select reservation_id, customer_id, 
      'Checking in on ' || to_char(check_in_date, 'Day') || ' - ' || to_char(check_in_date, 'Mon dd, yyyy') as arrival_date,
      'at ' || case location_id 
            when 1 then 'South Congress'
            when 2 then 'East 7th'
            when 3 then 'Balcones Cabins'
            end LOCATION_NAME,
       nvl(notes, ' ') as notes
    from reservation
    where status = 'U' and check_in_date > sysdate
    order by check_in_date;

-- #3
-- returns customers who have completed reservation and checked out in last 30 days
select upper(substr(first_name,1,1) || '. ' || c.last_name) as customer_name,
    check_in_date, check_out_date, c.email
    from customer c join reservation r
        on c.customer_id = r.customer_id
    where check_out_date >= (sysdate - 30)
    order by check_out_date;
    
-- #4
-- returns anticipated total for customers checking in on November 5th
select r.reservation_id, r.customer_id,
    to_char(ro.weekend_rate * 1.1 * 2, '$999.99') as anticipated_total
    from reservation r
        join reservation_details rd
            on r.reservation_id = rd.reservation_id
        join room ro
            on ro.room_id = rd.room_id
    where check_in_date = '5-Nov-2021';

-- #5
-- returns days till expiration for customer credit cards 
select cardholder_last_name,
    length(billing_address) as billing_address_length,
    round(expiration_date - sysdate) as days_until_card_expiration
    from customer_payment
    where expiration_date > sysdate
    order by days_until_card_expiration;

-- #6
-- returns customer address information
select last_name, 
    substr(address_line_1,0,instr(address_line_1, ' ')) as Street_Nbr,
    ltrim(substr(address_line_1,instr(address_line_1, ' '))) as Street_Name,
    nvl(address_line_2,'n/a') as Address_line_2_listed,
    city, state, zip
    from customer;

-- #7
-- returns customer payment info with redacted card number
select first_name || ' ' || last_name as Customer_Name,
    card_type, 
    '****-****-****-' || substr(card_number, length(card_number) - 3) as redacted_card_num
    from customer c join customer_payment cp
        on c.customer_id = cp.customer_id
    where card_type in ('MSTR', 'VISA')
    order by last_name;

-- #8 
-- returns status level of customer based on stay credits
select case 
    when stay_credits_earned < 10 then '1-Gold Member'
    when stay_credits_earned >= 10 and stay_credits_earned < 40 then '2-Platinum Member'
    when stay_credits_earned >= 40 then '3-Diamond Club'
    end as status_level,
    first_name, last_name, email, stay_credits_earned
from customer
order by 1, 3;

-- #9 and #10
-- returns top 10 customers with most stay_credits_earned
select first_name, last_name, customer_id, email, 
stay_credits_earned, Customer_Rank 
    from
    (select first_name, last_name, customer_id, email, stay_credits_earned,
    rank() over (order by stay_credits_earned desc) as Customer_Rank
    from customer )
    where rownum <= 10;
