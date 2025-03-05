-- Create a user

CREATE user 'robotuser'@'localhost' identified by 'password';

-- create role
create role robotrole;

-- give role right the user
grant robotrole to 'robotuser'@'localhost';

-- set roles to be enabled by default for the user when logging in
set default role all to 'robotuser'@'localhost';

-- Grant permission to a role in the desired database
use rpacourse;
grant select, insert, update on invoiceheader to robotrole;
grant select, insert, update on invoicerow to robotrole;
grant select, insert, update on invoicestatus to robotrole;