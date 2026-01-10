<%@ page import="com.usm.bookhub.util.FileManager" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 1. GET CURRENT USER
    String myID = (String) session.getAttribute("userID");
    if (myID == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. GET CHAT PARTNER ID (From URL)
    String chatPartnerID = request.getParameter("withUser");
    String chatPartnerName = "Unknown";

    // 3. FIND WHO WE HAVE CHATTED WITH (Scan messages.txt)
    Set<String> chattedUserIDs = new HashSet<>();
    List<String> msgLines = FileManager.readAllLines(application, "messages.txt");

    for (String line : msgLines) {
        String[] m = line.split("\\|");
        // MsgID|Sender|Receiver|...
        if (m.length >= 3) {
            String sender = m[1];
            String receiver = m[2];

            // If I sent it, add the Receiver to my contacts
            if (sender.equals(myID)) chattedUserIDs.add(receiver);
            // If I received it, add the Sender to my contacts
            if (receiver.equals(myID)) chattedUserIDs.add(sender);
        }
    }

    // 4. READ ALL USERS & FILTER THE LIST
    List<String> allUsersLines = FileManager.readAllLines(application, "users.txt");
    List<String[]> userList = new ArrayList<>();

    for (String line : allUsersLines) {
        String[] parts = line.split("\\|");
        // UserID|Email|Password|FullName...
        if (parts.length >= 4) {
            String uID = parts[0];
            String uName = parts[3];

            // 🛑 FIX 1: Skip the Header line
            if (uID.equalsIgnoreCase("UserID")) continue;

            // 🛑 FIX 2: Skip Myself
            if (uID.equals(myID)) continue;

            // 🛑 FIX 3: Add to list ONLY if:
            //    a) We have chatted before (in chattedUserIDs set)
            //    b) OR we are currently trying to chat with them (in URL)
            if (chattedUserIDs.contains(uID) || uID.equals(chatPartnerID)) {
                userList.add(parts);

                // Grab the name if this is our active partner
                if (uID.equals(chatPartnerID)) {
                    chatPartnerName = uName;
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Chat - USM Reference Book Hub</title>
    <style>
        /* --- EXACT DASHBOARD VARIABLES --- */
        :root { --main-purple: #DDA0DD; --darker-purple: #BA55D3; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0; padding: 0;
            background-color: #ffffff;
            height: 100vh;
            display: flex; flex-direction: column;
            overflow-y: scroll;
        }

        /* HEADER */
        .header { background-color: var(--main-purple); color: white; text-align: center; padding: 30px 20px; position: relative; flex-shrink: 0; }
        .header h1 { margin: 10px 0 0 0; font-size: 32px; font-weight: bold; text-transform: uppercase; letter-spacing: 1px; }
        .logo-placeholder { font-size: 50px; }
        .back-btn { position: absolute; top: 20px; right: 20px; background-color: rgba(255,255,255,0.2); color: white; padding: 8px 15px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 14px; }
        .back-btn:hover { background-color: rgba(255,255,255,0.4); }

        /* CHAT STRIP */
        .chat-strip { background-color: var(--darker-purple); padding: 15px 40px; color: white; font-size: 28px; font-weight: bold; display: flex; align-items: center; gap: 10px; text-transform: uppercase; }

        /* MAIN LAYOUT */
        .chat-container { display: flex; flex: 1; height: 100%; overflow: hidden; }

        /* LEFT SIDEBAR */
        .user-sidebar { width: 300px; border-right: 1px solid #eee; background-color: #fff; overflow-y: auto; }
        .user-item { padding: 20px; font-size: 18px; font-weight: bold; color: #333; border-bottom: 1px solid #f0f0f0; cursor: pointer; transition: 0.2s; text-decoration: none; display: block; }
        .user-item:hover { background-color: #f9f0ff; }
        .user-item.active { background-color: var(--main-purple); color: white; }

        /* RIGHT CHAT AREA */
        .chat-area { flex: 1; background-color: #f4f4f4; display: flex; flex-direction: column; }

        .messages-box { flex: 1; padding: 30px; overflow-y: auto; display: flex; flex-direction: column; gap: 15px; }

        /* MESSAGES */
        .message { max-width: 70%; padding: 15px 20px; border-radius: 20px; font-size: 16px; line-height: 1.4; position: relative; }
        .message.sent { align-self: flex-end; background-color: var(--darker-purple); color: white; border-bottom-right-radius: 2px; }
        .message.received { align-self: flex-start; background-color: white; color: #333; border-bottom-left-radius: 2px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .timestamp { font-size: 11px; opacity: 0.7; margin-top: 5px; text-align: right; display: block;}

        /* INPUT BAR */
        .input-bar { background-color: white; padding: 20px; display: flex; gap: 15px; border-top: 1px solid #ddd; }
        .input-bar input { flex: 1; padding: 15px; border-radius: 30px; border: 1px solid #ccc; font-size: 16px; outline: none; background-color: #f9f9f9; }
        .send-btn { background-color: var(--darker-purple); color: white; border: none; padding: 0 30px; border-radius: 25px; font-size: 16px; font-weight: bold; cursor: pointer; text-transform: uppercase; transition: 0.3s; }
        .send-btn:hover { background-color: #9932CC; transform: scale(1.05); }

        /* EMPTY STATE */
        .empty-state { display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100%; color: #888; text-align: center; padding: 20px; }
    </style>
</head>
<body>

    <div class="header">
        <a href="dashboard.jsp" class="back-btn">Back to Dashboard ➜</a>
        <div class="logo-placeholder">📚</div>
        <h1>USM Reference Book Hub</h1>
    </div>

    <div class="chat-strip">
        <span>💬 CHAT <%= (chatPartnerID != null) ? "- " + chatPartnerName : "" %></span>
    </div>

    <div class="chat-container">

        <div class="user-sidebar">
            <%
                for (String[] u : userList) {
                    String uID = u[0];
                    String uName = u[3];
                    String activeClass = (uID.equals(chatPartnerID)) ? "active" : "";
            %>
                <a href="chat.jsp?withUser=<%= uID %>" class="user-item <%= activeClass %>">
                    <%= uName %>
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
                        // 🟢 FIXED: Read file DIRECTLY from the real path (Bypassing FileManager cache)
                        String realPath = application.getRealPath("/data/messages.txt");
                        java.io.File file = new java.io.File(realPath);
                        boolean hasChat = false;

                        if (file.exists()) {
                            // Read the file fresh every time the page loads
                            java.io.BufferedReader br = new java.io.BufferedReader(new java.io.FileReader(file));
                            String line;
                            while ((line = br.readLine()) != null) {
                                String[] m = line.split("\\|");

                                // Format: MsgID|Sender|Receiver|Text|Time
                                if (m.length >= 5) {
                                    String sender = m[1].trim();   // .trim() removes accidental spaces
                                    String receiver = m[2].trim();
                                    String text = m[3];
                                    String time = m[4];

                                    // CONDITION: Show message if it belongs to this conversation
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
                            br.close(); // Close the reader nicely
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
                    var objDiv = document.getElementById("msgBox");
                    objDiv.scrollTop = objDiv.scrollHeight;
                </script>

            <% } %>
        </div>
    </div>

</body>
</html>