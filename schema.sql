CREATE TABLE users(id serial primary key, name varchar(50), email varchar(100));

CREATE TABLE microposts(id serial primary key, title varchar(50), post text, user_id integer, image_url text, tag text, comment_id integer, time_stamp date );

CREATE TABLE comments(id serial primary key, post_id integer, user_id integer, content text, time date);

CREATE TABLE tags(id serial primary key, tag_name varchar(100), post_id integer);

