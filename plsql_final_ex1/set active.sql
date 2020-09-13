	create or replace
	procedure setActive(userID varchar2, activeUser boolean)
	as
		usr role_mem%rowtype;
	begin
		select * into usr from role_mem where user_ID = userID;
		if activeUser then			
			update sys_usr set active = 'Y' , login_fail = 0 where user_ID = userID;
			update role set active ='Y' where role_ID = usr.role_ID;
			DBMS_OUTPUT.PUT_LINE('USER '||userID||' activated');
		else 
			update sys_usr set active = 'N' where user_ID = userID;
			update role set active = 'N' where 	ROLE_ID = usr.role_ID;
			DBMS_OUTPUT.PUT_LINE('USER '||userID||' deactivated');
		end if;
	end setActive;
	/