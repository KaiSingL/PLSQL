create or replace package pck_security as
	procedure setActive(userID varchar2, activeUser boolean);
	
	function login(userID varchar2, pwd varchar2) return BOOLEAN;
	function canRead(userID varchar2, funcID varchar2) return BOOLEAN;
	function canInsert(userID varchar2, funcID varchar2) return boolean;
	function canUpdate(userID varchar2, funcID varchar2) return boolean;
	function canDelete(userID varchar2, funcID varchar2) return boolean;
	function canExecute(userID varchar2, funcID varchar2) return boolean;
	
end pck_security;
/

create or replace package body pck_security as

	function checkUser(userID varchar2) return boolean
	as 
		usr sys_usr%rowtype;
		rolem role_mem%rowtype;
		rol role%rowtype;
	begin
		select * into usr from sys_usr where user_ID=userID;
		if usr.active = 'N' OR usr.expiry_date +1 < sysdate then 
			--DBMS_OUTPUT.PUT_LINE('SYS_USR ACTIVE OR EXPIRY ISSUE');
			return false;
		end if;
		select * into rolem from role_mem where user_ID = userID;
		select * into rol from role where role_ID = rolem.role_ID;
		if rol.active = 'N' then 
			--DBMS_OUTPUT.PUT_LINE('ROLE ACTIVE ISSUE');
			return false;
		else return true;
		end if;
		exception
			when NO_DATA_FOUND then 
			DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
			return false;
	end checkUser;
	
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
	
	
	function login(userID varchar2, pwd varchar2) return BOOLEAN
	as
	usr sys_usr%rowtype;
	begin
		select * into usr from sys_usr where user_ID = userID;
		if usr.password = pwd then 
			if usr.active = 'N' then 
				DBMS_OUTPUT.PUT_LINE('ACCOUNT NOT ACTIVE');
				RETURN FALSE;
			END IF;
			if usr.expiry_date +1< sysdate then
				DBMS_OUTPUT.PUT_LINE('ACCOUNT EXPIRED');
				RETURN FALSE;
			end if;
			if usr.superuser = 'N' then
				if checkUser(userID) then 
					update sys_usr set login_fail = 0 where user_ID=userID; 
					DBMS_OUTPUT.PUT_LINE('LOGIN FAIL RESETED');
					DBMS_OUTPUT.PUT_LINE('NOT SUPER USER, USER ID COMFIRMED');
					return true;
				else 
					DBMS_OUTPUT.PUT_LINE('NOT SUPRE USER, CHECKUSER() NOT VALID');
					return false ;
				end if;
			else 
				DBMS_OUTPUT.PUT_LINE('SUPER USER, ACCESS GRANTED');
				return true;
			end if;
		else
			usr.login_fail := usr.login_fail +1;
			update sys_usr set login_fail = usr.login_fail where user_ID=userID;
			DBMS_OUTPUT.PUT_LINE('LOGIN FAIL, COUNTER +1');
			if usr.login_fail >= 3 and usr.active = 'Y' then 
				update sys_usr set active = 'N' where user_ID=userID;
				DBMS_OUTPUT.PUT_LINE('LOGIN FAIL OVER LIMIT, ACCOUNT DEACTIVATED');
			END IF;
			return false;
		end if;
		exception 
			when NO_DATA_FOUND then 
				DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
				return false;
	end login;
	
function canRead(userID varchar2, funcID varchar2) return BOOLEAN
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
			if NOT checkUser(userID) then
				DBMS_OUTPUT.PUT_LINE('ACCOUNT NOT VALID');
				RETURN FALSE;
			ELSIF func.read = 'Y' then
				DBMS_OUTPUT.PUT_LINE('NORMAL USER READ RIGHT GRANTED');
				return true;
			else 
				DBMS_OUTPUT.PUT_LINE('READ RIGHT NOT GRANTED');
				return false;
			end if;
		end if;
		exception
			when NO_DATA_FOUND then 
			DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
			return FALSE;
	end canRead;
	
	function canInsert(userID varchar2, funcID varchar2) return boolean
	as		usr sys_usr%rowtype;
		func role_func%rowtype;
		role role_mem%rowtype;
	begin
		select * into usr from sys_usr where user_ID = userID;
		if usr.superuser = 'Y' then 
			DBMS_OUTPUT.PUT_LINE('SUPER USER, ACCESS FULL RIGHT');
			return true;
		else		
			select * into func from role_func where func_ID = funcID;
			if NOT checkUser(userID) then
				DBMS_OUTPUT.PUT_LINE('ACCOUNT NOT VALID');
				RETURN FALSE;
			ELSIF func.ins = 'Y' then
				DBMS_OUTPUT.PUT_LINE('NORMAL USER READ RIGHT GRANTED');
				return true;
			else 
				DBMS_OUTPUT.PUT_LINE('READ RIGHT NOT GRANTED');	
				return false;
			end if;
		end if;
		exception
			when NO_DATA_FOUND then 
				DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
				return false; 
	end canInsert;
	
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
			if NOT checkUser(userID) then
				DBMS_OUTPUT.PUT_LINE('ACCOUNT NOT VALID');
				RETURN FALSE;
			ELSIF func.upd = 'Y' then
				return true;
			else return false;
			end if;
		end if;
		exception
			when NO_DATA_FOUND then 
				return FALSE; 
	end canUpdate;
	
	function canDelete(userID varchar2, funcID varchar2) return boolean
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
			if NOT checkUser(userID) then
				DBMS_OUTPUT.PUT_LINE('ACCOUNT NOT VALID');
				RETURN FALSE;
			ELSIF func.del = 'Y' then
				return true;
			else return false;
			end if;
		end if;
		exception
			when NO_DATA_FOUND then 
				return FALSE; 
	end canDelete;
	
function canExecute(userID varchar2, funcID varchar2) return boolean
	as		usr sys_usr%rowtype;
		func role_func%rowtype;
		role role_mem%rowtype;
	begin
		select * into usr from sys_usr where user_ID=userID;
		if usr.superuser = 'Y' then 
			DBMS_OUTPUT.PUT_LINE('SUPER USER, ACCESS FULL RIGHT');
			return true;
		else		
			select * into func from role_func where func_ID = funcID;
			if NOT checkUser(userID) then
				DBMS_OUTPUT.PUT_LINE('ACCOUNT NOT VALID');
				RETURN FALSE;
			ELSIF func.exe = 'Y' then
				DBMS_OUTPUT.PUT_LINE('NORMAL USER READ RIGHT GRANTED');
				return true;
			else 
				DBMS_OUTPUT.PUT_LINE('READ RIGHT NOT GRANTED');
				return false;
			end if;
		end if;
		exception
			when NO_DATA_FOUND then 
				DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
				return FALSE; 
	end canExecute;
	

end pck_security;
/