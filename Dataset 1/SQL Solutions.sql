-- All the questions are solved in PostgreSQL.
/* Q1. Load the Data in the file - "assignment_python.csv" given to you as a .csv using Pandas.*/
 
 CREATE TABLE SQL_ASSIGNMENT (
       IDCUSTOMER  INT  PRIMARY KEY,
 	   GENDER  VARCHAR (1),
	   CITY VARCHAR (50),
	   COUNTRY VARCHAR(50),
	   FIRST_DEPOSIT_AMOUNT FLOAT,
	   REGISTRATION_DATE DATE,
	   DEPOSIT_DATE DATE)
	   
/*checking the data imported*/
SELECT * FROM SQL_ASSIGNMENT


/* Q3. Calculate the time period in days for which the customer was active (days from first deposit date) 
       and enter the value in a new column titled 'Customer Lifetime' & what is the lifetime in days for 
       customer ID - 5371454 */

SELECT CUSTOMER_LIFE_TIME 
FROM (
      SELECT *, DEPOSIT_DATE - REGISTRATION_DATE 
	            AS CUSTOMER_LIFE_TIME 
      FROM SQL_ASSIGNMENT)e
WHERE e.IDCUSTOMER = '5371454'		  


/* Q4. Find the city & country with the highest number of unique customers. */

WITH TABLE1 AS(
				SELECT COUNT(DISTINCT IDCUSTOMER) AS COUNT_CUSTOMER, CITY, COUNTRY 
				FROM SQL_ASSIGNMENT
				GROUP BY (COUNTRY, CITY)
                                        )
SELECT CITY, COUNTRY 
FROM TABLE1
	WHERE COUNT_CUSTOMER = (
							SELECT MAX(COUNT_CUSTOMER) 
							FROM TABLE1
										)


/* Q5. Find the unique count of players in each country (in descending order) & specify the number 
       of unique players from the city - Kayseri. */

-- a. unique count of players in each country (in descending order)

SELECT COUNTRY, COUNT(DISTINCT(IDCUSTOMER)) 
       AS UNIQ_CUSTOMER
FROM SQL_ASSIGNMENT
  GROUP BY COUNTRY
  ORDER BY UNIQ_CUSTOMER DESC
  
/*The given dataset consists of informations of customer from only one country.*/

-- b. Finding the number of unique players from the city - Kayseri

SELECT CITY, COUNT(DISTINCT(IDCUSTOMER)) AS UNIQ_CUSTOMER
FROM SQL_ASSIGNMENT
  WHERE CITY = 'Kayseri'
  GROUP BY CITY


/* Q6.Which city gives the third highest average first_deposit_amount and what is the average amount?*/

SELECT CITY, AVG_AMOUNT 
FROM 
    (
	 SELECT *,DENSE_RANK() OVER(ORDER BY AVG_AMOUNT DESC) AS DENSE_RNK
	 FROM 
		(SELECT CITY , AVG(FIRST_DEPOSIT_AMOUNT) AS AVG_AMOUNT
		FROM SQL_ASSIGNMENT
		GROUP BY CITY)e
	                   )f
WHERE f.DENSE_RNK = 3


/* Q7. Plot a graph showing the city and the descending unique count of the unique customers 
       (upto the top 40 cities by the unique count) and make a large plot (clearly visible) and make sure 
       the title and labels are clearly visible.*/

--Top 40 cities contains higher number of unique customers 

SELECT CITY, COUNT(DISTINCT(IDCUSTOMER)) AS UNIQ_CUSTOMER_COUNT
FROM SQL_ASSIGNMENT
    GROUP BY (CITY)
ORDER BY UNIQ_CUSTOMER_COUNT DESC
LIMIT 40


/* Q8. Plot the conversion for each month of the data 
      (Conversion % = No. of unique First Deposits in the month/ No. of unique Registrations in the month) 
      Here, the conversion percentage should be reflected in red, and the labels in the X-axis should be year 
      & month out of the Deposit Dates.*/

WITH 
	TABLE_REG_COUNT AS(
			SELECT REG_Y_M , COUNT(DISTINCT(IDCUSTOMER)) AS CUST_COUNT_REG
			FROM 
				 (SELECT *, TO_CHAR(REGISTRATION_DATE ,'YYYY-MM') AS REG_Y_M
				  FROM SQL_ASSIGNMENT)e
			GROUP BY e.REG_Y_M) ,

    TABLE_DEPOSIT_COUNT AS(
			SELECT DEPO_Y_M , COUNT(DISTINCT(FIRST_DEPOSIT_AMOUNT)) AS FIRST_AMOUNT_COUNT 
			FROM 
				 (SELECT *, TO_CHAR(DEPOSIT_DATE ,'YYYY-MM') AS DEPO_Y_M
				  FROM SQL_ASSIGNMENT)f
			GROUP BY f.DEPO_Y_M) ,
			
    TABLE_JOIN AS(
	        SELECT reg_y_m AS date, CUST_COUNT_REG , FIRST_AMOUNT_COUNT 
		    FROM TABLE_REG_COUNT 
		          JOIN TABLE_DEPOSIT_COUNT
		          ON TABLE_REG_COUNT.REG_Y_M = TABLE_DEPOSIT_COUNT.DEPO_Y_M)

SELECT *, CAST(FIRST_AMOUNT_COUNT AS FLOAT)/CAST(CUST_COUNT_REG AS FLOAT)*100 
          AS Conversion_percentage
FROM TABLE_JOIN


/*Q9. What was the conversion rate in June 2022, limit the answer to 2 decimal places.(in %) */

WITH 
	TABLE_REG_COUNT AS(
			SELECT REG_Y_M , COUNT(DISTINCT(IDCUSTOMER)) AS CUST_COUNT_REG
			FROM 
				 (SELECT *, TO_CHAR(REGISTRATION_DATE ,'YYYY-MM') AS REG_Y_M
				  FROM SQL_ASSIGNMENT)e
			GROUP BY e.REG_Y_M) ,

    TABLE_DEPOSIT_COUNT AS(
			SELECT DEPO_Y_M , COUNT(DISTINCT(FIRST_DEPOSIT_AMOUNT)) AS FIRST_AMOUNT_COUNT 
			FROM 
				 (SELECT *, TO_CHAR(DEPOSIT_DATE ,'YYYY-MM') AS DEPO_Y_M
				  FROM SQL_ASSIGNMENT)f
			GROUP BY f.DEPO_Y_M) ,
			
    TABLE_JOIN AS(
	        SELECT reg_y_m AS date, CUST_COUNT_REG , FIRST_AMOUNT_COUNT 
		    FROM TABLE_REG_COUNT 
		          JOIN TABLE_DEPOSIT_COUNT
		          ON TABLE_REG_COUNT.REG_Y_M = TABLE_DEPOSIT_COUNT.DEPO_Y_M) ,
				  
	TABLE_CP AS(
			SELECT *, CAST(FIRST_AMOUNT_COUNT AS FLOAT)/CAST(CUST_COUNT_REG AS FLOAT)*100 
					  AS Conversion_percentage
			FROM TABLE_JOIN)

SELECT Conversion_percentage FROM TABLE_CP
WHERE date = '2022-06'


/* Q10. Make a copy of the original data in the file assignment_python as a pandas dataframe called 'df_ft' 
        and generate the following columns */
/* Q10.1  week of day column from the deposit date column */

SELECT *,EXTRACT(ISODOW FROM DEPOSIT_DATE ) AS WEEK_DAY 
FROM SQL_ASSIGNMENT


/* Q10.2 descriptive statistics of the table*/

-- Descriptive statistics of numerical columns 

SELECT 'COUNT',
      COUNT(*) AS FIRST_DEPOSIT_AMOUNT
FROM SQL_ASSIGNMENT
UNION
SELECT 'MEAN',
	 AVG(FIRST_DEPOSIT_AMOUNT)
FROM SQL_ASSIGNMENT
UNION
SELECT 'STD',
	STDDEV(FIRST_DEPOSIT_AMOUNT)
FROM SQL_ASSIGNMENT
UNION 
SELECT 'MIN',
	MIN(FIRST_DEPOSIT_AMOUNT)
FROM SQL_ASSIGNMENT
UNION 
SELECT 'MAX',
	MAX(FIRST_DEPOSIT_AMOUNT)
FROM SQL_ASSIGNMENT
UNION 
SELECT '75%',
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY FIRST_DEPOSIT_AMOUNT)
FROM SQL_ASSIGNMENT
UNION 
SELECT 'MEDIAN',
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY FIRST_DEPOSIT_AMOUNT)
FROM SQL_ASSIGNMENT
UNION 
SELECT '25%',
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY FIRST_DEPOSIT_AMOUNT)
FROM SQL_ASSIGNMENT

/* Q10.3 make a column with the first_deposit_amounts binned in bins of 500 and reflected against 
         every customer ID (for example, someone with a first deposit amount of 880 should reflect in the 
         binning column as '500-1000' */

-- Very less number of observations consists of FIRST_DEPOSIT_AMOUNT >9000, So i am creating bins of 1000 insted of 500 and assign all the deposits> 9000 to a single bin

SELECT * , 
  CASE 
     WHEN (FIRST_DEPOSIT_AMOUNT <= 1000) THEN '(0, 1000]'
	 WHEN (FIRST_DEPOSIT_AMOUNT >1000 ) AND (FIRST_DEPOSIT_AMOUNT <=2000) THEN '(1000,2000]'
     WHEN (FIRST_DEPOSIT_AMOUNT >2000) AND (FIRST_DEPOSIT_AMOUNT <=3000) THEN '(2000,3000]'
	 WHEN (FIRST_DEPOSIT_AMOUNT >3000) AND (FIRST_DEPOSIT_AMOUNT <=4000) THEN '(3000,4000]'
	 WHEN (FIRST_DEPOSIT_AMOUNT >4000) AND (FIRST_DEPOSIT_AMOUNT <=5000) THEN '(4000,5000]'
	 WHEN (FIRST_DEPOSIT_AMOUNT >5000) AND (FIRST_DEPOSIT_AMOUNT <=6000) THEN '(5000,6000]'
	 WHEN (FIRST_DEPOSIT_AMOUNT >6000) AND (FIRST_DEPOSIT_AMOUNT <=7000) THEN '(6000,7000]'
	 WHEN (FIRST_DEPOSIT_AMOUNT >7000) AND (FIRST_DEPOSIT_AMOUNT <=8000) THEN '(7000,8000]'
	 WHEN (FIRST_DEPOSIT_AMOUNT >8000) AND (FIRST_DEPOSIT_AMOUNT <=9000) THEN '(8000,9000]'
	 WHEN (FIRST_DEPOSIT_AMOUNT >9000)  THEN '>9000'
	 END AS first_deposit_amounts_binned
FROM SQL_ASSIGNMENT


/* Q11. Find a 7 days moving average of number of registrations. (calculating an average of the T-7 days 
        for every week's total registrations) */

SELECT * , TRUNC(AVG(WEEKLY_REG)
         OVER( ORDER BY week_num ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 4)
         AS moving_average  
FROM 
	 (
		SELECT week_num ,COUNT(DISTINCT(IDCUSTOMER)) AS WEEKLY_REG
		FROM 
			  (
				SELECT * , DATE_PART('week',REGISTRATION_DATE) AS week_num
				FROM SQL_ASSIGNMENT
				ORDER BY REGISTRATION_DATE
										   )e
		  GROUP BY e.week_num)f





