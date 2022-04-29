
-- Description: ETL (Extract - Transform - Load) Process 

-- 1. Creates new table to serve as data warehouse for current and acquired customers 
-- 2. Creates view statements to format data from both tables in a unified, consistent format
-- 3. Select columns from view and insert into original customer data warehouse if records don't already exist
-- 4. Update records on customer data warehouse with latest data from the source views
-- 5. Create customer ETL procedure to execute insert / update statements to moodify customer data warehouse


-- creates customer datawarehouse table to compile customers and acquired customers
drop table customer_dw;
create table customer_dw 
(
data_source varchar(4),
customer_id number,
first_name varchar2(100),
last_name varchar2(100),
email varchar2(100),
phone char (15),
zip char(5),
stay_credits_earned number,
stay_credits_used number,

constraint pk_id_source primary key (data_source, customer_id)
);


-- creates 2 views that formats data from both customer tables
create or replace view customer_view 
as
select 'CUST' as data_source, customer_id, first_name, last_name, email, phone, zip, stay_credits_earned, stay_credits_used
from customer;

create or replace view customer_acquisition_view 
as
select 'AQUI' as data_source, acquired_customer_id as customer_id, ca_first_name as first_name, ca_last_name as last_name, 
ca_email as email, ca_phone as phone, ca_zip_code as zip, ca_credits_remaining as stay_credits_earned, 0 as stay_credits_used
from customer_acquisition;


-- select from views and insert new records into customer_dw 

-- insert customer records
insert into customer_dw 
select c.data_source, c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.zip, c.stay_credits_earned, c.stay_credits_used
from customer_view c left join customer_dw cd
    on c.customer_id = cd.customer_id
    and c.data_source = cd.data_source
where cd.customer_id is null;

-- insert customer acquisition records
insert into customer_dw 
select c.data_source, c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.zip, c.stay_credits_earned / 2, c.stay_credits_used
from customer_acquisition_view  c left join customer_dw cd
    on c.customer_id = cd.customer_id
    and c.data_source = cd.data_source
where cd.customer_id is null;


-- updates customer_dw table with latest name, email, phone, zip or credits from source views

-- merges customer table data
merge into customer_dw cd
    using customer_view c
    on (c.customer_id = cd.customer_id and c.data_source = cd.data_source)
    when matched then
        update set 
            cd.first_name = c.first_name,
            cd.last_name = c.last_name,
            cd.email = c.email,
            cd.phone = c.phone,
            cd.zip = c.zip,
            cd.stay_credits_earned = c.stay_credits_earned,
            cd.stay_credits_used = c.stay_credits_used;

-- merges customer acquisition table data
merge into customer_dw cd
    using customer_acquisition_view  c
    on (c.customer_id = cd.customer_id and c.data_source = cd.data_source)
    when matched then
        update set 
            cd.first_name = c.first_name,
            cd.last_name = c.last_name,
            cd.email = c.email,
            cd.phone = c.phone,
            cd.zip = c.zip,
            cd.stay_credits_earned = c.stay_credits_earned,
            cd.stay_credits_used = c.stay_credits_used;

            
-- creates procedure that runs insert and merge statements
create or replace procedure customer_etl_proc
as
begin

insert into customer_dw 
select c.data_source, c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.zip, c.stay_credits_earned, c.stay_credits_used
from customer_view c left join customer_dw cd
    on c.customer_id = cd.customer_id
    and c.data_source = cd.data_source
where cd.customer_id is null;

-- insert customer acquisition records
insert into customer_dw 
select c.data_source, c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.zip, c.stay_credits_earned / 2, c.stay_credits_used
from customer_acquisition_view  c left join customer_dw cd
    on c.customer_id = cd.customer_id
    and c.data_source = cd.data_source
where cd.customer_id is null;

-- merges customer table data
merge into customer_dw cd
    using customer_view c
    on (c.customer_id = cd.customer_id and c.data_source = cd.data_source)
    when matched then
        update set 
            cd.first_name = c.first_name,
            cd.last_name = c.last_name,
            cd.email = c.email,
            cd.phone = c.phone,
            cd.zip = c.zip,
            cd.stay_credits_earned = c.stay_credits_earned,
            cd.stay_credits_used = c.stay_credits_used;

-- merges customer acquisition table data
merge into customer_dw cd
    using customer_acquisition_view c
    on (c.customer_id = cd.customer_id and c.data_source = cd.data_source)
    when matched then
        update set 
            cd.first_name = c.first_name,
            cd.last_name = c.last_name,
            cd.email = c.email,
            cd.phone = c.phone,
            cd.zip = c.zip,
            cd.stay_credits_earned = c.stay_credits_earned,
            cd.stay_credits_used = c.stay_credits_used;
 
end;
/


/*

INSERT INTO customer_acquisition (CA_First_Name, CA_Last_Name, CA_Email, CA_Phone, CA_zip_code,CA_credits_remaining) VALUES ('Bob','Chu', 'bobchug@pmail.com',  '(603)668-7268','73941', 100);

Insert into CUSTOMER (CUSTOMER_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE,ADDRESS_LINE_1,ADDRESS_LINE_2,CITY,STATE,ZIP,BIRTHDATE,STAY_CREDITS_EARNED,STAY_CREDITS_USED) values (192,'Bob','ChuChu','selou@gmail.com','783-625-7173','6 Cody Terrace','Unit A','Lake Charles','LA','79030',to_date('16-JUL-85','DD-MON-RR'),3,0);


update customer
set first_name = 'Lmao'
where customer_id = 1;

update customer_acquisition
set ca_first_name = 'Ayyy'
where acquired_customer_id = 1;
  
call customer_etl_proc();
select * from customer_dw;
rollback;
select * from customer_view;
select * from customer_acquisition_view;
select * from customer;
select * from customer_acquisition;


drop table customer_dw;
drop view customer_view;
drop view customer_acquisition_view;
drop procedure customer_etl_proc;
*/
