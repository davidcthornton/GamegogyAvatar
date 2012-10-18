<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@page import="java.util.*"%>

<%@page import="blackboard.base.*"%>
<%@page import="blackboard.data.course.*"%> 				<!-- for reading data -->
<%@page import="blackboard.data.user.*"%> 					<!-- for reading data -->
<%@page import="blackboard.persist.*"%> 					<!-- for writing data -->
<%@page import="blackboard.persist.course.*"%> 				<!-- for writing data -->
<%@page import="blackboard.platform.gradebook2.*"%>
<%@page import="blackboard.platform.gradebook2.impl.*"%>
<%@page import="java.util.*"%> 								<!-- for utilities -->
<%@page import="blackboard.platform.plugin.PlugInUtil"%>	<!-- for utilities -->
<%@ taglib uri="/bbData" prefix="bbData"%> 					<!-- for tags -->
<bbData:context id="ctx">  <!-- to allow access to the session variables -->

<%@include file="ConnectToDatabase.jsp" %>
<% 		
	ResultSet rs, rs2;
	Statement stmt, stmt2;
	
	String currentUser = request.getParameter("whichUser");
	String sendBack = "";
	if (currentUser != null) {	
		stmt = connection.createStatement();
		stmt2 = connection.createStatement();
		rs = stmt.executeQuery("SELECT poseID FROM users WHERE userID = " + currentUser);
		rs.next();
		String pose = rs.getString("poseID");
		
		rs = stmt.executeQuery("SELECT images.imageID, images.url, images.level, images.itemID, images.allPoses FROM equipped INNER JOIN images ON equipped.itemID = images.itemID WHERE equipped.userID = " + currentUser + " ORDER BY images.level");
		sendBack = "<script type=\"text/javascript\">clearCanvas();</script><script type=\"text/javascript\">drawImage(\"";
		
		while (rs.next()) {
			if (rs.getString("allPoses").equals("Y")) {
				sendBack += rs.getString("url") + " ";
			}
			else {
				rs2 = stmt2.executeQuery("SELECT * FROM images_poses_link WHERE poseID = " + pose + " AND imageID = " + rs.getString("imageID"));
				while (rs2.next()) {					
					sendBack += rs.getString("url") + " ";
				}
			}
		}
	} //end of if currentUser != null

	sendBack += "\");</script>";
	//sendBack = sendBack.replace("png \"", "png\"");
	connection.close();
	out.print(sendBack);	
%>
</bbData:context>