------------------------
--- Title: Homework 3
--- Team Members: Ishan Patel(IKP97) , Michael Bohnet (MRB4383), Narain Mandyam (NTM555), Abdullah Khan (AK46996), Emilio Cabrera (EAC4622), Vinay Pahwa (VP7339)
------------------------
--- 1a.
--- Write a SELECT statement that returns the following columns from the Customer_Payment table: Cardholder first name, cardholder last name, the card type, and the card expiration date. 
--- Then, run this statement to make sure it works correctly. 
------------------------
SELECT cardholder_first_name,cardholder_last_name,card_type,expiration_date
FROM customer_payment;

------------------------
--- 1b.
--- Add an ORDER BY clause to this statement that sorts the result set by expiration date in ascending order (i.e. oldest to newest).
--- Then, run this statement again to make sure it works correctly. Note, this is a good way to iteratively build and test a statement, one clause at a time.
------------------------
SELECT cardholder_first_name,cardholder_last_name,card_type,expiration_date
FROM customer_payment
ORDER BY expiration_date;

------------------------
--- 2.
--- Write a SELECT statement that returns one column from the Customer table named customer_full_name that combines the first_name and last_name columns.
--- Format this column with the first name, a space, and last name like this: Michael Jordan. 
--- Sort the result set by last name in descending sequence. Use the “IN” operator to return only the customers whose first name begins with letters of A, B, or C.
------------------------
SELECT cardholder_first_name || ' ' || cardholder_last_name AS customer_full_name
FROM customer_payment
WHERE cardholder_first_name IN (SELECT cardholder_first_name FROM customer_payment WHERE cardholder_first_name LIKE 'A%'
OR cardholder_first_name LIKE 'B%'
OR cardholder_first_name LIKE 'C%')
ORDER BY cardholder_last_name DESC;

------------------------
--- 3.
--- Write a SELECT statement that returns these columns from Reservation: customer_id, confirmation_nbr, date_created, check_in_date, and number_of_guests.
--- Return only the rows for reservations that have a status of “upcoming” that have check_in_dates that are today or in the future but only for this year.
--- That means to filter where only the check_in_date is greater or equal the current date (note: use SYSDATE here) and on or before Dec 31st  
--- See if you can do this with only the following operators (<, >, <=, or >=).  
------------------------
SELECT customer_id, confirmation_nbr, date_created, check_in_date, number_of_guests
FROM reservation
WHERE (status = 'U' AND
check_in_date >= SYSDATE AND
check_in_date <= '31-DEC-21');

------------------------
--- 4a.
--- Part A: Create a duplicate of the previous query but this time update the WHERE clause to use the BETWEEN operator. Keep the rest of the query the same.
------------------------
SELECT customer_id, confirmation_nbr, date_created, check_in_date, number_of_guests
FROM reservation
WHERE (status = 'U' AND
check_in_date BETWEEN SYSDATE AND'31-DEC-21');

------------------------
--- 4b.
--- Part B: Using the MINUS operator, compare the query from #3 to the query from Part A in #4.  
--- If you get no rows returned, that means the queries produce the same results. Pretty cool huh!?! ?
------------------------
SELECT customer_id, confirmation_nbr, date_created, check_in_date, number_of_guests
FROM reservation
WHERE (status = 'U' AND
check_in_date >= SYSDATE AND
check_in_date <= '31-DEC-21')
MINUS
SELECT customer_id, confirmation_nbr, date_created, check_in_date, number_of_guests
FROM reservation
WHERE (status = 'U' AND
check_in_date BETWEEN SYSDATE AND'31-DEC-21');

------------------------
--- 5.
--- Write a SELECT statement that returns these column names and data from the Reservation table:
--- customer_id     The customer_id column
--- location_id     The location_id column
--- length_of_stay  This is calculated by subtracting check_in_date from the check_out_date. Assign an alias of length_of_stay 
---
--- Filter the query to only show completed reservations (i.e. status = ‘C’). 
--- After you have that running correctly, update filter to use the ROWNUM pseudo column so the result set contains only the first 10 rows from the table.
--- Sort the result set by the column alias length_of_stay in descending order and then also by customer_id ascending
------------------------
SELECT customer_id, location_id,length_of_stay

FROM (SELECT customer_id, location_id,(check_out_date - check_in_date) AS length_of_stay
    FROM reservation
    WHERE status = 'C' 
    ORDER BY length_of_stay DESC, customer_id
)
WHERE ROWNUM <= 10 
;

------------------------
--- 6.
--- Write a SELECT statement that returns the first_name, last_name, email from Customer and also a fourth column called credits_available.
--- The credits available is calculated by subtracting credits used from credits earned. 
--- Once you have this, filter to only show customers with at least 10 or more credits available.
--- Sort results by the column alias credits_available.
------------------------
SELECT first_name, last_name, email, (stay_credits_earned - stay_credits_used) AS credits_available
FROM customer
WHERE (stay_credits_earned - stay_credits_used) >= 10
ORDER BY credits_available;

------------------------
--- 7.
--- Write a SELECT statement that returns the first, middle, and last name of a customer’s payment profile on Customer_Payment
--- Using the NULL operator, return only rows for those customers with a middle name. Sort by column positions 2 and then 3 in ascending order
------------------------
SELECT cardholder_first_name,cardholder_mid_name,cardholder_last_name
FROM customer_payment
WHERE cardholder_mid_name IS NOT NULL
ORDER BY 2,3;


------------------------
--- 8.
--- Using the DUAL table write a SELECT statement that uses SYSDATE function to create a row with these columns:
--- today_unformatted   The SYSDATE function unformatted
--- today_formatted     The SYSDATE function in this format: MM/DD/YYYY
---
--- This displays a number for the month, a number for the day, and a four-digit year. 
--- Use a FROM clause that specifies the Dual table. 
--- Hint: You will need to implement the TO_CHAR function to format the sysdate in the format designated above.
--- After you write this add the following columns to the row:
--- Credits_Earned      25
--- Stays_Earned        25 / 10
--- Redeemable_stays    (25/10) returned with FLOOR() function
--- Next_Stay_to_earn   (25/10) rounded to nearest whole number   
--- Your result table contains only one row.
------------------------
SELECT SYSDATE AS today_unformatted, 
TO_CHAR(SYSDATE, 'MM/DD/YYYY') AS today_formatted, 
25 AS credits_earned,25/10 AS stays_earned,
FLOOR(25/10) AS redeemable_stays, 
ROUND(25/10) AS next_stay_to_earn
FROM DUAL;

------------------------
--- 9.
--- Write a SELECT statement that pulls Reservation records for all reservations that are completed (i.e. status of C) for location 2.
--- Return only the following columns: Customer_id, Location_id, and a calculated column called length_of_stay which is just checkout date minus check-in date.
--- Sort the results by length_of_stay descending and customer_id ascending. 
--- Lastly only pull in the top 20 rows. That means we want you to sort the table before filtering the 20 rows.
--- Hint: Do this using FETCH command and not with a subquery since subqueries come later.
------------------------
SELECT customer_id, location_id, (check_out_date - check_in_date) AS length_of_stay FROM reservation
WHERE status = 'C' AND location_id = 2
ORDER BY length_of_stay DESC, customer_id
FETCH FIRST 20 ROWS ONLY;

------------------------
--- 10.
--- Pull all customers and their reservations. Filter data to only show completed reservations (i.e. status is C).  
--- Return just the following columns: first_name, last_name, confirmation_nbr, date_created, check_in_date, check_out_date.
--- Sort results by customer_id ascending and check_out_date descending so that we see all customers and their most recent checkouts first.
------------------------
SELECT c.first_name, c.last_name, r.confirmation_nbr, r.date_created, r.check_in_date, r.check_out_date
FROM reservation r JOIN customer c
ON r.customer_id = c.customer_id
WHERE r.status = 'C'
ORDER BY r.customer_id, r.check_out_date DESC;

------------------------
--- 11.
--- Write a query that joins matching records between the following tables (Customer, Reservation, Reservation_Details, and Room) so we can understand what rooms customers are staying in. 
--- Only return rows for upcoming reservations (i.e. status of U) and for customers that have earned more than 40 credits.  
--- The query should display the following columns:
--- Name – a concatenation of a customer’s first and last name like so: e.g. Tayfun Keskin
--- Location_ID
--- Confirmation_Nbr
--- Check_in_date
--- Room_number
------------------------
SELECT c.first_name || ' ' || c.last_name as customer_full_name, r.location_id, r.confirmation_nbr, r.check_in_date, ro.room_number
FROM customer c 
    JOIN reservation r
        ON c.customer_id = r.customer_id
    JOIN reservation_details rd
        ON r.reservation_id = rd.reservation_id
    JOIN room ro
        ON rd.room_id = ro.room_id
WHERE r.status = 'U' AND c.stay_credits_earned > 40;

------------------------
--- 12. 
--- Write a query that returns any customers in our system’s customer table that have never had a reservation. 
--- Show that you can use the proper type of join that will return all customers even when there’s no matching reservation for them.
--- Results should display the following columns for the customer: first_name, last_name, confirmation_nbr, date_created, check_in_date, check_out_date
------------------------
SELECT c.first_name, c.last_name, r.confirmation_nbr, r.date_created, r.check_in_date, r.check_out_date
FROM customer c LEFT JOIN reservation r
ON c.customer_id = r.customer_id
WHERE r.customer_id IS NULL;


------------------------
--- 13.
--- Use the UNION operator to generate a result set consisting of five columns (four directly from the Customer table, and one calculated) as below:
--- Status_level      A calculated column that contains a value of ‘1-Gold Member’, ‘2-Platinum Member’, or ‘3-Diamond Club’
--- First_name
--- Last_name
--- Email
--- Stay_Credits_earned
--- If the customer has less than 10 credits (they haven’t earned a free stay yet), they are considered to be Gold Level & so their status_level column should contain a literal string value of ‘1-Gold Member’.
--- If the customer has earned more than or equal to 10 credits but less than 40, their status_level column should contain a literal string value of ‘2-Platinum Member’.
--- Otherwise, it the status_level is ‘3-Diamond Club’
--- Sort the final result set by the first and third columns in the results.  
------------------------
--    SELECT  '1-Gold-Member' AS status_level,c1.first_name,c1.last_name,c1.email,c1.stay_credits_earned
--    FROM customer c1 JOIN customer c2
--        ON c1.customer_id = c2.customer_id
--    WHERE c1.stay_credits_earned < 10
--UNION
--    SELECT  '2-Platinum-Member' AS status_level,c1.first_name,c1.last_name,c1.email,c1.stay_credits_earned
--    FROM customer c1 JOIN customer c2
--        ON c1.customer_id = c2.customer_id
--    WHERE c1.stay_credits_earned BETWEEN 10 AND 40
--UNION
--    SELECT  '3-Diamond-Club' AS status_level,c1.first_name,c1.last_name,c1.email,c1.stay_credits_earned
--    FROM customer c1 JOIN customer c2
--        ON c1.customer_id = c2.customer_id
--    WHERE c1.stay_credits_earned > 40
--ORDER BY 1,3;

SELECT  '1-Gold-Member' AS status_level,first_name,last_name,email,stay_credits_earned
    FROM customer 
    WHERE stay_credits_earned < 10
UNION
    SELECT  '2-Platinum-Member' AS status_level,first_name,last_name,email,stay_credits_earned
    FROM customer 
    WHERE stay_credits_earned BETWEEN 10 AND 40
UNION
    SELECT  '3-Diamond-Club' AS status_level,first_name,last_name,email,stay_credits_earned
    FROM customer 
    WHERE stay_credits_earned > 40
ORDER BY 1,3;