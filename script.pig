-- Add data from CSV files.

  ACTOR = LOAD '/usr/local/actor.csv' USING PigStorage(',') AS (actorid:int, name:chararray);
  MOVIE = LOAD '/usr/local/movie.csv' USING PigStorage(',') AS (movieid:int, title:chararray, year:int,score:float,votes:int);
  CASTING = LOAD '/usr/local/casting.csv' USING PigStorage(',') AS (movieid:int,actorid:int ,ordinal:int);Actors = GROUP CASTING BY actorid;

-- Query 2: Join the data, TB1 joins casting with movie and Tb2 joins Tb1 with actor.

TB1 = JOIN  CASTING  BY movieid,  MOVIE by movieid;
TB2 = JOIN TB1 BY CASTING::actorid,ACTOR by actorid;
Dump TB2;

-- Query3:  titles of movies that have a score higher than 8.

MOVIE_ORDER = ORDER MOVIE BY title;
MOVIESCORE = FILTER MOVIE_ORDER BY score > 8;
MOVIE_TITLE = FOREACH MOVIESCORE GENERATE title ;
dump MOVIE_TITLE;

-- Query 4 : Dump the title and year of movies made in even years in the 1980s.


MOVIE_YEAR =  FILTER MOVIE BY year >=1980 AND year <=1988 AND year % 2== 0;
MOVIE_TITLE1 = FOREACH MOVIE_YEAR GENERATE title,year;
dump MOVIE_TITLE1;

-- QUERY 5 :  top 5 highest vote-getting movies (use ORDER and LIMIT).
-- The question asks us to use order and limit together but if i dont use the rank function it always gives an error after orderring movie by votes and then
-- using limit

MOVIE_ORDER1 = ORDER MOVIE BY votes desc;
B = rank MOVIE_ORDER1;
TOP_FIVE = FOREACH B GENERATE title,votes;
LIM_MOV = LIMIT TOP_FIVE 5;
RES = ORDER LIM_MOV BY votes DESC;
dump RES;

-- Query 6 : actors that have been cast in more than three movies
-- Group by on casting and the filtering where count >3
-- join it to actor to retrieve name and dump names.
-- I tried joining before sorting and decided to use distinct but that did not work so i did it this way.

Actors = GROUP CASTING BY actorid;
ACnt =  FILTER Actors BY COUNT(CASTING)>3;
Actor_Table = JOIN ACTOR BY actorid, ACnt BY group;
Actor_Names = FOREACH Actor_Table Generate ACTOR::name;
Dump Actor_Names;

-- Query 7: Joined all three tables and then filtered coulums needed, used sum and count to get an average.
-- uses same logic as query 6

T1 = JOIN  CASTING  BY movieid,  MOVIE by movieid;
T2 = JOIN T1 BY CASTING::actorid,ACTOR by actorid;
T3 = GROUP T2 BY T1::CASTING::actorid;
T4 =  FILTER T3 BY COUNT(T2.T1::CASTING::movieid)>3;
T5 = FOREACH T4 GENERATE group as id, ((SUM(T2.T1::MOVIE::score))/(COUNT(T2))) as averagePoints;
T6 = JOIN T5 BY id, ACTOR BY actorid;
RESULT = FOREACH T6 GENERATE ACTOR::name ,T5::averagePoints;
Dump RESULT;