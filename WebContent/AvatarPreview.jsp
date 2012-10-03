<%@ page import="java.sql.*" %> 
<%@ page import="java.io.*" %> 
<%@page import="java.util.*"%> 						
<%@page import="javax.sql.rowset.CachedRowSet"%> 			
<%@page import="com.sun.rowset.CachedRowSetImpl"%>

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

<!DOCTYPE HTML>
	<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Avatar Creator</title>
		
        <% 
        	String currentUser = "1"; // dave, this needs to be fixed!
			Connection connection = null;
			ResultSet rs, rs2, rs3;
			CachedRowSet cachedRowSet=new CachedRowSetImpl();
			Statement stmt, stmt2, stmt3;
			   
			try {
				String connectionURL = "jdbc:mysql://127.0.0.1:3306/avatardatabase"; 
				Class.forName("com.mysql.jdbc.Driver").newInstance();
				connection = DriverManager.getConnection(connectionURL, "root", "Blackboard789");	 
                   
				if(!connection.isClosed()) { 
					//out.println("Successfully connected to MySQL server");							
				}                   		
			} 
			catch(Exception ex){
				out.println("Unable to connect to database, because: " + ex.toString());
			}
			// dave, need to shrink this if possible
			stmt = connection.createStatement();
			stmt2 = connection.createStatement();
			stmt3 = connection.createStatement();	
						
			// get the current user
			User sessionUser = ctx.getUser();
			Id courseID = ctx.getCourseId();		
			String sessionUserRole = ctx.getCourseMembership().getRoleAsString();	
			String currentUsername = sessionUser.getUserName();	
			
			// now, if this user doesn't exist in the database, add him
			rs = stmt.executeQuery("SELECT count(*) FROM users where username='" + currentUsername + "'");
			rs.next();		
			if (rs.getString(1).equals("0")) {  // this is a new user, so add them to the database
				out.print("Greetings, " + currentUsername + "!  Please customize your avatar.");
				stmt.executeUpdate("insert into users (username, poseID) values ('" + currentUsername + "', 3)");
				// now, which ID was just added by the autoincrementer?
				rs = stmt.executeQuery("SELECT userID FROM users where username='" + currentUsername + "'");
				rs.next();
				currentUser = rs.getString(1);
				stmt.executeUpdate("insert into equipped (itemID, userID) values (1, " + currentUser + ")");
				stmt.executeUpdate("insert into equipped (itemID, userID) values (11, " + currentUser + ")");
				stmt.executeUpdate("insert into inventory (itemID, userID) values (2, " + currentUser + ")");
				stmt.executeUpdate("insert into inventory (itemID, userID) values (3, " + currentUser + ")");
				stmt.executeUpdate("insert into inventory (itemID, userID) values (4, " + currentUser + ")");
				stmt.executeUpdate("insert into inventory (itemID, userID) values (5, " + currentUser + ")");
				stmt.executeUpdate("insert into inventory (itemID, userID) values (6, " + currentUser + ")");
				stmt.executeUpdate("insert into inventory (itemID, userID) values (7, " + currentUser + ")");
				stmt.executeUpdate("insert into inventory (itemID, userID) values (8, " + currentUser + ")");
				stmt.executeUpdate("insert into inventory (itemID, userID) values (9, " + currentUser + ")");
				stmt.executeUpdate("insert into inventory (itemID, userID) values (10, " + currentUser + ")");				
			} // end of adding new user to database	
			else {  // user is already in the database, so get their ID
				rs = stmt.executeQuery("SELECT userID FROM users where username='" + currentUsername + "'");
				rs.next();
				currentUser = rs.getString(1);
				out.print("Welcome back, " + currentUsername);
			}
			
			
			// dimensions for the avatar canvas
            int height = 450;
            int width = 300;
			
			String styleSheetURL = PlugInUtil.getUri("dt", "avatarblock", "style.css");
		%>
		
		<link rel="stylesheet" type="text/css" href="<%=styleSheetURL%>" />
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
		<script type="text/javascript">
			jQueryAlias = $.noConflict();  //to avoid this webapp conflicting with others on the page        
				
			// Check to see whether the browser is compatible with AJAX.
			var req;

			if(window.XMLHttpRequest){
				//For Firefox, Safari, Opera
				req = new XMLHttpRequest();
			}
			else if(window.ActiveXObject){
				//For IE 5
				req = new ActiveXObject("Microsoft.XMLHTTP");
			} else if(window.ActiveXObject){
				//For IE 6+
				req = new ActiveXObject("Msxml2.XMLHTTP");
			}
			else{
				//Error for an old browser
				alert('Error: Your browser is not compatible with AJAX. Functionality may be restricted.');
			}
			
			//Set up tab functionality for inventory
			jQueryAlias(function() {
				var tabContainers = jQueryAlias('div.tabs > div');
		
				jQueryAlias('div.tabs ul.tabNavigation a').click(function () {
					tabContainers.hide();
					tabContainers.filter(this.hash).show();
					jQueryAlias('div.tabs ul.tabNavigation a').removeClass('selected');
					jQueryAlias(this).addClass('selected');
					return false;
				}).filter(':first').click();
			});
	        
			
			function preloadImages(arr){
				var newimages=[], loadedimages=0
				var postaction=function(){}
				var arr=(typeof arr!="object")? [arr] : arr
				function imageloadpost(){
					loadedimages++
					if (loadedimages==arr.length){
						postaction(newimages) //call postaction and pass in newimages array as parameter
					}
				}
				for (var i=0; i<arr.length; i++){
					newimages[i]=new Image()
					newimages[i].src=arr[i]
					newimages[i].onload=function(){
						imageloadpost()
					}
					newimages[i].onerror=function(){
						imageloadpost()
					}
				}
				return { //return blank object with done() method
					done:function(f){
						postaction=f || postaction //remember user defined callback functions to be called when images load
					}
				}
			} // end of preloadImages			
			
			
			
			<%
				String imagesFolderURL = PlugInUtil.getUri("dt", "avatarblock", "images/");
			%>	
			/*
			function drawImage(imgurl) {
				var imagesToDraw = new Array();
				// This function draws an image to the canvas.
				var canvas = document.getElementById("avatarCanvas");
				var context = canvas.getContext("2d");
				var tempImg;
				var numLoadedImages = 0;				
				// check to see whether the image is the last or only one to be drawn by looking for spaces in imgurl.
				while (/\s/g.test(imgurl)) {
					tempImg = new Image();
					// this is not the last image
					thisurl = imgurl.split(" ",1)[0];
					imgurl = imgurl.split(/[" "](.+)?/)[1];					
					tempImg.src = "<%=imagesFolderURL%>" + thisurl;
					imagesToDraw.push(tempImg);	
					
					tempImg.onload = function() {					
						numLoadedImages++;
					}					
				}				
				// out of loop, this is the last image
				tempImg = new Image();
				tempImg.src = "<%=imagesFolderURL%>" + thisurl;			
				imagesToDraw.push(tempImg);
				// make sure everything is loaded, then draw
				preloadImages(imagesToDraw).done(function(images){
					for(var i=0; i<imagesToDraw.length; i++) {
						context.drawImage(imagesToDraw[i], 0, 0, canvas.width, canvas.height);
					}
				})				
			} // end of drawImage
			*/
			
			function drawImage(imgurl) {
				// This function draws an image to the canvas.
				var canvas = document.getElementById("avatarCanvas");
				var context = canvas.getContext("2d");
				var tempImg = new Image();
				// Check to see whether the image is the last or only one to be drawn by looking for spaces in imgurl.
				if (/\s/g.test(imgurl)) {
					//This is not the last image. Call the function again to draw the next one.
					thisurl = imgurl.split(" ",1)[0];
					imgurl = imgurl.split(/[" "](.+)?/)[1];
					
					tempImg.src = "<%=imagesFolderURL%>" + thisurl;
					tempImg.onload = function() {
						context.drawImage(tempImg, 0, 0, canvas.width, canvas.height);
						drawImage(imgurl);
					}
				}
				else {
					//This is the last image.
                    tempImg.src = "<%=imagesFolderURL%>" + thisurl;
					tempImg.onload = function() {
						context.drawImage(tempImg, 0, 0, canvas.width, canvas.height);
					}
				}
			} // end of drawImage
				
			function clearCanvas() {
				// This function clears the canvas completely to prepare it for redrawing.
				var canvas = document.getElementById("avatarCanvas");
				var context = canvas.getContext("2d");
				context.clearRect(0,0, canvas.width, canvas.height);
			}
				
			<%
				String changingAvatarItemURL = PlugInUtil.getUri("dt", "avatarblock", "ChangingAvatarItem.jsp");
			%>
			function clickItem(whichItem, whichUser) {
				// This function calls "ChangingAvatarItem.php" to equip or unequip avatar items.
				var url = "<%=changingAvatarItemURL%>?whichItem=" + whichItem + "&whichUser=" + whichUser;
				req.open("GET", url, true);
				req.onreadystatechange = handleResponse;
				req.send(null);
			}

			<%
				String changingAvatarPoseURL = PlugInUtil.getUri("dt", "avatarblock", "ChangingAvatarPose.jsp");
			%>
			function clickPose(whichPose, whichUser) {
				// This function calls "ChangingAvatarPose.php" to change the avatar's pose.
				var url = "<%=changingAvatarPoseURL%>?whichPose=" + whichPose +"&whichUser=" + whichUser;
				req.open("GET", url, true);
				req.onreadystatechange = handleResponse;
				req.send(null);
			}
				
			function handleResponse() {
				// This function handles responses from PHP pages.
				if(req.readyState == 4 && req.status == 200) {
					// Retrieving text from the PHP script
					var response = req.responseText;
					if(response){
						parseScript(response);
					}
				}
			}	
				
			function parseScript(strcode) {
				// This function creates an array that contains the Javascript code of every <script> tag.
				// It applies eval() to each script to execute its code.
				var scripts = new Array();
  
				// Remove the script tags and retrieve the javascript code.
				while(strcode.indexOf("<script") > -1 || strcode.indexOf("<\/script") > -1) {
					var s = strcode.indexOf("<script");
					var s_e = strcode.indexOf(">", s);
					var e = strcode.indexOf("<\/script", s);
					var e_e = strcode.indexOf(">", e);
    
					// Add the scripts to the array.
					scripts.push(strcode.substring(s_e+1, e));
					// Remove the scripts from strcode.
					strcode = strcode.substring(0, s) + strcode.substring(e_e+1);
				}
  
				// Loop through every script collected and evaluate it.
				for(var i=0; i<scripts.length; i++) {
					try {
					eval(scripts[i]);
					}
					catch(ex) {
						alert("Javascript Error: The script could not be parsed.");
						alert(scripts[i]);
					}
				}
			} // end of parseScript
				
			function ShowPoseOptions() {
				// This function displays or hides the avatar pose options.
				var poseList = document.getElementById('posesList');
				if (poseList.style.display == "none") {
					// The poses are currently hidden; display them.
					poseList.style.display = "block";
					document.getElementById("posesButton").innerHTML = "Hide Pose Options";
				}
				else {
					// The poses are currently displayed; hide them.
					poseList.style.display = "none";
					document.getElementById("posesButton").innerHTML = "Show Pose Options";
				}
			} // end of showPoseOptions
				
			function showDropList(whichList) {
			// This function displays the list of useable poses for items that have more than one pose.
				var listName = "dropList" + whichList;
				var theList = document.getElementById(listName);
				theList.style.display = "block";
			}
				
			function hideDropList(whichList) {
				// This function hides the list of useable poses for items that have more than one pose.
				var listName = "dropList" + whichList;
				var theList = document.getElementById(listName);
				theList.style.display = "none";
			}
				
			<%
				String updatingAvatarURL = PlugInUtil.getUri("dt", "avatarblock", "UpdatingAvatar.jsp");
			%>
			function UpdatingAvatar(whichUser) {
				// This function calls "UpdatingAvatar.php" to refresh the avatar preview.
				//alert("Updating Avatar");
				try {
					var tempurl = "<%=updatingAvatarURL%>?whichUser=" + whichUser;
					req.open("GET", tempurl, true);
					req.onreadystatechange = handleResponse;
					req.send(null);
				}
				catch (err) {
					alert("An unexpected error occurred; the avatar could not be updated.");
				}
			} // end of UpdatingAvatar
				
			function SaveAvatarImage(whichUser) {
				// This function calls "SavingAvatarImage.php" to save an image of the avatar.
				var canvas = document.getElementById("avatarCanvas");
				var img = canvas.toDataURL("image/png");
				//window.open(img, "toDataURL() image", "width=<%=width%>, height=<%=height%>");
				window.open(img, "blah", "width=<%=width+30%>, height=<%=height+30%>");
				/*
				
				var url = "SavingAvatarImage.jsp";
				try {
					img = "whichUser=" + whichUser + "&whichImage=" + img ;					
					req.open("POST", url, true);
					req.onreadystatechange = handleResponse;
					req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");					
					req.send(img);
				}
				catch (e) {
					document.getElementById("changeMessage").innerHTML="An error occurred; the new avatar was not saved.";
				}*/				
			} // end of SaveAvatarImage
		</script>					
			
	<%                    
		int poseIndex = 0;
		String makeButton = "";
	%>			
	</head>
	<body>
	<div id="CanvasDiv">
		<canvas id="avatarCanvas" name="avatarCanvas" width="<%=width%>px" height="<%=height%>px" ></canvas>
	</div>
	<div class="messageDiv">
		<p id="changeMessage"></p>
	</div>
		

		<div class="saveDiv">
			<%
				// Creates a button for calling the SaveAvatarImage function.
				out.print("<button title=\"Save Avatar\" class=\"saveClick\" onClick=\"SaveAvatarImage('" + currentUser + "');\" id=\"saveButton\">Save Avatar</button>");
			%>
		</div>
		
		<div class="tabs">
			<ul class="tabNavigation">
				<%
					// Creates tabs for the inventory division.
					rs = stmt.executeQuery("SELECT name FROM categories");
					cachedRowSet.populate(rs);
					while (cachedRowSet.next()) {				
						String makeCategoryTab = "<li class=\"noselect\"><a href=\"#" + cachedRowSet.getString("name") + "\">" + cachedRowSet.getString("name") + "</a></li>";
						out.print(makeCategoryTab);
					}
					cachedRowSet.beforeFirst();
				%>
			</ul>
			
			<br/>
				<%
					// Creates buttons for each item in the inventory tab.
					while (cachedRowSet.next()) {					
						String makeCategoryDiv = "<div id=\"" + cachedRowSet.getString("name") + "\" class=\"boxes\">";
						out.print(makeCategoryDiv);
						
						rs = stmt.executeQuery("SELECT items.itemID, items.name, items.thumbnail FROM items INNER JOIN inventory ON items.itemID = inventory.itemID INNER JOIN categories ON items.categoryID = categories.categoryID WHERE inventory.userID = " + currentUser + " AND categories.name = '" + cachedRowSet.getString("name") + "'");				
						while (rs.next()) {
							//An array to keep track of different compatible poses. Must be cleared each time.
							List<String> poseList = new ArrayList<String>();
							String tempList = "";					
						
							//Check whether some images are only relevant to current poses.
							rs2 = stmt3.executeQuery("SELECT images_poses_link.poseID, poses.poseImg FROM images INNER JOIN images_poses_link ON images.imageID = images_poses_link.imageID INNER JOIN poses ON images_poses_link.poseID = poses.poseID WHERE images.itemID = " + rs.getString("itemID") + " AND images.allPoses = 'N'");				
							while (rs2.next()) {
								if (!poseList.contains(rs2.getString("poseID"))) {									
									poseList.add(rs2.getString("poseID"));
								}					
							}
							if (poseList.size() > 1) {
								Iterator<String> it = poseList.iterator();
						        while(it.hasNext()) {
						          	String value=(String)it.next();					        
						          	rs3 = stmt2.executeQuery("SELECT poseImg FROM poses WHERE poseID=" + value);
						          	rs3.next();
						          	String poseImg = rs3.getString("poseImg");
									tempList = tempList + "<li onClick=\"clickPose('" + value + "', '" + currentUser + "')\"><img src=\"" + imagesFolderURL + poseImg + "\" /></img></li>";

								}
								//End check and make button.
								makeButton = "<button title=\"" + rs.getString("name") + "\" class=\"icon\" onClick=\"clickItem('" + rs.getString("itemID") + "', '" + currentUser + "')\" onmouseover=\"showDropList('" + rs.getString("itemID") + "')\"><img src=\"" + imagesFolderURL + rs.getString("thumbnail") + "\" /></button><ul id='dropList" + rs.getString("itemID") + "' class='dropListClass' >" + tempList + "</ul>  <script>jQueryAlias(\"#dropList" + rs.getString("itemID") + "\").mouseleave(function(){hideDropList('" + rs.getString("itemID") + "')})</script>";
							}
							else {
								makeButton = "<button title=\"" + rs.getString("name") + "\" class=\"icon\" onClick=\"clickItem('" + rs.getString("itemID") + "', '" + currentUser + "')\"><img src=\"" + imagesFolderURL + rs.getString("thumbnail") + "\" /></button>";
							}
							
							out.print(makeButton);
						}
						out.print("</div>");
					}
					//connection.close();	
				%>		
				
		</div>
		<button title="Select Pose" class="posesClick" onclick="ShowPoseOptions();" id="posesButton">Hide Pose Options</button>
		<div class="posesDiv" id="posesList">
			<%
				// Creates buttons for all avatar pose options.
				
				// dave, just temporarily limiting the poses as an experiment
				rs = stmt.executeQuery("SELECT * FROM poses where poseID in (3, 4, 6, 7, 8)");
				//rs = stmt.executeQuery("SELECT * FROM poses");
				
				String poseScript = "";
				int i = 0;
				while (rs.next()) {
					makeButton = "<button title=\"" + rs.getString("description") + "\" class=\"icon\" onClick=\"clickPose('" + rs.getString("poseID") + "', '" + currentUser + "')\"><img src=\"" + imagesFolderURL + rs.getString("poseImg") + "\" /></button>";
					out.print(makeButton);
				}	
			%>			
		</div>
	
		<div id="ajax_div">
		</div>
		<script type="text/javascript">  UpdatingAvatar("<%=currentUser%>"); </script>
	</body>
</html>
</bbData:context>