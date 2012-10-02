<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@page import="java.util.*"%>
<%@page import="sun.misc.BASE64Decoder"%>

<%	
	Connection connection = null;	
	Statement updateStatement;	
	try {
		String connectionURL = "jdbc:mysql://127.0.0.1:3306/avatardatabase"; 
		Class.forName("com.mysql.jdbc.Driver").newInstance();		
		connection = DriverManager.getConnection(connectionURL, "root", "Blackboard789");	 
		if(!connection.isClosed()) { 
			//out.println("SavingAvatarImage: successfully connected to MySQL server");
		}			
	} 
	catch(Exception ex){
		out.println("Unable to connect to database, because: " + ex.toString());
	}  
	
	String currentUser = request.getParameter("whichUser");
    String encodedImage = request.getParameter("whichImage");
	
	if (currentUser != null) {
        updateStatement = connection.createStatement();        
        String avatarScreenshotLocation = "AvatarUser" + currentUser + ".png";   
        updateStatement.executeUpdate("UPDATE users SET avatarImg=\"" + avatarScreenshotLocation + "\" WHERE userID=" + currentUser);
	
		encodedImage = encodedImage.substring(encodedImage.indexOf(",") + 1).replace(" ", "+");				
		FileOutputStream outFile = new FileOutputStream(avatarScreenshotLocation);			
		BASE64Decoder decoder = new BASE64Decoder();
		byte[] decodedBytes = decoder.decodeBuffer(encodedImage);	
		
		outFile.write(decodedBytes);
		outFile.close();
		connection.close();	
	}
%>