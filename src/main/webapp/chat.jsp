<%@ page import="com.usm.bookhub.util.FileManager" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.io.File" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    //logic for getting current user session
    String myID = (String) session.getAttribute("userID");
    if (myID == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    //logic for retrieving chat partner id from url parameter
    String chatPartnerID = request.getParameter("withUser");
    String chatPartnerName = "Unknown";

    //logic for identifying previous chat history
    Set<String> chattedUserIDs = new HashSet<>();
    List<String> msgLines = FileManager.readAllLines(application, "messages.txt");

    for (String line : msgLines) {
        String[] m = line.split("\\|");
        if (m.length >= 3) {
            String sender = m[1];
            String receiver = m[2];
            if (sender.equals(myID)) chattedUserIDs.add(receiver);
            if (receiver.equals(myID)) chattedUserIDs.add(sender);
        }
    }

    //logic for reading and filtering user list for sidebar
    List<String> allUsersLines = FileManager.readAllLines(application, "users.txt");
    List<String[]> userList = new ArrayList<>();

    for (String line : allUsersLines) {
        String[] parts = line.split("\\|");
        if (parts.length >= 4) {
            String uID = parts[0];
            String uName = parts[3];

            if (uID.equalsIgnoreCase("UserID")) continue;
            if (uID.equals(myID)) continue;

            if (chattedUserIDs.contains(uID) || uID.equals(chatPartnerID)) {
                userList.add(parts);
                if (uID.equals(chatPartnerID)) {
                    chatPartnerName = uName;
                }
            }
        }
    }

    //logic for locating partner's qr code image
    String partnerQRPath = null;
    if (chatPartnerID != null) {
        String[] exts = {".jpg", ".jpeg", ".png"};
        for (String ext : exts) {
            String relativePath = "/images/profiles/" + chatPartnerID + ext;
            String realPath = application.getRealPath(relativePath);
            File checkFile = new File(realPath);
            if (checkFile.exists()) {
                partnerQRPath = "images/profiles/" + chatPartnerID + ext;
                break;
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Chat - USM Reference Book Hub</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📚</text></svg>">
    <style>
        /* styling for main theme colors */
        :root {
            --main-purple: #DDA0DD;
            --darker-purple: #BA55D3;
        }

        /* styling for overall page layout */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0; padding: 0;
            background-color: #ffffff;
            height: 100vh;
            display: flex; flex-direction: column;
            overflow-y: scroll;
        }

        /* styling for header container */
        .header {
            background-color: var(--main-purple);
            color: white;
            text-align: center;
            padding: 30px 20px;
            position: relative;
            flex-shrink: 0;
        }

        /* styling for header title text */
        .header h1 {
            margin: 10px 0 0 0;
            font-size: 32px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* styling for logo placeholder */
        .logo-placeholder {
            font-size: 50px;
        }

        /* styling for back button navigation */
        .back-btn {
            position: absolute;
            top: 20px;
            right: 20px;
            background-color: rgba(255,255,255,0.2);
            color: white;
            padding: 8px 15px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            font-size: 14px;
        }

        /* styling for back button hover effect */
        .back-btn:hover {
            background-color: rgba(255,255,255,0.4);
        }

        /* styling for chat info strip container */
        .chat-strip {
            background-color: var(--darker-purple);
            padding: 15px 40px;
            color: white;
            font-size: 28px;
            font-weight: bold;
            display: flex;
            align-items: center;
            justify-content: space-between;
            text-transform: uppercase;
        }

        /* styling for qr code button */
        .qr-btn {
            background-color: white;
            color: var(--darker-purple);
            border: none;
            padding: 8px 15px;
            font-size: 14px;
            font-weight: bold;
            border-radius: 20px;
            cursor: pointer;
            transition: 0.2s;
            text-transform: none;
        }

        /* styling for qr button hover effect */
        .qr-btn:hover {
            background-color: #f0f0f0;
            transform: scale(1.05);
        }

        /* styling for main chat layout container */
        .chat-container {
            display: flex;
            flex: 1;
            height: 100%;
            overflow: hidden;
        }

        /* styling for user list sidebar */
        .user-sidebar {
            width: 300px;
            border-right: 1px solid #eee;
            background-color: #fff;
            overflow-y: auto;
        }

        /* styling for individual user items in sidebar */
        .user-item {
            padding: 20px;
            font-size: 18px;
            font-weight: bold;
            color: #333;
            border-bottom: 1px solid #f0f0f0;
            cursor: pointer;
            transition: 0.2s;
            text-decoration: none;
            display: block;
        }

        /* styling for user item hover effect */
        .user-item:hover {
            background-color: #f9f0ff;
        }

        /* styling for active selected user */
        .user-item.active {
            background-color: var(--main-purple);
            color: white;
        }

        /* styling for right side chat area */
        .chat-area {
            flex: 1;
            background-color: #f4f4f4;
            display: flex;
            flex-direction: column;
        }

        /* styling for message scrollable box */
        .messages-box {
            flex: 1;
            padding: 30px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        /* styling for individual message bubbles */
        .message {
            max-width: 70%;
            padding: 15px 20px;
            border-radius: 20px;
            font-size: 16px;
            line-height: 1.4;
            position: relative;
        }

        /* styling for sent messages */
        .message.sent {
            align-self: flex-end;
            background-color: var(--darker-purple);
            color: white;
            border-bottom-right-radius: 2px;
        }

        /* styling for received messages */
        .message.received {
            align-self: flex-start;
            background-color: white;
            color: #333;
            border-bottom-left-radius: 2px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        /* styling for message timestamp */
        .timestamp {
            font-size: 11px;
            opacity: 0.7;
            margin-top: 5px;
            text-align: right;
            display: block;
        }

        /* styling for input field container */
        .input-bar {
            background-color: white;
            padding: 20px;
            display: flex;
            gap: 15px;
            border-top: 1px solid #ddd;
        }

        /* styling for text input field */
        .input-bar input {
            flex: 1;
            padding: 15px;
            border-radius: 30px;
            border: 1px solid #ccc;
            font-size: 16px;
            outline: none;
            background-color: #f9f9f9;
        }

        /* styling for send button */
        .send-btn {
            background-color: var(--darker-purple);
            color: white;
            border: none;
            padding: 0 30px;
            border-radius: 25px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            text-transform: uppercase;
            transition: 0.3s;
        }

        /* styling for send button hover effect */
        .send-btn:hover {
            background-color: #9932CC;
            transform: scale(1.05);
        }

        /* styling for empty state display */
        .empty-state {
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100%;
            color: #888;
            text-align: center;
            padding: 20px;
        }

        /* styling for modal background overlay */
        .modal {
            display: none;
            position: fixed;
            z-index: 2000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }

        /* styling for modal content box */
        .modal-content {
            background-color: white;
            margin: 10% auto;
            padding: 30px;
            border-radius: 15px;
            width: 350px;
            text-align: center;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            position: relative;
        }

        /* styling for modal close button */
        .close-btn {
            position: absolute;
            top: 10px;
            right: 15px;
            font-size: 24px;
            cursor: pointer;
            color: #aaa;
        }

        /* styling for close button hover effect */
        .close-btn:hover {
            color: black;
        }
    </style>

    <script>
        //function for opening partner qr modal
        function openPartnerQR() {
            document.getElementById("partnerQRModal").style.display = "block";
        }

        //function for closing partner qr modal
        function closePartnerQR() {
            document.getElementById("partnerQRModal").style.display = "none";
        }

        //function for handling outside clicks to close modal
        window.onclick = function(event) {
            var m = document.getElementById("partnerQRModal");
            if (event.target == m) m.style.display = "none";
        }
    </script>
</head>
<body>

    <div class="header">
        <a href="dashboard" class="back-btn">Back to Dashboard ➜</a>
        <div class="logo-placeholder">📚</div>
        <h1>USM Reference Book Hub</h1>
    </div>

    <div class="chat-strip">
        <span>💬 CHAT <%= (chatPartnerID != null) ? "- " + chatPartnerName : "" %></span>

        <% if (chatPartnerID != null) { %>
            <button class="qr-btn" onclick="openPartnerQR()">View Seller QR 📱</button>
        <% } %>
    </div>

    <div class="chat-container">

        <div class="user-sidebar">
            <%
                //logic for iterating through user list
                for (String[] u : userList) {
                    String uID = u[0];
                    String uName = u[3];
                    String activeClass = (uID.equals(chatPartnerID)) ? "active" : "";
            %>
                <a href="chat.jsp?withUser=<%= uID %>" class="user-item <%= activeClass %>">
                    <div><%= uName %></div>
                    <div style="font-size: 13px; font-weight: normal; opacity: 0.7; margin-top: 2px;">
                        User ID: <%= uID %>
                    </div>
                </a>
            <% } %>
        </div>

        <div class="chat-area">
            <% if (chatPartnerID == null) { %>

                <div class="empty-state">
                    <span style="font-size: 60px; margin-bottom: 20px; opacity: 0.5;">💬</span>
                    <h3>Please select a user to continue chat</h3>
                    <p>or start chatting with the book's owner through marketplace</p>
                </div>

            <% } else { %>

                <div class="messages-box" id="msgBox">
                    <%
                        //logic for reading messages from text file
                        String realPath = application.getRealPath("/data/messages.txt");
                        File file = new File(realPath);
                        boolean hasChat = false;

                        if (file.exists()) {
                            java.io.BufferedReader br = new java.io.BufferedReader(new java.io.FileReader(file));
                            String line;
                            while ((line = br.readLine()) != null) {
                                String[] m = line.split("\\|");
                                if (m.length >= 5) {
                                    String sender = m[1].trim();
                                    String receiver = m[2].trim();
                                    String text = m[3];
                                    String time = m[4];

                                    boolean isFromMe = sender.equals(myID);
                                    boolean isToMe = receiver.equals(myID);
                                    boolean isFromHim = sender.equals(chatPartnerID);
                                    boolean isToHim = receiver.equals(chatPartnerID);

                                    if ((isFromMe && isToHim) || (isFromHim && isToMe)) {
                                        hasChat = true;
                                        String bubbleClass = isFromMe ? "sent" : "received";
                    %>
                        <div class="message <%= bubbleClass %>">
                            <%= text %>
                            <span class="timestamp"><%= time %></span>
                        </div>
                    <%
                                    }
                                }
                            }
                            br.close();
                        }
                        if (!hasChat) {
                    %>
                        <p style="text-align:center; color:#ccc; margin-top:20px;">No messages yet. Say hello! 👋</p>
                    <% } %>
                </div>

                <form class="input-bar" action="sendMessage" method="post">
                    <input type="hidden" name="receiverID" value="<%= chatPartnerID %>">
                    <input type="text" name="message" placeholder="Type a message..." required autocomplete="off">
                    <button type="submit" class="send-btn">Send ➤</button>
                </form>

                <script>
                    //logic for auto scrolling to bottom of chat
                    var objDiv = document.getElementById("msgBox");
                    objDiv.scrollTop = objDiv.scrollHeight;
                </script>

            <% } %>
        </div>
    </div>

    <div id="partnerQRModal" class="modal">
        <div class="modal-content">
            <span class="close-btn" onclick="closePartnerQR()">&times;</span>
            <h2>Pay to <%= chatPartnerName %> 💸</h2>
            <p>Scan this DuitNow/TNG QR code</p>

            <% if (partnerQRPath != null) { %>
                <img src="<%= partnerQRPath %>?t=<%= System.currentTimeMillis() %>"
                     style="width: 250px; height: 250px; border-radius: 10px; border: 2px solid #BA55D3; object-fit: cover; margin-bottom: 20px;">
            <% } else { %>
                <div style="width: 250px; height: 250px; background: #eee; margin: 0 auto; display: flex; align-items: center; justify-content: center; border-radius: 10px;">
                    <span style="color: #888;">User has not uploaded a QR code yet.</span>
                </div>
            <% } %>
        </div>
    </div>

</body>
</html>