set search_path = gallery;

revoke gallery_readonly from db_reader_user;
revoke gallery_admin    from db_admin_user;

drop user if exists db_reader_user;
drop user if exists db_admin_user;
drop role if exists gallery_readonly;
drop role if exists gallery_admin;


create role gallery_admin;
create role gallery_readonly;

grant usage on schema gallery to gallery_admin;
grant usage on schema gallery to gallery_readonly;

grant select, insert, update, delete
    on gallery.artists,
       gallery.artworks,
       gallery.artist_artworks,
       gallery.restorations,
       gallery.exhibitions,
       gallery.exhibition_artworks,
       gallery.employees,
       gallery.exhibition_employees,
       gallery.visitors,
       gallery.ticket_types,
       gallery.tickets
    to gallery_admin;

grant select
    on gallery.artists,
       gallery.artworks,
       gallery.artist_artworks,
       gallery.restorations,
       gallery.exhibitions,
       gallery.exhibition_artworks,
       gallery.employees,
       gallery.exhibition_employees,
       gallery.visitors,
       gallery.ticket_types,
       gallery.tickets
    to gallery_readonly;


create user db_admin_user  with password 'AdminPass!2026';
create user db_reader_user with password 'ReaderPass!2026';

grant gallery_admin    to db_admin_user;
grant gallery_readonly to db_reader_user;


revoke update, delete
    on gallery.artists,
       gallery.artworks,
       gallery.artist_artworks,
       gallery.restorations,
       gallery.exhibitions,
       gallery.exhibition_artworks,
       gallery.employees,
       gallery.exhibition_employees,
       gallery.visitors,
       gallery.ticket_types,
       gallery.tickets
    from gallery_readonly;


/*
                                     Access privileges
 Schema  |    Name    | Type  |        Access privileges
---------+------------+-------+-----------------------------
 gallery | artists    | table | postgres=arwdDxt/postgres  +
         |            |       | gallery_admin=arwd/postgres +
         |            |       | gallery_readonly=r/postgres
*/


set role db_admin_user;
select current_user;      
select count(*) from gallery.artists;  

insert into gallery.artists (first_name, last_name, nationality)
values ('Test', 'Admin', 'Kazakh')
returning *;   
update gallery.artists
    set nationality = 'Kazakh'
    where nationality = 'Kazakh';   
delete from gallery.artists
    where artist_id = (select max(artist_id) from gallery.artists); 

reset role;


set role db_reader_user;
select current_user;        
select count(*) from gallery.artists;  

begin;
insert into gallery.artists (first_name, last_name, nationality)
values ('Test', 'Reader', 'Kazakh');
rollback;

begin;
update gallery.artists set nationality = 'Test' where artist_id = 1;
rollback;

begin;
delete from gallery.artists where artist_id = 1;
rollback;

reset role;


truncate table gallery.tickets            restart identity cascade;
truncate table gallery.ticket_types       restart identity cascade;
truncate table gallery.visitors           restart identity cascade;
truncate table gallery.exhibition_employees restart identity cascade;
truncate table gallery.exhibition_artworks  restart identity cascade;
truncate table gallery.employees          restart identity cascade;
truncate table gallery.exhibitions        restart identity cascade;
truncate table gallery.restorations       restart identity cascade;
truncate table gallery.artist_artworks    restart identity cascade;
truncate table gallery.artworks           restart identity cascade;
truncate table gallery.artists            restart identity cascade;


insert into gallery.artists (first_name, last_name, birth_date, death_date, nationality, biography)
values
    ('Vasily',    'Kandinsky',  '1866-12-04', '1944-12-13', 'Russian',
     'Pioneer of abstract art; developed theories on color and form.'),
    ('Frida',     'Kahlo',      '1907-07-06', '1954-07-13', 'Mexican',
     'Known for surrealist self-portraits exploring identity and pain.'),
    ('Pablo',     'Picasso',    '1881-10-25', '1973-04-08', 'Spanish',
     'Co-founder of Cubism; prolific across painting, sculpture, printmaking.'),
    ('Georgia',   'O''Keeffe',  '1887-11-15', '1986-03-06', 'American',
     'Celebrated for large-scale flower paintings and New Mexico landscapes.'),
    ('Salvador',  'Dali',       '1904-05-11', '1989-01-23', 'Spanish',
     'Surrealist master; known for dreamlike imagery and precise technique.'),
    ('Aisha',     'Bekova',     '1990-03-22', null,          'Kazakhstani',
     'Contemporary artist working with textile and mixed media.');

insert into gallery.artworks (title, year_created, medium, dimensions)
values
    ('Composition VIII',          1923, 'Oil on canvas',     '140 x 201 cm'),
    ('The Two Fridas',            1939, 'Oil on canvas',     '173 x 173 cm'),
    ('Guernica',                  1937, 'Oil on canvas',     '349 x 776 cm'),
    ('Black Iris III',            1926, 'Oil on canvas',     '91 x 76 cm'),
    ('The Persistence of Memory', 1931, 'Oil on canvas',     '24 x 33 cm'),
    ('Steppe Dreams',             2024, 'Mixed media',       '120 x 80 cm');

insert into gallery.artist_artworks (artist_id, artwork_id)
values
    ((select artist_id from gallery.artists where first_name = 'Vasily'   and last_name = 'Kandinsky'),
     (select artwork_id from gallery.artworks where title = 'Composition VIII')),
    ((select artist_id from gallery.artists where first_name = 'Frida'    and last_name = 'Kahlo'),
     (select artwork_id from gallery.artworks where title = 'The Two Fridas')),
    ((select artist_id from gallery.artists where first_name = 'Pablo'    and last_name = 'Picasso'),
     (select artwork_id from gallery.artworks where title = 'Guernica')),
    ((select artist_id from gallery.artists where first_name = 'Georgia'  and last_name = 'O''Keeffe'),
     (select artwork_id from gallery.artworks where title = 'Black Iris III')),
    ((select artist_id from gallery.artists where first_name = 'Salvador' and last_name = 'Dali'),
     (select artwork_id from gallery.artworks where title = 'The Persistence of Memory')),
    ((select artist_id from gallery.artists where first_name = 'Aisha'    and last_name = 'Bekova'),
     (select artwork_id from gallery.artworks where title = 'Steppe Dreams'));

insert into gallery.restorations (artwork_id, restoration_date, description, cost)
values
    ((select artwork_id from gallery.artworks where title = 'Guernica'),
     '2026-03-15', 'Surface cleaning and varnish removal', 12500.00),
    ((select artwork_id from gallery.artworks where title = 'The Two Fridas'),
     '2026-04-20', 'Canvas re-lining and crack consolidation', 8750.50),
    ((select artwork_id from gallery.artworks where title = 'Composition VIII'),
     '2026-05-10', 'Pigment stabilisation on blue areas', 5300.00),
    ((select artwork_id from gallery.artworks where title = 'Black Iris III'),
     '2026-06-01', 'Frame restoration and edge in-painting', 3200.75),
    ((select artwork_id from gallery.artworks where title = 'The Persistence of Memory'),
     '2026-07-18', 'UV protective varnish application', 2100.00);

insert into gallery.exhibitions (title, start_date, end_date, description)
values
    ('Abstractions of the 20th Century', '2026-03-01', '2026-06-30',
     'Tracing the evolution of abstract art from Kandinsky to abstract expressionism.'),
    ('Surreal Worlds',                  '2026-04-15', '2026-08-31',
     'A journey through surrealism featuring Dali, Magritte, and contemporaries.'),
    ('Women in Art',                    '2026-05-01', '2026-09-30',
     'Celebrating female artists from the 20th century to today.'),
    ('Central Asian Perspectives',      '2026-06-01', '2026-10-15',
     'Contemporary works from Kazakhstan, Kyrgyzstan, and Uzbekistan.'),
    ('Masters of Form and Color',       '2026-07-01', '2026-12-31',
     'Exploring how masters used composition to guide the eye.');

insert into gallery.exhibition_artworks (exhibition_id, artwork_id, display_order)
values
    ((select exhibition_id from gallery.exhibitions where title = 'Abstractions of the 20th Century'),
     (select artwork_id    from gallery.artworks    where title = 'Composition VIII'), 1),
    ((select exhibition_id from gallery.exhibitions where title = 'Surreal Worlds'),
     (select artwork_id    from gallery.artworks    where title = 'The Persistence of Memory'), 1),
    ((select exhibition_id from gallery.exhibitions where title = 'Women in Art'),
     (select artwork_id    from gallery.artworks    where title = 'The Two Fridas'), 1),
    ((select exhibition_id from gallery.exhibitions where title = 'Women in Art'),
     (select artwork_id    from gallery.artworks    where title = 'Black Iris III'), 2),
    ((select exhibition_id from gallery.exhibitions where title = 'Central Asian Perspectives'),
     (select artwork_id    from gallery.artworks    where title = 'Steppe Dreams'), 1),
    ((select exhibition_id from gallery.exhibitions where title = 'Masters of Form and Color'),
     (select artwork_id    from gallery.artworks    where title = 'Guernica'), 1);

insert into gallery.employees (first_name, last_name, email, phone, position, hire_date)
values
    ('Aigerim', 'Nurlanovna', 'a.nurlanovna@gallery.kz',  '+7 701 111 2233', 'curator',        '2021-08-01'),
    ('Dmitri',  'Petrov',     'd.petrov@gallery.kz',      '+7 702 333 4455', 'manager',        '2019-03-15'),
    ('Sara',    'Omarova',    's.omarova@gallery.kz',     '+7 705 555 6677', 'guide',          '2023-01-10'),
    ('Bekzat',  'Akhmetov',   'b.akhmetov@gallery.kz',   '+7 707 777 8899', 'guide',          '2022-06-20'),
    ('Lena',    'Ivanova',    'l.ivanova@gallery.kz',     '+7 708 999 0011', 'curator',        '2020-11-05'),
    ('Timur',   'Seilov',     't.seilov@gallery.kz',      '+7 771 222 3344', 'manager',        '2018-07-22');

insert into gallery.exhibition_employees (exhibition_id, employee_id, role)
values
    ((select exhibition_id from gallery.exhibitions where title = 'Abstractions of the 20th Century'),
     (select employee_id   from gallery.employees   where email = 'a.nurlanovna@gallery.kz'), 'curator'),
    ((select exhibition_id from gallery.exhibitions where title = 'Abstractions of the 20th Century'),
     (select employee_id   from gallery.employees   where email = 'd.petrov@gallery.kz'),     'manager'),
    ((select exhibition_id from gallery.exhibitions where title = 'Surreal Worlds'),
     (select employee_id   from gallery.employees   where email = 'l.ivanova@gallery.kz'),    'curator'),
    ((select exhibition_id from gallery.exhibitions where title = 'Women in Art'),
     (select employee_id   from gallery.employees   where email = 's.omarova@gallery.kz'),    'guide'),
    ((select exhibition_id from gallery.exhibitions where title = 'Central Asian Perspectives'),
     (select employee_id   from gallery.employees   where email = 'b.akhmetov@gallery.kz'),   'guide'),
    ((select exhibition_id from gallery.exhibitions where title = 'Masters of Form and Color'),
     (select employee_id   from gallery.employees   where email = 't.seilov@gallery.kz'),     'manager');

insert into gallery.visitors (first_name, last_name, email, phone)
values
    ('Aibek',   'Seitkali',   'aibek.seitkali@mail.kz',    '+7 701 123 4567'),
    ('Madina',  'Zhaksybekova','madina.j@gmail.com',        '+7 702 234 5678'),
    ('Artur',   'Loginov',    'a.loginov@outlook.com',      '+7 705 345 6789'),
    ('Zarina',  'Bekova',     'zarina.bekova@mail.kz',      '+7 707 456 7890'),
    ('Nicolas', 'Fontaine',   'n.fontaine@example.fr',      '+33 612 345 678'),
    ('Yuki',    'Tanaka',     'y.tanaka@example.jp',        '+81 90 1234 5678');

insert into gallery.ticket_types (type_name, price)
values
    ('Standard',   1500.00),
    ('Student',     750.00),
    ('Senior',      900.00),
    ('Child',       500.00),
    ('VIP',        3500.00);

insert into gallery.tickets (visitor_id, ticket_type_id, exhibition_id, visit_date)
values
    ((select visitor_id      from gallery.visitors      where email = 'aibek.seitkali@mail.kz'),
     (select ticket_type_id  from gallery.ticket_types  where type_name = 'Standard'),
     (select exhibition_id   from gallery.exhibitions   where title = 'Abstractions of the 20th Century'),
     '2026-03-10'),
    ((select visitor_id      from gallery.visitors      where email = 'madina.j@gmail.com'),
     (select ticket_type_id  from gallery.ticket_types  where type_name = 'Student'),
     (select exhibition_id   from gallery.exhibitions   where title = 'Women in Art'),
     '2026-05-20'),
    ((select visitor_id      from gallery.visitors      where email = 'a.loginov@outlook.com'),
     (select ticket_type_id  from gallery.ticket_types  where type_name = 'VIP'),
     (select exhibition_id   from gallery.exhibitions   where title = 'Surreal Worlds'),
     '2026-04-25'),
    ((select visitor_id      from gallery.visitors      where email = 'zarina.bekova@mail.kz'),
     (select ticket_type_id  from gallery.ticket_types  where type_name = 'Senior'),
     (select exhibition_id   from gallery.exhibitions   where title = 'Masters of Form and Color'),
     '2026-07-15'),
    ((select visitor_id      from gallery.visitors      where email = 'n.fontaine@example.fr'),
     (select ticket_type_id  from gallery.ticket_types  where type_name = 'Standard'),
     (select exhibition_id   from gallery.exhibitions   where title = 'Central Asian Perspectives'),
     '2026-06-10'),
    ((select visitor_id      from gallery.visitors      where email = 'y.tanaka@example.jp'),
     (select ticket_type_id  from gallery.ticket_types  where type_name = 'Child'),
     (select exhibition_id   from gallery.exhibitions   where title = 'Abstractions of the 20th Century'),
     '2026-03-22');

select visitor_id, first_name, last_name, email
from gallery.visitors
where email = 'aibek.seitkali@mail.kz';

update gallery.visitors
    set email = 'aibek.seitkali@gmail.com',
        phone = '+7 701 999 8877'
where email = 'aibek.seitkali@mail.kz';


select ticket_type_id, type_name, price
from gallery.ticket_types
where type_name = 'Senior';

update gallery.ticket_types
    set price = 700.00
where type_name = 'Senior';


select r.restoration_id, aw.title, aw.medium, r.cost
from gallery.restorations r
join gallery.artworks aw on r.artwork_id = aw.artwork_id
where aw.medium ilike '%oil on canvas%';

update gallery.restorations r
    set cost = round(r.cost * 1.10, 2) 
from gallery.artworks aw
where r.artwork_id = aw.artwork_id
  and aw.medium ilike '%oil on canvas%';


begin;

delete from gallery.tickets
where ticket_type_id = (
        select ticket_type_id
        from   gallery.ticket_types
        where  type_name = 'Child'
    )
  and visit_date < current_date;  

select count(*) from gallery.tickets;

rollback; 