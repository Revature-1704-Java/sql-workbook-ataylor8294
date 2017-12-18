--2.1
select * from employee;
select * from employee where lastname='King';
select * from employee where firstname ='Andrew' and reportsto is null;
--2.2
select firstname from customer order by firstname asc;
select * from album order by title;
--2.3
insert into genre values(50, 'punkrock');
insert into genre values(51, 'steel');
insert into employee values(501, 'Andrew','Taylor','It Staff',5,'09-JAN-94','02-NOV-17','313 baller','Reston','VA','America','2222','738q898495','983480454','andrew@revature.com');
insert into employee values(502, 'Kevin','Jasmine','It Staff',5,'09-JAN-94','01-NOV-17','313 baller','Los Angeles','CA','America','2232','738q898493','983480354','kevin@revature.com');
insert into customer values(503, 'Brady', 'Kilpatrick', 'Mavia', '543 lane', 'San Diego', 'CA', 'America', '739893','984984','93284859483','brady@pointloma.edu',5);
insert into customer values(504, 'Sam', 'Fuller', 'Mavia', '543 lane', 'San Diego', 'CA', 'America', '734893','9849834','932848593483','sam@pointloma.edu',5);
--2.4
update customer set customer.firstname='robert', customer.lastname='walter' where customer.firstname='aaron' and customer.lastname='Mitchell';
update artist set artist.name='CCR' where arist.name='Creedence clearwster Revival';

--2.5
select * from invoice where BILLINGADDRESS like 'T%';
--2.6
select * from invoice where total between 15 and 50;
select * from employee where hiredate between '01-JUN-03' and '01-MAR-04';
select * from invoice;

--2.6 Delete a record in Customer table where the name is Robert Walter 
alter table invoice drop constraint FK_invoicecustomerid;
alter table invoice add constraint fk_invoicecustomer FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId)  on delete cascade;
alter table invoiceline drop constraint FK_InvoiceLineInvoiceId;
alter table invoiceline add constraint invoicelineinvoice foreign key (invoiceid) references invoice (invoiceid) on delete cascade;
delete from customer c where c.firstname='robert' and c.lastname='walter';
--3.0


create or replace function 
gettime
return timestamp with time zone as times timestamp with time zone;
begin
times := current_timestamp;
return times;
end;
/


--3.1
declare 
times timestamp with time zone;
begin
times:=gettime;
dbms_output.put_line('Current time '||times);
end;
/

create or replace function
getlength(x in varchar2)
return integer as sizes integer;
begin
    sizes:=length(x);
    return sizes;
end;
/



    
declare 
x mediatype.name%type;
sizes integer;
begin
select mediatype.name into x from mediatype where MEDIATYPEID=1;
sizes:= getlength(x);
dbms_output.put_line(sizes);
end;
/

--3.2
create or replace function getaverage
return number as x number;
begin
select AVG(i.total) into x from invoice i;
return x;
end;
/

declare
x number;
begin
x:=getaverage;
dbms_output.put_line('Avg '||x);
end;
/

select* from track t where t.unitprice = (select
max(unitprice)from track);

select max(unitprice) from track;

create or replace function
gettrack
return sys_refcursor as s sys_refcursor;
begin
open s for select t.trackid, t.name, t.albumid from track t where t.unitprice = (select max(unitprice)from track);
return s;
end;
/


declare 
cursors sys_refcursor;
tracksid  track.trackid%type;
tracksal track.name%type;
tracksalid track.albumid%type;
begin
cursors:=gettrack;
    loop
    fetch cursors into tracksid, tracksal, tracksalid;
    exit when cursors%notfound;
    dbms_output.put_line('track with max price' ||tracksid || ' album: '||tracksal|| ' albumid: '||tracksalid);
    end loop;
end;
/
--3.3
create or replace function
getavg(summ in number, counts in integer)
return number as numb number;
begin
    numb :=summ/counts;
    return numb;
end;
/

declare
summ number;
counts integer;
average number;
begin
    select count(*) into counts from invoiceline;
    select SUM(unitprice) into summ from invoiceline i;
    DBMS_OUTPUT.PUT_LINE('summ '||summ||' counts '||counts);
    average:= getavg(summ, counts);
    dbms_output.put_line('the average is '||average);
end;
/
--3.4
create or replace function youngpeople
return sys_refcursor as s sys_refcursor;
begin
open s for select  e.employeeid, e.lastname, e.firstname, e.title from employee e where e.birthdate>'31-DEC-68'; 
return s;
end;
/
declare 
s sys_refcursor;
emps employee.employeeid%type;
lnames employee.lastname%type;
fnames employee.firstname%type;
titles employee.title%type;
begin
s:= youngpeople;
    loop
    fetch s into emps, lnames, fnames, titles;
    exit when s%notfound;
    dbms_output.put_line('young employees are id: '||emps||' last name: '||lnames||'first names: '||fnames||' title: '||titles);
    end loop;
end;
/
--stored procedures 4.0
create or replace procedure
names(s out sys_refcursor)
as
begin
    open s for select e.lastname, e.firstname from employee e;
end;
/

declare
s sys_refcursor;
fname employee.firstname%type;
lname employee.lastname%type;
begin
names(s);
    loop
    fetch s into lname, fname;
    exit when s%notfound;
    dbms_output.put_line('names of employees '||fname||' '||lname);
    end loop;
end;
/
create or replace procedure  updateemail(eid in integer, emails in varchar2)
as 
begin
    update employee e set e.email=emails where e.employeeid=eid;
end;
/

declare
emails employee.email%type;
ids integer;
begin
emails := 'frank@revature.com';
ids := 1;
updateemail(ids, emails);
end;
/

create or replace procedure
getmanager(emp in integer, manf out varchar2, manl out varchar2)
as
begin
select e2.firstname, e2.lastname into manf, manl from employee e, employee e2 where e.reportsto = e2.employeeid and e.employeeid=emp; 
end;
/

declare 
emp integer;
firstn varchar2(20);
lastn varchar2(20);
begin
emp:=8;
getmanager(emp, firstn, lastn);
dbms_output.put_line('first name : '||firstn||' last name :'||lastn);
end;
/
--4.3
create or replace procedure
getcustomer(ids in integer, names out varchar2, names2 out varchar2, companies out varchar2)
as 
begin
select c.firstname, c.lastname, c.company into names, names2, companies from customer c where c.customerid=ids;
end;
/
declare
ids integer;
fname varchar2(20);
lname varchar2(20);
comp varchar2(20);
begin
ids:=3;
getcustomer(ids, fname, lname, comp);
dbms_output.put_line('customer id: '||ids||' first name '||fname|| ' last name '||lname||' company '||comp);
end;
/
delete * from invoice order by invoice.invoiceid=412;

--5.0 Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
create or replace procedure
deleteinv(ids in integer ) as
begin
    
    delete from invoice i where i.invoiceid=ids;
    commit;
end;
/
declare 
ids integer;
begin
    ids:=7;
    deleteinv(ids);
    dbms_output.put_line('invoice with id '||ids||' deleted');
end;
/
--Create a transaction nested within a stored procedure that inserts a new record in the Customer table
create or replace procedure
insertcus(ids in integer, firstn in varchar, lastn in varchar, compa in varchar, address in varchar, city in varchar, state in varchar, country in varchar, postal in varchar, phone in varchar, fax in varchar, email in varchar, support in integer)
as
begin
    insert into customer values (ids, firstn, lastn, compa, address, city, state, country, postal, phone, fax, email, support);
    commit;
end;
/
declare
ids customer.customerid%type;
firstn customer.firstname%type;
lastn customer.lastname%type;
comp customer.company%type;
addr customer.address%type;
city customer.city%type;
state customer.state%type;
country customer.country%type;
postal customer.postalcode%type;
phone customer.phone%type;
fax customer.fax%type;
email customer.email%type;
support CUSTOMER.SUPPORTREPID%type;
begin
ids:=413;
firstn:='Drew';
lastn:='Brees';
comp := 'Saints';
addr := '313 Winning road';
city := 'New Orleans';
state := 'Louisiana';
country := 'America (Murica)';
postal := '22222';
phone := '746 7564374';
fax := '(818) 654-9034';
email:= 'drewbrees@saints.com';
support:= 8;
INSERTCUS(ids, firstn, lastn, comp, addr, city, state, country, postal, phone, fax, email, support);
end;
/

--6.0 Triggers
--6.1.1 Create an after insert trigger on the employee table fired after a new record is inserted into the table.
create or replace trigger
employeeafterinsert
after insert on employee
for each row
begin
    dbms_output.put_line('run');
    commit;
end;
/
commit;
select * from employee;
insert into employee values (301, 'ocean', 'frank', 'rapper', 4, '09-JAN-97', '08-FEB-17', '456 singing road', 'los angeles', 'CA', 'America','94049','84385839', '0385903905', 'frankocean@money.com'); 

--6.1.2
-- Create an after update trigger on the album table that fires after a row is inserted inthe table
create or replace trigger albumupdate
after update on album
for each row
begin
    DBMS_OUTPUT.PUT_LINE('row updated');
end;
/
commit;
update album set title = 'realmusic' where albumid=4;

--6.1.3 create an after delete trigger on the customer table
create or replace trigger deletecus
after delete on customer
begin
    dbms_output.put_line('deletion successful');
end;
/
commit;
delete from customer where customerid=8;
--7.0
select i.invoiceid  from invoice i
inner join  customer on customer.customerid = i.customerid;
select i.invoiceid , customer.firstname, customer.lastname from invoice i
inner join  customer on customer.customerid = i.customerid;
select c.customerid, c.firstname, c.lastname, i.invoiceid, i.total
from invoice i 
full outer join customer c on c.customerid = i.customerid;
select al.title, a.name 
from album al
right outer join artist a
on al.artistid = a.artistid;
select * FROM artist cross join album order by artist.NAME ASC;
select * from employee e, employee e2 where e.reportsto=e2.reportsto;
select * from employee e
inner join customer c on c.supportrepid = e.employeeid
inner join invoice i on i.customerid = c.customerid
inner join invoiceline inv on inv.invoiceid = i.invoiceid
inner join track t on t.trackid = inv.trackid
inner join playlisttrack p on p.trackid = t.trackid
inner join playlist pl on pl.playlistid = p.playlistid
inner join mediatype m on m.mediatypeid = t.mediatypeid
inner join album a on a.albumid = t.albumid
inner join artist ar on ar.artistid= a.artistid
inner join genre g on g.genreid = t.genreid;
--9.0
rollback;
