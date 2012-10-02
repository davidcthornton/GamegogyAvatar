<%@ page import="java.sql.*" %> 
<%@ page import="java.io.*" %> 
<%@page import="java.util.*"%>
					
<% 	
	Connection connection = null;
	ResultSet rs, allEquippedSet, dataInventory;
	Statement stmt, stmt2, updateStatement;
	String sendBack = "";
	
	try {
		String connectionURL = "jdbc:mysql://127.0.0.1:3306/avatardatabase"; 
		Class.forName("com.mysql.jdbc.Driver").newInstance();		
		connection = DriverManager.getConnection(connectionURL, "root", "Blackboard789");	 
		if(!connection.isClosed()) { 
			//out.println("UpdatingAvatar: successfully connected to " + "MySQL server using TCP/IP...");
		}
				
	} //end of trying to connect to database
	catch(Exception ex){
		out.println("Unable to connect to database, because: " + ex.toString());
	}
	stmt = connection.createStatement();
	stmt2 = connection.createStatement();
	updateStatement = connection.createStatement();
	
   String currentUser = request.getParameter("whichUser");
   String currentItem = request.getParameter("whichItem");
   
	//Using the item's ID number, the module checks whether the current item is equipped
	rs = stmt.executeQuery("SELECT * FROM equipped WHERE userID=" + currentUser + " AND itemID =" + currentItem);
	if (rs.next()) { // this item is already equipped, so just unequip it
		updateStatement.executeUpdate("DELETE FROM equipped WHERE userID=" + currentUser + " AND itemID=" + currentItem);
	}
	else { // the item is not equipped.  thus, we need to equip it.  but first, let's check for conflicts!
		updateStatement.executeUpdate("delete from equipped where itemID in (select itemID from images where level in (SELECT level FROM images where itemID = " + currentItem + ") and sharesLayer=\"N\" and itemID <> " + currentItem + ")");
		// now check if the current pose is valid. 
		// does there exist an image of the item that agrees with current pose
		
		// first, are there any pose-picky images associated with this item?  
		rs = stmt.executeQuery("select count(*) from images, items where items.itemID = " + currentItem + " and images.itemID = items.itemID and allPoses <> \"Y\"");
		rs.next();		
		if (!rs.getString(1).equals("0")) {  // yes there are pose-picky images for this item
			// let's consider if there are any images that work with this pose (this is assuming items are all one image, not multiple!)
			rs = stmt.executeQuery("select count(*) from images_poses_link where imageID in (select imageID from images, items where items.itemID = " + currentItem + " and images.itemID = items.itemID and allPoses <> \"Y\") and poseID = (SELECT poseID FROM users WHERE userID = " + currentUser + ")" );
			rs.next();
			//out.print("compatible images: " + rs.getString(1));	
			if (rs.getString(1).equals("0")) {  // no compatible images means that we must change the pose
				// find all the compatible poses for this item
				rs = stmt.executeQuery("select distinct poseID from images_poses_link where imageID in (select imageID from images, items where items.itemID = " + currentItem + " and images.itemID = items.itemID and allPoses <> \"Y\") limit 1");
				rs.next();						
				// then, set the pose to the first one (assuming there is at least one)	
				//out.print("UPDATE users SET poseID=" + rs.getString("poseID") + " WHERE userID=" + currentUser);
				updateStatement.executeUpdate("UPDATE users SET poseID=" + rs.getString("poseID") + " WHERE userID=" + currentUser);
			}		
		}		
		// now equip the item
		updateStatement.executeUpdate("insert into equipped (userID, itemID) values (" + currentUser + ", " + currentItem + ")");				
	} //end of attempting to equip item
	
	//Reload avatar display
	sendBack += "<script type=\"text/javascript\">UpdatingAvatar(\"" + currentUser + "\");</script>";
	connection.close();
	out.print(sendBack);
%>