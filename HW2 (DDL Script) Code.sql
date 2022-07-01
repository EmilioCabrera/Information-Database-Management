---------------------------------------------------------
-- DROP Section
-- Section that will drop all the tables in the proper order
-- Authors: Ishan Patel (IKP97)
---------------------------------------------------------
-- Drop all sequences and tables in the proper order so that referntial integrity is not compromised
DROP SEQUENCE Payment_ID_seq;
DROP SEQUENCE Reservation_ID_seq;
DROP SEQUENCE Room_ID_seq;
DROP SEQUENCE Location_ID_seq;
DROP SEQUENCE Feature_ID_seq;
DROP SEQUENCE Customer_ID_seq;

DROP TABLE Location_Features_Linking;
DROP TABLE Features;
DROP TABLE Reservation_Details;
DROP TABLE Room;
DROP TABLE Location;
DROP TABLE Reservation;
DROP TABLE Customer_Payment;
DROP TABLE Customer;

---------------------------------------------------------
-- CREATE Section
-- Section that will create the tables with the approprate PKs and FKs
-- Authors: Michael Bohnet (MRB4383), Narain Mandyam (NTM555), Abdullah Khan (AK46996), Emilio Cabrera (EAC4622)
---------------------------------------------------------

-- Create Customer table with a Customer_ID PK
CREATE TABLE Customer
(
    Customer_ID         NUMBER                      NOT NULL,
    First_Name          VARCHAR2(100)               NOT NULL,
    Last_Name           VARCHAR2(100)               NOT NULL,
    Email               VARCHAR2(100)               NOT NULL,
    Phone               CHAR(12)                    NOT NULL,
    Address_Line_1      VARCHAR2(100)               NOT NULL,
    Address_Line_2      VARCHAR2(100),
    City                VARCHAR2(100)               NOT NULL,
    State               CHAR(2)                     NOT NULL,
    Zip                 CHAR(5)                     NOT NULL,
    Birthdate           DATE,
    Stay_Credits_Earned NUMBER          DEFAULT 0   NOT NULL,
    Stay_Credits_Used   NUMBER          DEFAULT 0   NOT NULL,
    
    CONSTRAINT Customer_pk PRIMARY KEY (Customer_ID),
    CONSTRAINT Credits_ck CHECK (Stay_Credits_Used <= Stay_Credits_Earned),
    CONSTRAINT Email_Length_ck CHECK (LENGTH(Email) >= 7),
    CONSTRAINT Email_unq UNIQUE (Email) 
);

-- Create Payments Table with a Payment_ID PK and link it with a FK to Customer with Customer_ID
CREATE TABLE Customer_Payment 
(
    Payment_ID              NUMBER          NOT NULL,
    Customer_ID             NUMBER          NOT NULL,
    Cardholder_First_Name   VARCHAR2(100)   NOT NULL,
    Cardholder_Mid_Name     VARCHAR2(100), -- Did not put NOT NULL because not everyone has a Legal Middle Name
    Cardholder_Last_Name    VARCHAR2(100)   NOT NULL,
    CardType                CHAR(4)         NOT NULL,
    CardNumber              VARCHAR2(20)    NOT NULL, --- CC #s can go up to 20 digits 
    Expiration_Date         DATE            NOT NULL,
    CC_ID                   VARCHAR2(5)     NOT NULL, ---CVC codes can go up to 5 digits
    Billing_Address         VARCHAR2(100)   NOT NULL,
    Billing_City            VARCHAR2(100)   NOT NULL,
    Billing_State           CHAR(2)         NOT NULL,
    Billing_Zip             CHAR(5)         NOT NULL,
    
    CONSTRAINT Payment_pk PRIMARY KEY (Payment_ID),
    CONSTRAINT Payment_fk_Customer FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID)
);

-- Create Reservations Table with a Reservation_ID PK and link it with a FK to Customer with Customer_ID
CREATE TABLE Reservation 
(
    Reservation_ID      NUMBER                      NOT NULL,
    Customer_ID         NUMBER                      NOT NULL,
    Confirmation_Nbr    CHAR(8)                     NOT NULL,
    Date_Created        DATE      DEFAULT SYSDATE   NOT NULL,
    Check_In_Date       DATE                        NOT NULL,
    Check_Out_Date      DATE,
    Status              CHAR(1)                     NOT NULL,
    Discount_Code       VARCHAR2(50),
    Reservation_Total   NUMBER(9,2)                 NOT NULL,
    Customer_Rating     NUMBER,
    Notes               VARCHAR2(1000), -- up to 1,000 characters
    
    CONSTRAINT Reservation_pk PRIMARY KEY (Reservation_ID),
    CONSTRAINT Reservation_fk_Customer FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID),
    CONSTRAINT Status_ck CHECK (Status = 'U' OR Status = 'I' OR Status = 'C' OR Status = 'N' OR Status = 'R'),
    CONSTRAINT Confirmation_Nbr_unq UNIQUE (Confirmation_Nbr) 
);

-- Create Locations Table with a Location_ID PK
CREATE TABLE Location 
(
    Location_ID     NUMBER          NOT NULL,
    Location_Name   VARCHAR2(100)   NOT NULL,
    Address         VARCHAR2(100)   NOT NULL,
    City            VARCHAR2(100)   NOT NULL,
    State           CHAR(2)         NOT NULL,
    Zip             CHAR(5)         NOT NULL,
    Phone           CHAR(12)        NOT NULL,
    URL             VARCHAR2(100)   NOT NULL,
    
    CONSTRAINT Location_pk PRIMARY KEY (Location_ID),
    CONSTRAINT Location_Name_unq UNIQUE (Location_Name) 
);

-- Create Rooms Table with a Room_ID PK and link it with a FK to Location with Location_ID
CREATE TABLE Room 
(
    Room_ID         NUMBER          NOT NULL,
    Location_ID     NUMBER          NOT NULL,
    Floor           VARCHAR2(100)   NOT NULL,
    Room_Number     VARCHAR2(100)   NOT NULL,
    Room_Type       CHAR(1)         NOT NULL,
    Square_Footage  NUMBER          NOT NULL,
    Max_People      NUMBER          NOT NULL,
    Weekday_Rate    NUMBER(9,2)     NOT NULL,
    Weekend_Rate    NUMBER(9,2)     NOT NULL,
    
    CONSTRAINT Rooms_pk PRIMARY KEY (Room_ID),
    CONSTRAINT Rooms_fk_Location FOREIGN KEY (Location_ID) REFERENCES Location (Location_ID),
    CONSTRAINT Room_Type_ck CHECK (Room_Type = 'D' OR Room_Type = 'Q' OR Room_Type = 'K' OR Room_Type = 'S' OR Room_Type = 'C')
);

-- Create Reservations_Details Join Table with a Reservation_ID and Room_ID Composite PK
CREATE TABLE Reservation_Details 
(
    Reservation_ID      NUMBER NOT NULL,
    Room_ID             NUMBER NOT NULL,
    Number_of_Guests    NUMBER NOT NULL,
    
    CONSTRAINT Reservation_Details_pk PRIMARY KEY (Reservation_ID, Room_ID),
    CONSTRAINT Reservation_Details_fk1 FOREIGN KEY (Reservation_ID) REFERENCES Reservation (Reservation_ID),
    CONSTRAINT Reservation_Details_fk2 FOREIGN KEY (Room_ID) REFERENCES Room (Room_ID)
);

-- Create Features Table with a Feature_ID PK
CREATE TABLE Features 
(
    Feature_ID     NUMBER           NOT NULL,
    Feature_Name   VARCHAR2(100)    NOT NULL,
    
    CONSTRAINT Features_pk PRIMARY KEY (Feature_ID),
    CONSTRAINT Feature_Name_unq UNIQUE (Feature_Name)
);

-- Create Location_Features_Linking Join Table with a Location_ID and Feature_ID Composite PK
CREATE TABLE Location_Features_Linking
(
    Location_ID NUMBER NOT NULL,
    Feature_ID  NUMBER NOT NULL,
    
    CONSTRAINT Location_Feature_pk PRIMARY KEY (Location_ID, Feature_ID),
    CONSTRAINT Location_Feature_fk1 FOREIGN KEY (Location_ID) REFERENCES Location (Location_ID),
    CONSTRAINT Location_Feature_fk2 FOREIGN KEY (Feature_ID) REFERENCES Features (Feature_ID)
);

---------------------------------------------------------
-- INSERT DATA Section
-- Section that will create sequences certain IDs and inserting data into tables
-- Authors: Emilio Cabrera (EAC4622), Vinay Pahwa (VP7339), Ishan Patel (IKP97)
---------------------------------------------------------

-- Create a sequence for Payment_id that increments by 1 starting at 1
CREATE SEQUENCE Payment_ID_seq 
    START WITH 1  
    INCREMENT BY 1;

-- Create a sequence for Reservation_id that increments by 1 starting at 1
CREATE SEQUENCE Reservation_ID_seq  
    START WITH 1  
    INCREMENT BY 1;

-- Create a sequence for Room_id that increments by 1 starting at 1
CREATE SEQUENCE Room_ID_Seq
    START WITH 1  
    INCREMENT BY 1;

-- Create a sequence for Location_id that increments by 1 starting at 1
CREATE SEQUENCE Location_ID_seq 
    START WITH 1  
    INCREMENT BY 1;

-- Create a sequence for Feature_id that increments by 1 starting at 1
CREATE SEQUENCE Feature_ID_seq 
    START WITH 1  
    INCREMENT BY 1;

-- Create a sequence for Customer_id that increments by 1 starting at 100001
CREATE SEQUENCE Customer_ID_seq 
    START WITH 100001  
    INCREMENT BY 1;

-- Create 3 Locations from HW1
INSERT INTO Location
VALUES(Location_ID_seq.NEXTVAL,'AUS01','1 South Congress Avenue','Austin','TX','78751','512-299-0203','http://www.socohotel.com');

INSERT INTO Location
VALUES(Location_ID_seq.NEXTVAL,'AUS02','422 East 7th Street','Austin','TX','78751','512-933-1234','http://www.eastloftshotel.com');

INSERT INTO Location
VALUES(Location_ID_seq.NEXTVAL,'AUS03','Balcones Canyons Boulevard','Marble Falls','TX','78654','512-343-8484','http://www.balconeshotel.com');

COMMIT;

-- Create 3 features
-- Link it with the Locations_Features_Linking Table
INSERT INTO Features
VALUES(Feature_ID_seq.NEXTVAL,'Complementary Wi-Fi');

INSERT INTO Features
VALUES(Feature_ID_seq.NEXTVAL,'Complementary Breakfast');

INSERT INTO Features
VALUES(Feature_ID_seq.NEXTVAL,'Business Center');

COMMIT;

INSERT INTO Location_Features_Linking
VALUES(1,1);

INSERT INTO Location_Features_Linking
VALUES(1,2);

INSERT INTO Location_Features_Linking
VALUES(1,3);

INSERT INTO Location_Features_Linking
VALUES(2,1);

INSERT INTO Location_Features_Linking
VALUES(2,2);

INSERT INTO Location_Features_Linking
VALUES(2,3);

INSERT INTO Location_Features_Linking
VALUES(3,1);

INSERT INTO Location_Features_Linking
VALUES(3,2);

INSERT INTO Location_Features_Linking
VALUES(3,3);

COMMIT;

-- Create 2 rooms for each location
INSERT INTO Room
VALUES(Room_ID_Seq.NEXTVAL,1,1,101,'D',200,2,150,200);

INSERT INTO Room
VALUES(Room_ID_Seq.NEXTVAL,1,2,201,'Q',200,2,180,220);

INSERT INTO Room
VALUES(Room_ID_Seq.NEXTVAL,2,1,101,'D',200,2,150,200);

INSERT INTO Room
VALUES(Room_ID_Seq.NEXTVAL,2,2,201,'Q',200,2,180,220);

INSERT INTO Room
VALUES(Room_ID_Seq.NEXTVAL,3,1,101,'D',200,2,150,200);

INSERT INTO Room
VALUES(Room_ID_Seq.NEXTVAL,3,2,201,'Q',200,2,180,220);

COMMIT;

-- Create 2 customers with payments attached
-- Link it with the Customer_Payment table
INSERT INTO Customer
VALUES(Customer_ID_seq.NEXTVAL,'Emilio','Cabrera','eac4622@utexas.edu','123-456-7890','Wall Street','#5420','New York City','NY',
'10001','03-December-1995', 100, 50);

INSERT INTO Customer
VALUES(Customer_ID_seq.NEXTVAL,'Narain','Bohnet','iamsixfootfive@utexas.edu','098-765-4321','Bufrods Street','#4690','Austin','TX',
'78751','14-February-1997', 300, 0);

COMMIT;

INSERT INTO Customer_Payment
VALUES(Payment_ID_seq.NEXTVAL,100001,'Emilio','','Cabrera', 'VISA',1111222233334444,'31-December-2024',567,'Wall Street','New York City','NY',
'10001');

INSERT INTO Customer_Payment
VALUES(Payment_ID_seq.NEXTVAL,100002,'Narain','','Bohnet', 'VISA',2222333344445555,'31-December-2024',678,'Bufords Street','Austin','TX',
'78751');

COMMIT;

-- Create Reservations for 2 customers where 2 reservations are for different dates for 1 customer
-- Link it to the Reservation_Details table 
INSERT INTO Reservation
VALUES(Reservation_ID_seq.NEXTVAL,100001,'ASD6FGH0',DEFAULT,'12-March-2022','','U','',300.00,'','');

INSERT INTO Reservation
VALUES(Reservation_ID_seq.NEXTVAL,100002,'ZXC3VBN8',DEFAULT,'17-April-2022','','U','',3000.00,'','Extra Towels');

INSERT INTO Reservation
VALUES(Reservation_ID_seq.NEXTVAL,100002,'QWE6RTY9','04-May-2021','04-July-2021','06-July-2021','C','',440.00,4,'');

COMMIT;

INSERT INTO Reservation_Details
VALUES(1,1,1);

INSERT INTO Reservation_Details
VALUES(2,2,1);

INSERT INTO Reservation_Details
VALUES(3,3,1);

COMMIT;

---------------------------------------------------------
-- INDEX Section
-- Section that will create indexes for non-PK FKs or any important query feature
-- Authors: Ishan Patel (IKP97), Emilio Cabrera (EAC4622)
---------------------------------------------------------

---A)
CREATE INDEX idx_Reservation -- Create Index on FK for the Reservation Table
ON Reservation (Customer_ID);

CREATE UNIQUE INDEX idx_Customer_Payment -- Create Index on FK for the Customer_Payment Table
ON Customer_Payment (Customer_ID);

CREATE INDEX idx_Room -- Create Index on FK for the Room Table
ON Room (Location_ID);

---B)
CREATE INDEX idx_State -- Create Index on State for the Customer Table
ON Customer (State);

CREATE INDEX idx_City -- Create Index on City for the Customer Table
ON Customer (City);
