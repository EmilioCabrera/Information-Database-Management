/*
HW4: Summary/Subquery
Team Members: Ishan Patel(IKP97) , Michael Bohnet (MRB4383), Narain Mandyam (NTM555)
              Abdullah Khan (AK46996), Emilio Cabrera (EAC4622), Vinay Pahwa (VP7339)
*/

-- QUESTION 1 --
SELECT count(customer_id) as count_of_customer,min(stay_credits_earned) as min_credits,max(stay_credits_earned) as max_credits
FROM customer;

-- QUESTION 2 --
SELECT c.customer_id,count(r.reservation_id) as number_of_Reservations, min(r.check_in_date) as earliest_check_in
FROM reservation r JOIN customer c ON r.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY c.customer_id;

-- QUESTION 3 --
SELECT city,state,round(avg(stay_credits_earned)) as avg_credits_earned
FROM customer
GROUP BY city,state
ORDER BY state,avg_credits_earned DESC;

-- QUESTION 4 --
SELECT c.customer_id, c.last_name, ro.room_number, count(rd.reservation_id) as stay_count
FROM customer c 
    JOIN reservation r
        ON c.customer_id = r.customer_id
    JOIN reservation_details rd
        ON r.reservation_id = rd.reservation_id
    JOIN room ro
        ON rd.room_id = ro.room_id
WHERE r.location_id = 1
GROUP BY c.customer_id,c.last_name,ro.room_number
--HAVING count(rd.reservation_id) > 1 include this line if you only want customers with more than 1 stay
ORDER BY c.customer_id,stay_count DESC;

-- QUESTION 5 --
SELECT c.customer_id, c.last_name, ro.room_number, count(rd.reservation_id) as stay_count
FROM customer c 
    JOIN reservation r
        ON c.customer_id = r.customer_id
    JOIN reservation_details rd
        ON r.reservation_id = rd.reservation_id
    JOIN room ro
        ON rd.room_id = ro.room_id
WHERE r.location_id = 1 and r.status='C'
GROUP BY c.customer_id,c.last_name,ro.room_number
HAVING count(rd.reservation_id) > 2
ORDER BY c.customer_id,stay_count DESC;

-- QUESTION 6 --
SELECT l.location_name, r.check_in_date,sum(r.number_of_guests) as number_of_guests
FROM reservation r JOIN location l on r.location_id=l.location_id
WHERE r.check_in_date > SYSDATE
GROUP BY ROLLUP(l.location_name, r.check_in_date);
/* The most basic way to understand CUBE vs ROLLUP is that CUBE will 
contain every possible ROLLUP scenario for each node whereas ROLLUP will keep the hierarchy in tact. 
CUBE is usueful for getting cross-tabulation rows and every permutation of the data if you need */

-- QUESTION 7 --
SELECT f.feature_name, count(l.location_id) as count_of_locations
FROM location l JOIN location_features_linking lf on l.location_id = lf.location_id
JOIN features f on lf.feature_id = f.feature_id
GROUP BY f.feature_name
HAVING count(l.location_id) > 2;

-- QUESTION 8 --
SELECT customer_id, first_name, last_name, email
FROM customer
WHERE customer_id NOT IN  
(
SELECT distinct c.customer_id
FROM reservation r JOIN customer c ON r.customer_id = c.customer_id
);

SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customer c
WHERE customer_id NOT IN  
(
SELECT distinct customer_id
FROM reservation r
WHERE r.reservation_id IS NOT NULL
);

-- QUESTION 9 --
SELECT first_name, last_name, email, phone, stay_credits_earned
FROM customer
WHERE stay_credits_earned > 
(
SELECT avg(stay_credits_earned) FROM customer
)
ORDER BY stay_credits_earned DESC;

-- QUESTION 10 --
SELECT city, state, sum(stay_credits_earned) as total_earned, sum(stay_credits_used) as total_used
FROM customer
GROUP BY state,city
ORDER BY state,city;

SELECT city, state, (total_earned - total_used) as credits_remaining
FROM
(
SELECT city, state, sum(stay_credits_earned) as total_earned, sum(stay_credits_used) as total_used
FROM customer
GROUP BY state,city
ORDER BY state,city
)
ORDER BY credits_remaining DESC;

-- QUESTION 11 -- 
SELECT r.confirmation_nbr, r.date_created, r.check_in_date, r.status, ro.room_id
FROM reservation r JOIN reservation_details rd on r.reservation_id = rd.reservation_id
JOIN room ro on rd.room_id = ro.room_id
WHERE ro.room_id IN 
(
SELECT ro.room_id
FROM reservation r JOIN reservation_details rd on r.reservation_id = rd.reservation_id
JOIN room ro on rd.room_id = ro.room_id
GROUP BY ro.room_id
HAVING count(ro.room_id) < 5
) and r.status <> 'C';

-- QUESTION 12 --
SELECT cp.cardholder_first_name, cp.cardholder_last_name, cp.card_number, cp.expiration_date, cp.cc_id
FROM customer_payment cp JOIN 
(
SELECT c.customer_id, count(r.reservation_id)
FROM customer c JOIN reservation r on c.customer_id = r.customer_id
WHERE r.status = 'C'
GROUP BY c.customer_id
HAVING  count(r.reservation_id) = 1
) 
c ON cp.customer_id = c.customer_id
WHERE cp.card_type = 'MSTR';


