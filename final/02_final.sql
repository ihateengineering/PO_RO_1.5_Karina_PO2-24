-- database_name: concert_hall_db
-- schema_name: concert_hall

-- part 2: db & schema
create schema if not exists concert_hall;
set search_path to concert_hall, public;

create table if not exists genre (
    genre_id serial primary key,
    name varchar(60) unique not null,
    description text
);

create table if not exists artist (
    artist_id serial primary key,
    genre_id int references genre(genre_id) on delete restrict,
    artist_name varchar(120) unique not null,
    country varchar(80),
    formed_date date
);

create table if not exists venue (
    venue_id serial primary key,
    venue_name varchar(100) unique not null,
    city varchar(50) not null,
    address varchar(255),
    capacity int not null check (capacity > 0) 
);

create table if not exists concert (
    concert_id serial primary key,
    venue_id int references venue(venue_id) on delete restrict,
    title varchar(200) not null,
    concert_date date not null check (concert_date > date '2026-01-02') 
);

create table if not exists seat (
    seat_id serial primary key,
    venue_id int references venue(venue_id) on delete cascade,
    row_number varchar(5) not null,
    seat_number int not null
);

create table if not exists employee (
    employee_id serial primary key,
    full_name varchar(150) not null,
    email varchar(120) unique not null,
    role varchar(20) not null check (role in ('Manager', 'Security', 'Technician', 'Cashier')), 
    hire_date date default current_date not null 
);

create table if not exists customer (
    customer_id serial primary key,
    email varchar(120) unique not null,
    full_name varchar(150) not null,
    phone varchar(15) check (phone is not null), 
    registered_at timestamp default current_timestamp
);

create table if not exists ticket (
    ticket_id serial primary key,
    concert_id int references concert(concert_id) on delete cascade,
    customer_id int references customer(customer_id) on delete restrict,
    seat_id int references seat(seat_id) on delete restrict,
    price numeric(10,2) not null,
    fee numeric(10,2) not null,
    total_price numeric(10,2) generated always as (price + fee) stored,
    purchase_date date not null
);

create table if not exists payment (
    payment_id serial primary key,
    ticket_id int references ticket(ticket_id) on delete cascade,
    amount numeric(10,2) not null,
    payment_date timestamp not null,
    payment_method varchar(20) default 'Credit Card' not null
);

create table if not exists concert_artist (
    concert_id int references concert(concert_id) on delete cascade,
    artist_id int references artist(artist_id) on delete cascade,
    primary key (concert_id, artist_id)
);

create table if not exists employee_concert (
    employee_id int references employee(employee_id) on delete cascade,
    concert_id int references concert(concert_id) on delete cascade,
    primary key (employee_id, concert_id)
);


-- part 3: alter tables

-- add payment status
alter table payment add column if not exists payment_status varchar(20) default 'Completed';

-- add unique constraint
alter table seat drop constraint if exists uq_venue_seat;
alter table seat add constraint uq_venue_seat unique (venue_id, row_number, seat_number);

-- expanding phone limit
alter table customer alter column phone type varchar(25);

-- default employee role is security
alter table employee alter column role set default 'Security';

-- rename fee into service_fee
do $$
begin
	if exists ( select 1 from information_schema.columns where table_schema = 'concert_hall' and table_name = 'ticket' and column_name = 'fee' ) then
		alter table ticket rename column fee to service_fee;
	end if;
end;
$$;


-- part 4: inserts

truncate table customer, genre, artist, venue, concert, seat, employee, ticket, payment, concert_artist, employee_concert restart identity cascade;

insert into genre (name, description) values
('Rock', 'Classic and modern rock music'),
('Pop', 'Popular mainstream music'),
('Jazz', 'Improvisational musical style'),
('Hip-Hop', 'Urban culture and rap music'),
('Electronic', 'Synthesizers and electronic beats');

insert into artist (genre_id, artist_name, country, formed_date) values
((select genre_id from genre where name = 'Rock'), 'The Loud Echoes', 'Kazakhstan', '2015-05-20'),
((select genre_id from genre where name = 'Pop'), 'Aruzhan', 'Kazakhstan', '2020-11-01'),
((select genre_id from genre where name = 'Jazz'), 'Midnight Trio', 'USA', '2010-03-15'),
((select genre_id from genre where name = 'Hip-Hop'), 'MC Shiza', 'Kazakhstan', '2018-08-12'),
((select genre_id from genre where name = 'Electronic'), 'Cyber Pulse', 'Germany', '2022-01-10');

insert into venue (venue_name, city, address, capacity) values
('Almaty Arena', 'Almaty', 'Momyshuly Ave 1', 12000),
('Astana Arena', 'Astana', 'Turan Ave 48', 30000),
('Palace of Republic', 'Almaty', 'Dostyk Ave 56', 3000),
('Central Stadium', 'Shymkent', 'Madeli Kozha St 1', 20000),
('Music Hall', 'Karaganda', 'Bukhar-Zhyrau Ave 32', 800);

insert into concert (venue_id, title, concert_date) values
((select venue_id from venue where venue_name = 'Almaty Arena'), 'Rock Fest 2026', '2026-07-15'),
((select venue_id from venue where venue_name = 'Palace of Republic'), 'Aruzhan Live Acoustic', '2026-08-20'),
((select venue_id from venue where venue_name = 'Music Hall'), 'Jazz Cozy Evening', '2026-09-05'),
((select venue_id from venue where venue_name = 'Astana Arena'), 'Grand Hip-Hop Night', '2026-10-12'),
((select venue_id from venue where venue_name = 'Central Stadium'), 'Electronic Open Air', '2026-06-25');

insert into seat (venue_id, row_number, seat_number) values
((select venue_id from venue where venue_name = 'Music Hall'), 'A', 1),
((select venue_id from venue where venue_name = 'Music Hall'), 'A', 2),
((select venue_id from venue where venue_name = 'Music Hall'), 'B', 1),
((select venue_id from venue where venue_name = 'Music Hall'), 'B', 2),
((select venue_id from venue where venue_name = 'Music Hall'), 'C', 1);

insert into employee (full_name, email, role, hire_date) values
('Mishelov Baitemir', 'dreamypatch@tutamail.com', 'Manager', '2024-01-10'),
('Sharonova Milana', 's.milana@gmail.com', 'Technician', '2025-03-15'),
('Ilya Kopytov', 'i.kopytov24@apec.edu.kz', 'Security', '2026-02-01'),
('Chapurina Milana', 'cutypie123@gmail.com', 'Cashier', '2025-09-20'),
('Umbetalieva Adelia', 'u.adelia24@apec.edu.kz', 'Manager', '2026-04-11');

insert into customer (email, full_name, phone) values
('d.zholgali24@apec.edu.kz', 'Zholgali Dias', '+77011112233'),
('g.marat24@apec.edu.kz', 'Marat Gaukhar', '+77023334455'),
('d.basiev24@apec.edu.kz', 'David Basiev', '+77057778899'),
('a.salimov24@apec.edu.kz', 'Alikhan Salimov', '+77471234567'),
('a.sagyndyk24@apec.edu.kz', 'Sagyndykovna Aidana', '+77079876543'),
('z.atlas24@apec.edu.kz', 'Zhansaya Atlas', '+77015554433'),
('a.yerbolatovna24@apec.edu.kz', 'Yerbolatovna Aziza', '+77028881122'),
('n.kuanishkali24@apec.edu.kz', 'Nurik Kuanishkali', '+77773332211'),
('a.kurmangazy24@apec.edu.kz', 'Amina Kurmangazy', '+77084445566'),
('m.albina24@apec.edu.kz', 'Albina Marat', '+77475556677');

insert into ticket (concert_id, customer_id, seat_id, price, service_fee, purchase_date) values
((select concert_id from concert where title = 'Jazz Cozy Evening'), (select customer_id from customer where email = 'd.zholgali24@apec.edu.kz'), (select seat_id from seat where row_number = 'A' and seat_number = 1), 15000.00, 1500.00, '2026-05-10'),
((select concert_id from concert where title = 'Jazz Cozy Evening'), (select customer_id from customer where email = 'g.marat24@apec.edu.kz'), (select seat_id from seat where row_number = 'A' and seat_number = 2), 15000.00, 1500.00, '2026-05-11'),
((select concert_id from concert where title = 'Jazz Cozy Evening'), (select customer_id from customer where email = 'd.basiev24@apec.edu.kz'), (select seat_id from seat where row_number = 'B' and seat_number = 1), 12000.00, 1200.00, '2026-05-12'),
((select concert_id from concert where title = 'Jazz Cozy Evening'), (select customer_id from customer where email = 'a.salimov24@apec.edu.kz'), (select seat_id from seat where row_number = 'B' and seat_number = 2), 12000.00, 1200.00, '2026-05-12'),
((select concert_id from concert where title = 'Jazz Cozy Evening'), (select customer_id from customer where email = 'a.sagyndyk24@apec.edu.kz'), (select seat_id from seat where row_number = 'C' and seat_number = 1), 10000.00, 1000.00, '2026-05-13'),
((select concert_id from concert where title = 'Rock Fest 2026'), (select customer_id from customer where email = 'z.atlas24@apec.edu.kz'), null, 25000.00, 2000.00, '2026-05-14'),
((select concert_id from concert where title = 'Rock Fest 2026'), (select customer_id from customer where email = 'a.yerbolatovna24@apec.edu.kz'), null, 25000.00, 2000.00, '2026-05-14'),
((select concert_id from concert where title = 'Aruzhan Live Acoustic'), (select customer_id from customer where email = 'a.kurmangazy24@apec.edu.kz'), null, 8000.00, 500.00, '2026-05-15'),
((select concert_id from concert where title = 'Aruzhan Live Acoustic'), (select customer_id from customer where email = 'm.albina24@apec.edu.kz'), null, 8000.00, 500.00, '2026-05-16'),
((select concert_id from concert where title = 'Electronic Open Air'), (select customer_id from customer where email = 'n.kuanishkali24@apec.edu.kz'), null, 18000.00, 1500.00, '2026-05-16');

insert into payment (ticket_id, amount, payment_date, payment_method) values
(1, 16500.00, '2026-05-10 14:32:00', 'Credit Card'),
(2, 16500.00, '2026-05-11 09:15:00', 'Mobile Payment'),
(3, 13200.00, '2026-05-12 18:22:00', 'Credit Card'),
(4, 13200.00, '2026-05-12 21:05:00', 'Credit Card'),
(5, 11000.00, '2026-05-13 11:40:00', 'Mobile Payment');

insert into concert_artist (concert_id, artist_id)
select c.concert_id, a.artist_id 
from concert c, artist a 
where c.title = 'Rock Fest 2026' and a.artist_name = 'The Loud Echoes';

-- part 5: update & delete

-- increasing ticket cost
update ticket 
set price = price + 2000.00 
where concert_id = (select concert_id from concert where title = 'Jazz Cozy Evening');

-- change the address
update venue
set address = concat('New Main Square, ', city)
where venue_name = 'Music Hall';

-- removal by ticket
begin;
delete from payment 
where ticket_id = (
    select ticket_id 
    from ticket 
    where customer_id = (select customer_id from customer where email = 'd.zholgali24@apec.edu.kz') 
    limit 1
)
returning payment_id;
rollback;

-- part 6: roles & rights

-- manage minimum required privileges (readonly: select all, writer: insert & update)
do $$
begin
	revoke all privileges on all tables in schema concert_hall from concert_readonly, concert_writer;
	revoke all privileges on schema concert_hall from concert_readonly, concert_writer;
exception when undefined_object then
    null;
end;
$$;

drop role if exists concert_readonly;
drop role if exists concert_writer;

create role concert_readonly;
create role concert_writer;

grant select on all tables in schema concert_hall to concert_readonly;
grant insert, update on ticket to concert_writer;

revoke update on ticket from concert_writer;