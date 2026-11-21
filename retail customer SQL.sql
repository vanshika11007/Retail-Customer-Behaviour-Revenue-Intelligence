create view total_revenue as
select  sum(Price*Quantity) as revenue from retail_data;

create view total_customers as 
select count(distinct(Customer_ID)) as total_customers from retail_data;

create view total_qty_sold as
select sum(Quantity) as total_qty from retail_data;

create view country_wise_customer as
select Country, count(distinct(Customer_ID)) as total_customer from retail_data group by Country order by total_customer desc;

create view country_wise_sales as
select Country , sum(Price*Quantity) as revenue from retail_data group by Country order by revenue desc;

create view customer_spending as
select Customer_ID , sum(Price*Quantity) as spending from retail_data where trim(Customer_ID) <> '' 
group by Customer_ID order by spending desc;

create view AOV as 
select (sum(Price*Quantity)) / (count(distinct(Invoice))) as AOV from retail_data;

create view revenue_by_month_ as
select monthname(InvoiceDate) as month_ ,sum(Price*Quantity) as revenue from retail_data group by month_ order by revenue desc ;

create view order_by_country as
select Country , count(distinct(Invoice)) as orders from retail_data group by Country order by orders desc;

create view MOM_growth as 
with t1 as (
select year(InvoiceDate) as yearr, month(InvoiceDate) as month_no, monthname(InvoiceDate) as month_name, sum(Price*Quantity) as revenue 
from retail_data group by yearr, month_no,month_name),
t2 as (
select yearr, month_no,month_name ,revenue , lag(revenue) over(order by yearr,month_no) as previous_month_sales from t1 )
select yearr, month_name, (revenue - previous_month_sales)/(previous_month_sales) *100 from t2 order by yearr, month_no;

create view customer_churn as
select count(*) as customer_churned from (select Customer_ID , max(InvoiceDate) as last_purchase_date from retail_data where trim(Customer_ID) <> '' and Quantity > 0
group by Customer_ID having last_purchase_date < '2010-10-01') as churned;

create view churn_rate as 
with t1 as (
select  Customer_ID , max(InvoiceDate) as last_purchase_date from retail_data where trim(Customer_ID) <> '' and Quantity > 0 
group by Customer_ID ), 
t2 as (
select count(*) as total_customers ,
sum( case when last_purchase_date > '2010-10-01' then 1 else 0 end ) as churned_customer from t1)
select churned_customer , total_customers , round(churned_customer * 100/ total_customers ,2) as churn_rate 
from t2

