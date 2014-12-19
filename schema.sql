CREATE TABLE micropost(id serial primary key, author_id integer, content text, snippet varchar(255), time_date date, img_url text);

CREATE TABLE comment(id serial primary key, post_id integer, content text, name varchar(50), time_date date);

CREATE TABLE author(id serial primary key, name varchar(50));

CREATE TABLE tag(id serial primary key, tag_name varchar(25));

CREATE TABLE tag_ref(tag_id integer, post_id integer);