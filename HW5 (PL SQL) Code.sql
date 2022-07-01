/*
HW5: PL/SQL
Team Members: Ishan Patel(IKP97) , Michael Bohnet (MRB4383), Narain Mandyam (NTM555)
              Abdullah Khan (AK46996), Emilio Cabrera (EAC4622), Vinay Pahwa (VP7339)
*/

-- Q1
/*
Do all tasks below.

(a) Write a script that uses an anonymous block of PL/SQL code to declare a variable called count_reservations 
    and set it to the count of all reservations placed by the customer whose ID is 100002. 
    If the count is greater than 15, then the block should display a message that says, 
    “The customer has placed more than 15 reservations.” Otherwise, the block output should 
    say “The customer has placed 15 or fewer reservations.” 
    Make sure that you set the server output to be on before 
    the PL/SQL block of code and include that at the top of your submission.
(b) Delete the record that has reservation ID = 318 from the reservation_details and reservation tables. Do NOT commit.
(c) Run your PL/SQL again. You should get a different output.
(d) Rollback your deletion.
*/

-- Q1a
SET SERVEROUTPUT ON;

DECLARE
    count_reservations NUMBER (9,2);
BEGIN
    SELECT COUNT(customer_id)
    INTO count_reservations
    FROM reservation
    WHERE customer_id = 100002;
    IF count_reservations > 15 THEN
      DBMS_OUTPUT.PUT_LINE('The customer has placed more than 15 reservations');
    ELSE
      DBMS_OUTPUT.PUT_LINE('The customer has placed 15 or fewer reservations');
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occured in the script');
END;
/

-- Q1b
DELETE FROM reservation_details 
WHERE reservation_id = 318;
DELETE FROM reservation 
WHERE reservation_id = 318;

-- Q1c
SET SERVEROUTPUT ON;

DECLARE
    count_reservations NUMBER (9,2);
BEGIN
    SELECT COUNT(customer_id)
    INTO count_reservations
    FROM reservation
    WHERE customer_id = 100002;
    IF count_reservations > 15 THEN
      DBMS_OUTPUT.PUT_LINE('The customer has placed more than 15 reservations');
    ELSE
      DBMS_OUTPUT.PUT_LINE('The customer has placed 15 or fewer reservations');
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occured in the script');
END;
/

-- Q1d
ROLLBACK;

-- Q2
/*
Run the “set define on;” command to allow substitution variables.  Update the previous statement but this time prompt the user to enter a customer ID and dynamically use that input to pull the count of reservations for the customer ID the user entered.  Also update the output as well to include the customer ID and the count of reservations like so:
e.g. When you prompt the user and they enter 100002, it should return something like “The customers with customer ID: 100002, has placed more than 15 reservations.” If you enter a customer ID = 100003, it should say something like “The customers with customer ID: 100003, has placed 15 or fewer reservations.”. Hint: you’ll need to adjust the SELECT to pull in customer ID with the count which will create a new to aggregate (i.e. group) data
*/
SET SERVEROUTPUT ON;
SET DEFINE ON;

DECLARE
    count_reservations NUMBER;
    customer_id_var NUMBER;
BEGIN
    customer_id_var := &customer_id;
    
    SELECT COUNT(customer_id_var)
    INTO count_reservations
    FROM reservation
    WHERE customer_id = customer_id_var;
    IF count_reservations > 15 THEN
      DBMS_OUTPUT.PUT_LINE('The customer with customer ID: ' || customer_id_var || ' has placed more than 15 reservations');
    ELSE
      DBMS_OUTPUT.PUT_LINE('The customer with customer ID: ' || customer_id_var || ' has placed 15 or fewer reservations');
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occured in the script');
END;
/

-- Q3
/*
Write a script that uses an anonymous block of PL/SQL code that attempts to insert a new customer into the customer table. 
Just utilize the customer_id_seq to assign the customer_id. Make up your own data. 
Only fill in the fields that require a value. Use a column list to complete the insert statement. 
Also commit after the data has been inserted. If the insert is successful, the PL/SQL code should display this message:

1 row was inserted into the customer table.

If the update is unsuccessful, the procedure should display this message:

Row was not inserted. Unexpected exception occurred.
*/
SET SERVEROUTPUT ON;

DECLARE
    cus1 customer%ROWTYPE;
BEGIN
    cus1.customer_id := customer_id_seq.nextval;
    cus1.first_name := 'Bevo';
    cus1.last_name := 'McBevoson';
    cus1.email := 'bevo@bevo.com';
    cus1.phone := '111-111-1111';
    cus1.address_line_1 := '111 Bevo Way';
    cus1.city := 'Austin';
    cus1.state := 'TX';
    cus1.zip := '78751';
    
    INSERT INTO customer(customer_id,first_name,last_name,email,phone,address_line_1,city,state,zip)
    VALUES(cus1.customer_id,cus1.first_name,cus1.last_name,cus1.email,cus1.phone,cus1.address_line_1,
    cus1.city,cus1.state,cus1.zip);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('1 row inserted.'); 
EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE( 'Row was not inserted. Unexpected exception occurred.'); 
END;
/
    
-- Q4
/*
Write a script that uses an anonymous block of PL/SQL code that uses a bulk collect to capture a list of available features that begin with the letter P. The rows in this result set should be sorted by feature name. Then, the code should display a string variable for each feature and its feature.  NOTE: We’re to just going to assign a number for the feature based on it’s place in the list and not its actual feature_id. Your output should look like this: 

Hotel feature 1: Parking Included
Hotel feature 2: Pets Allowed
Hotel feature 3: Pets Not Allowed
Hotel feature 4: Pool
*/
SET SERVEROUTPUT ON;

DECLARE
    TYPE features_table IS TABLE OF VARCHAR(200);
    hotel_features features_table;
BEGIN
    SELECT feature_name
    BULK COLLECT INTO hotel_features
    FROM features
    WHERE feature_name LIKE 'P%'
    ORDER BY feature_name;
    
    FOR i in 1..hotel_features.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Hotel Feature ' || i || ': ' || hotel_features(i));
  END LOOP;
END;
/

-- Q5
/*
Write a more complex version of the previous script that uses a cursor to capture the location name, city, and feature name.  Then output the rows like the shortened sample list below which is sorted by location name, city, and feature name. ***3 bonus points will be given if you can prompt the user for a city and then change the outputted list  to output the location name, city, and feature name for that city.***

Sample Output: (Only first four lines are shown)

Balcones Canyonlands Cabins in Marble Falls has feature: Business Center
Balcones Canyonlands Cabins in Marble Falls has feature: Free Breakfast
Balcones Canyonlands Cabins in Marble Falls has feature: Full Kitchen
Balcones Canyonlands Cabins in Marble Falls has feature: Parking Included
*/
SET SERVEROUTPUT ON;

DECLARE
    CURSOR features_cursor IS
        SELECT l.location_name, l.city, f.feature_name
        FROM location l
            JOIN location_features_linking fl ON l.location_id = fl.location_id
            JOIN features f ON fl.feature_id = f.feature_id
        ORDER BY l.location_name,l.city,f.feature_name;
    feature_row features%ROWTYPE;
    
BEGIN
    FOR feature_row IN features_cursor LOOP
        DBMS_OUTPUT.PUT_LINE(feature_row.location_name || ' in ' || feature_row.city || ' has feature: ' || feature_row.feature_name);
    END LOOP;
END;
/

-- Q6
/*
Take your script from problem 3 and change it from an anonymous block of PL/SQL code to a named procedure called insert_customer that allows you to insert a new customer by passing in customer ID, first name, last name, email, phone, address_line_1, city, state, and zip. Make sure that you are still using the sequence to generate the customer ID.  Handle exceptions generally by rolling back the transaction “when others” occurs. Once your procedure compiles correctly, test it with the following calls.

CALL insert_customer ('Joseph', 'Lee', 'jo12@yahoo.com', '773-222-3344', 'Happy street', 'Chicago', 'Il', '60602');
BEGIN
Insert_customer ('Mary', 'Lee', 'jo34@yahoo.com', '773-222-3344', 'Happy street', 'Chicago', 'Il', '60602');
END;
/  
*/
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE insert_customer
(
 first_name_param VARCHAR2,
 last_name_param VARCHAR2,
 email_param VARCHAR2,
 phone_param CHAR,
 address_line_1_param VARCHAR2,
 city_param VARCHAR2,
 state_param CHAR,
 zip_param CHAR
)
AS
BEGIN
    INSERT INTO customer(customer_id,first_name,last_name,email,phone,address_line_1,city,state,zip)
    VALUES(customer_id_seq.nextval,first_name_param,last_name_param,email_param,phone_param,address_line_1_param,
    city_param,state_param,zip_param);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('1 row inserted.'); 
EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE( 'Row was not inserted. Unexpected exception occurred.');
        ROLLBACK; 
END;
/

CALL insert_customer ('Joseph', 'Lee', 'jo12@yahoo.com', '773-222-3344', 'Happy street', 'Chicago', 'Il', '60602');

BEGIN
Insert_customer ('Mary', 'Lee', 'jo34@yahoo.com', '773-222-3344', 'Happy street', 'Chicago', 'Il', '60602');
END;
/  

-- Q7
/*
Create a function called hold_count that returned the total number of rooms that a customer has reserved when it is passed a customer_id. Once you have compiled your function, test it using the following select statement:

select customer_id, hold_count(customer_id)  
from reservation
group by customer_id
order by customer_id;
*/
SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION hold_count
(
    customer_id_param NUMBER
)
RETURN NUMBER
AS
    room_count_var NUMBER;
BEGIN
    SELECT count(r.room_id)
    INTO room_count_var
    FROM 
        room r JOIN reservation_details rd ON r.room_id = rd.room_id
        JOIN reservation rr ON rd.reservation_id = rr.reservation_id
    WHERE rr.customer_id = customer_id_param;
    
    RETURN room_count_var;
END;
/

select customer_id, hold_count(customer_id)  
from reservation
group by customer_id
order by customer_id;