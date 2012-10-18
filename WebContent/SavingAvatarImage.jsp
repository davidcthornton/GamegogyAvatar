<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@page import="java.util.*"%>
<%@page import="sun.misc.BASE64Decoder"%>

<%@include file="ConnectToDatabase.jsp" %>
<%			
	Statement updateStatement;	
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