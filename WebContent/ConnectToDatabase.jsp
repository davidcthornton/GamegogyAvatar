<%@ page import="java.sql.*" %> 
<%@ page import="java.io.*" %> 
<%@page import="java.util.*"%> 						
<%@page import="javax.sql.rowset.CachedRowSet"%> 			
<%@page import="com.sun.rowset.CachedRowSetImpl"%>
<%@page import="java.util.*"%> 							
		
<% 	
	Connection connection = null;
	try {
		String connectionURL = "jdbc:mysql://205.174.62.96:3306/avatardatabase"; 
		Class.forName("com.mysql.jdbc.Driver").newInstance();
		connection = DriverManager.getConnection(connectionURL, "root", "Blackboard789");	 
	                
		if(!connection.isClosed()) { 
			//out.println("Successfully connected to MySQL server");							
		}                   		
	} 
	catch(Exception ex){
		out.println("Unable to connect to database, because: " + ex.toString());
	}	
%>