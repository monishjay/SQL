

-- monish jayakumar mj27639
-- drops table and sequences
-- drop table section, drops every table

drop table reservation_details;
drop table location_features_linking;
drop table features;
drop table reservation;
drop table room;
drop table customer_payment;
drop table customer;
drop table location;

-- monish jayakumar mj27639
-- drop sequence section, drops every sequence

drop sequence customer_id_seq;
drop sequence payment_id_seq;
drop sequence reservation_id_seq;
drop sequence room_id_seq;
drop sequence location_id_seq;
drop sequence feature_id_seq;

-- monish jayakumar mj27639
-- creates table section
-- creates customer table
create table customer (

    customer_id number(8) primary key,
    first_name varchar(30),
    last_name varchar(30),
    email varchar(30) unique,
    phone char(12),
    address_line_1 varchar(50),
    address_line_2 varchar(50) null,
    city varchar(20),
    state char(2),
    zip char(5),
    birthdate date,
    stay_credits_earned number(3) default 0,
    stay_credits_used number(3) default 0,
    
    constraint credit_check check (stay_credits_used <= stay_credits_earned),
    constraint email_length_check check (length(email) >= 7) 
    
    );

-- monish jayakumar mj27639 
-- creates customer payment table referencing customer table  
create table customer_payment (

    payment_id number(8) primary key,
    customer_id number(8) references customer(customer_id) unique,
    cardholder_first_name varchar(30),
    cardholder_mid_name varchar(30) null,
    cardholder_last_name varchar(30),
    cardtype char(4),
    cardnumber number(16),
    expiration_date date,
    cc_id number(4),
    billing_address varchar(50),
    billing_city varchar(20),
    billing_state char(2),
    billing_zip char(5)
    
    );

-- monish jayakumar mj27639    
-- creates location table
create table location (

    location_id number(3) primary key,
    location_name varchar(20) unique,
    address varchar(30),
    city varchar(20),
    state char(2),
    zip char(5),
    phone char(12),
    url varchar(30)
    
    );

-- monish jayakumar mj27639
-- creates reservation table referencing customer and location tables
create table reservation (

    reservation_id number(8) primary key,
    customer_id number(8) references customer(customer_id),
    location_id number(5) references location(location_id),
    confirmation_nbr char(8) unique,
    date_created date default sysdate,
    check_in_date date,
    check_out_date date null,
    status char(1),
    number_of_guests number(2),
    reservation_total number(5),
    discount_code varchar(20) null,
    customer_rating varchar(100) null,
    notes varchar(100) null,
    
    constraint status_check check (status in ('U','I','C','N','R'))

    );

    
-- monish jayakumar mj27639
-- creates room table referencing location table
create table room (

    room_id number(5) primary key,
    location_id number(5) references location(location_id),
    room_number varchar(3),
    floor varchar(2),
    room_type char(1),
    square_footage varchar(5),
    max_people number(2),
    weekday_rate number(4),
    weekend_rate number(4),
    
   -- constraint room_check check 
    constraint location_room_number unique (location_id, room_number),
    constraint room_check check (room_type in ('D','Q','K','S','C'))

    );
 
-- monish jayakumar mj27639
-- creates reservation_details table referencing room
create table reservation_details (

    reservation_id number(8), 
    room_id number(5),  
    constraint reservation_room_pk primary key (reservation_id, room_id),
    constraint reservation_id_fk foreign key (reservation_id) references reservation(reservation_id),
    constraint room_id_fk foreign key (room_id) references room(room_id) 
    
    );

-- monish jayakumar mj27639
-- creates features table 
create table features (

    feature_id number(5) primary key,
    feature_name varchar(30) unique
    
    );

-- monish jayakumar mj27639
-- creates location features linking table referencing location and features table
create table location_features_linking (

    location_id number(5), 
    feature_id number(5),
    constraint location_feature_pk primary key (location_id, feature_id),
    constraint fk_location_id foreign key (location_id) references location(location_id),
    constraint fk_location_features_id foreign key (feature_id) references features(feature_id)
    
    );


-- monish jayakumar mj27639
-- creates sequences section
create sequence payment_id_seq
    start with 1
    increment by 1;
create sequence reservation_id_seq
    start with 1
    increment by 1;
create sequence room_id_seq
    start with 1
    increment by 1;
create sequence location_id_seq
    start with 1
    increment by 1;
create sequence feature_id_seq
    start with 1
    increment by 1;
create sequence customer_id_seq
    start with 100001
    increment by 1;

---- monish jayakumar mj27639
-- inserts data section

-- inserts feature, room, and location data for location #1
insert into features 
    values (feature_id_seq.nextval, 'Free Wi-Fi');
insert into location 
    values (location_id_seq.nextval, 'South Congress','2000 Bill St','Austin', 'TX', 78704, '512-182-1920', 'sourapple-sc.com');
insert into room
    values (room_id_seq.nextval, location_id_seq.currval, '100', '1','D','950', 9,100,150);
insert into room
    values (room_id_seq.nextval, location_id_seq.currval, '101', '1','Q','950', 7,100,150);
insert into location_features_linking 
    values (location_id_seq.currval, feature_id_seq.currval);


commit;

-- inserts feature, room, and location data for location #2
insert into features
    values (feature_id_seq.nextval, 'Complimentary Breakfast');
insert into location_features_linking
    values (location_id_seq.currval, feature_id_seq.currval);
insert into location 
    values (location_id_seq.nextval, 'East 7th Lofts','2000 Loft St','Austin', 'TX', 78702, '512-324-2393', 'sourapple-e7.com');
insert into room
    values (room_id_seq.nextval, location_id_seq.currval, '102', '1','D','1000', 10,120,170);
insert into room
    values (room_id_seq.nextval, location_id_seq.currval, '103', '1','Q','1000', 8,120,170);
insert into location_features_linking
    values( location_id_seq.currval, feature_id_seq.currval);

commit;

-- inserts feature, room, and location data for location #3
insert into features
    values (feature_id_seq.nextval, 'Free Parking');
insert into location 
    values (location_id_seq.nextval, 'Marble Falls','2000 Falls St','Austin', 'TX', 78654, '512-230-3482', 'sourapple-mbf.com');
insert into room
    values (room_id_seq.nextval, location_id_seq.currval, '104', '1','D','975', 10,110,160);
insert into room
    values (room_id_seq.nextval, location_id_seq.currval, '105', '1','Q','975', 8,110,160);
insert into location_features_linking 
    values (location_id_seq.currval, feature_id_seq.currval);
insert into location_features_linking 
    values (1, feature_id_seq.currval);
  
commit;

-- inserts customer #1, payment, and reservation data
insert into customer 
    values (customer_id_seq.nextval, 'Monish', 'Jayakumar', 'mj27639@utexas.edu', '512-129-1290','9030 Guad St', null, 'Austin', 'TX', '78302','20-April-2002', default, default);
insert into customer_payment 
    values (payment_id_seq.nextval, customer_id_seq.currval, 'Monish', null, 'Jayakumar', 'visa', 2023929302939029, '30-April-2025',201,'9030 Guad St','Austin','TX','78302');
insert into reservation
    values (reservation_id_seq.nextval, customer_id_seq.currval, location_id_seq.currval, 'ha329nap','1-April-2020','15-April-2020','20-April-2020','U',4,450,null, null, null);
insert into reservation_details
    values (reservation_id_seq.currval, 5);
    
commit;

-- inserts customer #2 , payment and reservation
insert into customer
    values (customer_id_seq.nextval, 'Bob', 'Chu', 'bobchu@gmail.com', '512-149-1091','9039 Bob St', null, 'Austin', 'TX', '78301','29-April-2000', default, default);
insert into customer_payment 
    values (payment_id_seq.nextval, customer_id_seq.currval, 'Bob', null, 'Chu', 'visa', 2023029302932029, '30-October-2025',291,'9039 Bob St','Austin','TX','78301');
insert into reservation
    values (reservation_id_seq.nextval, customer_id_seq.currval, location_id_seq.currval, 'ja319nmp','16-April-2020','17-April-2020','29-April-2020','U',2,350,null, null, null);
insert into reservation_details
    values (reservation_id_seq.currval, 5);
insert into reservation
    values (reservation_id_seq.nextval, customer_id_seq.currval, location_id_seq.currval, 'la399nrp','1-April-2020','13-April-2020','26-April-2020','U',3,400,null, null, null);
insert into reservation_details
    values (reservation_id_seq.currval, 6);
 
commit;


-- rollback;
 
-- monish jayakumar mj27639
-- creates indexes section
create index customer_reservation_idx
    on reservation (customer_id);
create index location_reservation_idx
    on reservation (location_id);
create index state_idx
    on customer (state);
create index zip_idx
    on customer (zip);


