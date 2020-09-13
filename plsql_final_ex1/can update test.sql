CREATE OR REPLACE 
	function canUpdate(userID varchar2, funcID varchar2) return boolean
	as
			usr sys_usr%rowtype;
		func role_func%rowtype;
		role role_mem%rowtype;
	begin
		select * into usr from sys_usr where user_ID=userID;
		if usr.superuser = 'Y' then 
			DBMS_OUTPUT.PUT_LINE('SUPER USER, ACCESS FULL RIGHT');
			return true;
		else		
			select * into func from role_func where func_ID = funcID;
			if checkUser(userID) and func.upd = 'Y' then
				DBMS_OUTPUT.PUT_LINE('NORMAL USER UPDATE RIGHT GRANTED');
				return true;
			else 
				DBMS_OUTPUT.PUT_LINE('UPDATE RIGHT NOT GRANTED');
				return false;
			end if;
		end if;
		exception
			when NO_DATA_FOUND then 				
				DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
				return FALSE; 
	end canUpdate;
	/