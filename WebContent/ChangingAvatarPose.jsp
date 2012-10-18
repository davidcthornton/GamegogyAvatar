<%@ page import="java.sql.*" %> 
<%@ page import="java.io.*" %> 
<%@page import="java.util.*"%>
	
<%@include file="ConnectToDatabase.jsp" %>
<% 		
	ResultSet rs;
	Statement updateStatement;
	String sendBack = "";		
	updateStatement = connection.createStatement();	
    String currentUser = request.getParameter("whichUser");
    String currentPose = request.getParameter("whichPose");

	// first, change the pose
	updateStatement.executeUpdate("UPDATE users SET poseID=" + currentPose + " WHERE userID=" + currentUser);
	
	// next, find items that don't like this new pose and unequip them
	
		// compatible images with this pose
		// select imageID from poses, images_poses_link where poses.poseID = images_poses_link.poseID and poses.poseID = 4;
		
		// compatible items with this pose
		// select distinct items.itemID from images, items where items.itemID = images.itemID and imageID in (select imageID from poses, images_poses_link 	where poses.poseID = images_poses_link.poseID 	and poses.poseID = 5) union select distinct items.itemID from images, items where items.itemID = images.itemID and allPoses = "Y";
				
		// delete all incompatible items from equipped
		// delete from equipped where itemID not in (select distinct items.itemID from images, items where items.itemID = images.itemID	and imageID in (select imageID from poses, images_poses_link where poses.poseID = images_poses_link.poseID and poses.poseID = 5) union select distinct items.itemID	from images, items where items.itemID = images.itemID and allPoses = "Y");
			
	updateStatement.executeUpdate("delete from equipped where itemID not in (select distinct items.itemID from images, items where items.itemID = images.itemID	and imageID in (select imageID from poses, images_poses_link where poses.poseID = images_poses_link.poseID and poses.poseID =" + currentPose + ") union select distinct items.itemID from images, items where items.itemID = images.itemID and allPoses = \"Y\")");
	
	//Reload avatar display
	sendBack += "<script type=\"text/javascript\">UpdatingAvatar(\"" + currentUser + "\");</script>";
	connection.close();
	out.print(sendBack);
%>  