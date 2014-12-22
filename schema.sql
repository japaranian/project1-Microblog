CREATE TABLE users(id serial primary key, name varchar(50), email varchar(100));

CREATE TABLE microposts(id serial primary key, title varchar(50), post text, user_id integer, image_url text, tag text, comments text, time_stamp date );
