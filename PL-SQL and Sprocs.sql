 set serveroutput on;
 
 -- #1
 -- initalizes count of reservations variable and prints if customer has more or fewer than 15 reservations
declare
    count_reservations number;
begin
    select count(reservation_id)
    into count_reservations
    from reservation
    where customer_ID = 100002;
    
    if count_reservations > 15 then
        dbms_output.put_line('The customer has placed more than 15 reservations');
    else
        dbms_output.put_line('The customer has placed 15 or fewer reservations');
    
    end if;

end;
/

/* delete from reservation_details where reservation_id = 318;
delete from reservation where reservation_id = 318;
rollback; */

-- #2
-- prints whether reservation count > or < 15 of inputted customer ID
set define on;

declare
    count_reservations number;
    customer_id_var number;
begin
    customer_id_var := &number;
    select count(reservation_id)
    into count_reservations
    from reservation
    where customer_ID = customer_id_var;
    
    if count_reservations > 15 then
        dbms_output.put_line('The customers with customer ID: ' || customer_id_var || ', has placed more than 15 reservations');
    else
        dbms_output.put_line('The customers with customer ID: ' || customer_id_var || ', has placed fewer than 15 reservations');
    
    end if;

end;
/

-- #3
-- inserts row into customer table
begin
    insert into customer 
    (customer_id, first_name, last_name, email, phone, address_line_1, city, state, zip ) 
    values (customer_id_seq.nextval, 'Monish', 'Jay','monishjay@gmail.com', '111-222-3333', '9 Burrows Avenue', 'Austin', 'TX', '78717');
    
    dbms_output.put_line('1 row was inserted into the customer table.');
    
    exception
        when others then
            dbms_output.put_line('Row was not inserted. Unexpected exception occurred.');
            rollback;
  commit;
  
end;
/

--delete from customer where first_name = 'Monish';

-- #4
-- uses bulk collect to display features that start with 'P'
declare 
    type features_table     is table of VARCHAR2(100 BYTE);
    features_names          features_table;

begin
    select feature_name
    bulk collect into features_names
    from features
    where substr(feature_name, 1,1) = 'P'
    order by feature_name; 

    for i in 1..features_names.count loop
        dbms_output.put_line('Hotel feature ' || i || ': ' || features_names(i));
    end loop;
end;
/


-- #5
-- uses cursor to output location_name, city and feature_name

set define on;

declare 
    city_var location.city%TYPE;
    cursor features_cursor is
        select location_name, city, feature_name 
        from location_features_linking lf 
            join location l
                on lf.location_id = l.location_id
            join features f
                on lf.feature_id = f.feature_id
        order by location_name, city, feature_name;
    
    row features%rowtype;
begin    
    city_var := '&city';
    for row in features_cursor loop
    if city_var = row.city then
         dbms_output.put_line(row.location_name || ' in ' || row.city || ' has feature: ' || row.feature_name);
    end if;
    end loop;

end;
/

-- #6
-- creates procure that inserts data into customer table
create or replace procedure insert_customer
(
  first_name_par customer.first_name%type,
  last_name_par customer.last_name%type,
  email_par customer.email%type,
  phone_par customer.phone%type,
  address_line_1_par customer.address_line_1%type,
  city_par  customer.city%type,
  state_par customer.state%type,
  zip_par  customer.zip%type
)
as
begin
    --insert into customer (customer_id, first_name, last_name, email, phone, address_line_1, city, state, zip)
    --values (customer_id_seq.nextval, first_name_par, last_name_par, email_par, phone_par, address_line_1_par, city_par,
    --state_par, zip_par);
    insert into customer (customer_id, first_name, last_name, email, phone, address_line_1, city, state, zip)
    values (customer_id_seq.nextval, first_name_par, last_name_par, email_par, phone_par, address_line_1_par, city_par, state_par, zip_par);
    
commit;

exception
  when others then
    dbms_output.put_line('Row was not inserted. Unexpected exception occurred.');
    rollback;


end;
/


-- tests insert_customer 

--CALL insert_customer ('Joseph', 'Lee', 'jo12@yahoo.com', '773-222-3344', 'Happy street', 
--'Chicago', 'Il', '60602');

/* BEGIN
insert_customer ('Mary', 'Lee', 'jo34@yahoo.com', '773-222-3344', 'Happy street', 
'Chicago', 'Il', '60602');
END;
/ */

-- #7
-- creates function that returns total rooms a customer has reserved
create or replace function hold_count
(
    customer_id_par number
)
return number
as
    numRooms number;

begin
select count(rd.room_id)
    into numRooms
    from reservation_details rd join reservation r 
    on r.reservation_id = rd.reservation_id
    where customer_id = customer_id_par;
    
return numRooms;
end;
/

-- tests #7
/* 
select customer_id, hold_count(customer_id)  
from reservation
group by customer_id
order by customer_id; 
*/


  
  
  
  
