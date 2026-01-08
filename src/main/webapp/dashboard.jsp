<%@ page import="com.usm.bookhub.util.FileManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // 1. Security Check
    String userID = (String) session.getAttribute("userID");
    String userName = (String) session.getAttribute("userName");

    if (userName == null || userID == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. Fetch Full User Details from Text File
    String[] userDetails = FileManager.getUserByID(userID);

    // Default values (prevents "null" errors if file is empty)
    String email = "N/A";
    String phone = "N/A";
    String address = "N/A";
    String major = "N/A";

    // 3. Extract data if found
    // File Format: UserID|Email|Password|FullName|Phone|Address|Major|Role
    if (userDetails != null && userDetails.length >= 7) {
        email = userDetails[1];
        // userDetails[2] is password (skip)
        // userDetails[3] is name (we already have userName)
        phone = userDetails[4];
        address = userDetails[5];
        major = userDetails[6];
    }
%>

<html>
<head>
    <title>BookHub Dashboard</title>
    <style>
        /* --- 1. CSS VARIABLES --- */
        :root {
            --main-purple: #DDA0DD; /* Light Purple */
            --darker-purple: #BA55D3; /* Darker Purple */
            --text-color: #333;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #ffffff;
        }

        /* --- 2. HEADER (Scrolls away) --- */
        .header {
            background-color: var(--main-purple);
            color: white;
            text-align: center;
            padding: 30px 20px;
            position: relative; /* Added for Logout positioning */
        }

        .header h1 {
            margin: 10px 0 0 0;
            font-size: 32px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* Logout Button Style */
        .logout-btn {
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
        .logout-btn:hover { background-color: rgba(255,255,255,0.4); }

        .logo-placeholder { font-size: 50px; }

        /* --- 3. PROFILE SECTION (Scrolls away) --- */
        .profile-container {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            padding: 20px 40px;
            max-width: 1200px;
            margin: 0 auto;
        }

        .profile-info {
            flex: 1;
            text-align: left;
        }

        .profile-info h1 {
            font-size: 36px;
            margin-bottom: 10px;
            text-transform: uppercase;
        }

        .profile-info p {
            font-size: 18px;
            margin: 8px 0;
            color: #444;
            line-height: 1.4;
        }

        .info-row {
            display: flex;
                align-items: flex-start; /* Aligns text to top if it wraps */
                margin: 8px 0;
                font-size: 18px;
                color: #444;
                line-height: 1.4;
            }

        .info-label {
            font-weight: bold;
                min-width: 90px; /* Ensures "Address:" has a fixed width column */
                color: #333;
        }

        .info-value {
            flex: 1; /* Allows the text to wrap within its own column */
        }

        .profile-buttons {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 10px;
            align-items: flex-end;
        }

        /* --- QR CODE BOX --- */
        .qr-section {
            display: flex;
            justify-content: center;
            align-self: center;
            padding: 0 20px
        }

        .qr-box {
            width: 160px;
            height: 160px;
            background-color: #f4f4f4; /* Light Grey */
            border: 3px dashed #ccc;   /* Dashed border looks like "Empty/Upload" */
            border-radius: 25px;       /* Rounded Corners */
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
            color: #888;
            font-weight: bold;
            font-size: 14px;
            padding: 10px;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.05); /* Inner shadow for depth */
        }

        .action-btn {
            background-color: var(--darker-purple);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            text-transform: uppercase;
            text-align: center;
            width: 200px;
            transition: 0.3s;
        }

        .action-btn:hover { background-color: #9932CC; transform: scale(1.02); }

        /* --- 4. THE NEW "STICKY WRAPPER" --- */
        .sticky-wrapper {
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0px 4px 6px rgba(0,0,0,0.1);
        }

        /* TABS */
        .tab-bar {
            background-color: var(--main-purple);
            display: flex;
            width: 100%;
            padding: 0;
            margin: 0;
        }

        .tab-button {
            background-color: transparent;
            border: none;
            outline: none;
            cursor: pointer;
            padding: 20px 0;
            font-size: 18px;
            color: white;
            font-weight: bold;
            flex: 1;
            transition: 0.3s;
            text-align: center;
        }

        .tab-button.active {
            background-color: var(--darker-purple);
            color: white;
        }

        .tab-button:hover { background-color: rgba(255, 255, 255, 0.2); }

        /* SEARCH BAR */
        .search-container {
            background-color: var(--darker-purple);
            padding: 15px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 15px;
            color: white;
            font-weight: bold;
            font-size: 20px;
        }

        .search-input {
            width: 50%;
            padding: 10px;
            border-radius: 5px;
            border: none;
            font-size: 16px;
        }

        /* --- 5. CONTENT AREA --- */
        .content-area {
            text-align: center;
            min-height: 800px;
        }

        .inner-content {
            padding: 40px;
            max-width: 1000px;
            margin: 0 auto;
        }

        .tab-content {
            display: none;
            animation: fadeEffect 0.5s;
        }

        @keyframes fadeEffect { from {opacity: 0;} to {opacity: 1;} }

        /* --- MODAL (POP-UP) STYLES --- */
        .modal {
            display: none; /* Hidden by default */
            position: fixed;
            z-index: 2000; /* Sit on top of everything */
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5); /* Black background with transparency */
        }

        .modal-content {
            background-color: white;
            margin: 10% auto; /* 10% from top, centered */
            padding: 30px;
            border-radius: 15px;
            width: 400px;
            text-align: center;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            position: relative;
        }

        .close-btn {
            position: absolute;
            top: 10px;
            right: 15px;
            font-size: 24px;
            cursor: pointer;
            color: #aaa;
        }
        .close-btn:hover { color: black; }

        /* File Input Styling */
        input[type="file"] {
            margin: 20px 0;
            padding: 10px;
            border: 1px dashed #ccc;
            width: 100%;
            box-sizing: border-box;
        }

    </style>

    <script>
        function openTab(evt, tabName) {
            var i, tabcontent, tablinks;
            tabcontent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabcontent.length; i++) {
                tabcontent[i].style.display = "none";
            }
            tablinks = document.getElementsByClassName("tab-button");
            for (i = 0; i < tablinks.length; i++) {
                tablinks[i].className = tablinks[i].className.replace(" active", "");
            }
            document.getElementById(tabName).style.display = "block";
            evt.currentTarget.className += " active";
        }

        // --- QR MODAL FUNCTIONS ---
        function openQRModal() {
            document.getElementById("qrModal").style.display = "block";
        }

        function closeQRModal() {
            document.getElementById("qrModal").style.display = "none";
        }

        // Close modal if user clicks outside the box
        window.onclick = function(event) {
            var modal = document.getElementById("qrModal");
            if (event.target == modal) {
                modal.style.display = "none";
            }
        }

        function openEditModal() {
            document.getElementById("editModal").style.display = "block";
        }

        function closeEditModal() {
            document.getElementById("editModal").style.display = "none";
        }

    </script>
</head>
<body>

    <div class="header">
        <a href="index.jsp" class="logout-btn">Logout ➜</a>

        <div class="logo-placeholder">📚</div>
        <h1>USM Reference Book Hub</h1>
    </div>

    <div class="profile-container">
        <div class="profile-info">
            <h1>Welcome, <%= userName %></h1>

            <div class="info-row">
                <span class="info-label">Email:</span>
                <span class="info-value"><%= email %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Phone:</span>
                <span class="info-value"><%= phone %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Major:</span>
                <span class="info-value"><%= major %></span>
            </div>
            <div class="info-row">
                <span class="info-label">Address:</span>
                    <span class="info-value"><%= address %></span>
            </div>
        </div>

        <div class="qr-section">
            <%
                // Check if a QR file exists for this user
                // We check standard extensions: jpg, png, jpeg
                String qrPath = null;
                String[] exts = {".jpg", ".jpeg", ".png"};

                // We need the physical path to check existence...
                // But we need the web URL to display it.
                // NOTE: Make sure this physical path matches your FileManager path!
                String basePhysicalPath = "C:/Users/User/Documents/GitHub/USMReferenceBookHub/src/main/webapp/images/profiles/";

                for (String ext : exts) {
                    java.io.File checkFile = new java.io.File(basePhysicalPath + userID + ext);
                    if (checkFile.exists()) {
                        qrPath = "images/profiles/" + userID + ext; // Found it!
                        break;
                    }
                }
            %>

            <% if (qrPath != null) { %>
                <img src="<%= qrPath %>?t=<%= System.currentTimeMillis() %>"
                     style="width: 160px; height: 160px; border-radius: 25px; border: 3px solid #BA55D3; object-fit: cover;">
            <% } else { %>
                <div class="qr-box">
                    No QR Code 📷<br>
                    <span style="font-size:12px; font-weight:normal;">(Please click "Update QR")</span>
                </div>
            <% } %>
        </div>

        <div class="profile-buttons">
            <button class="action-btn" onclick="openAddBookModal()">Add Book 📕</button>
            <button class="action-btn" onclick="openQRModal()">Update QR 📱</button>
            <button class="action-btn">Chat 💬</button>
            <button class="action-btn" onclick="openEditModal()">Edit Profile ✏️</button>
        </div>
    </div>

    <div class="sticky-wrapper">

        <div class="tab-bar">
            <button class="tab-button active" onclick="openTab(event, 'Marketplace')">Marketplace 🛒</button>
            <button class="tab-button" onclick="openTab(event, 'History')">History 📜</button>
            <button class="tab-button" onclick="openTab(event, 'Inventory')">My Inventory 📦</button>
        </div>

        <div class="search-container">
            <span>Search 🔍</span>
            <input type="text" class="search-input" placeholder="Type book name...">
        </div>

    </div>

    <div class="content-area">

        <div id="Marketplace" class="tab-content" style="display: block;">
            <div class="inner-content">
                <h2>🛒 The Marketplace</h2>
                <p>Here you will see a list of books for sale.</p>
                <br>
                <div style="border: 2px dashed #ccc; padding: 40px; color: #aaa; height: 500px;">
                    [ Book List Placeholder ]<br><br>
                    (Scroll down! The Search bar will stay with the Tabs!)
                </div>
            </div>
        </div>

        <div id="History" class="tab-content">
            <div class="inner-content">
                <h2>📜 Order History</h2>
                <p>Here are your past transactions.</p>
                <div style="border: 2px dashed #ccc; padding: 40px; color: #aaa; height: 300px;">
                    [ Order List Placeholder ]
                </div>
            </div>
        </div>

        <div id="Inventory" class="tab-content">
            <div class="inner-content">
                <h2>📦 My Inventory</h2>
                <p>Books you have uploaded to sell.</p>
                <br>
                <button class="action-btn" style="width: auto;">+ Add New Book</button>
            </div>
        </div>

    </div>

    <div id="qrModal" class="modal">
        <div class="modal-content">
            <span class="close-btn" onclick="closeQRModal()">&times;</span>

            <h2>Update QR Code 📱</h2>
            <p>Upload a screenshot of your TNG or DuitNow QR.</p>
            <p>Please make sure the QR has been cropped properly.</p>

            <form action="updateQR" method="post" enctype="multipart/form-data">
                <input type="file" name="qrFile" accept="image/*" required>
                <br>
                <button type="submit" class="action-btn">Upload Now ⬆️</button>
            </form>

        </div>
    </div>

    <div id="editModal" class="modal">
        <div class="modal-content">
            <span class="close-btn" onclick="closeEditModal()">&times;</span>

            <h2>Edit Profile ✏️</h2>

            <form action="editProfile" method="post">
                <div style="text-align: left; margin-bottom: 10px;">
                    <label>Full Name:</label><br>
                    <input type="text" name="fullName" value="<%= userName %>" required style="width:100%; padding: 8px;">
                </div>

                <div style="text-align: left; margin-bottom: 10px;">
                    <label>Phone:</label><br>
                    <input type="text" name="phone" value="<%= phone %>" required style="width:100%; padding: 8px;">
                </div>

                <div style="text-align: left; margin-bottom: 10px;">
                    <label>Major:</label><br>
                    <input type="text" name="major" value="<%= major %>" required style="width:100%; padding: 8px;">
                </div>

                <div style="text-align: left; margin-bottom: 20px;">
                    <label>Address:</label><br>
                    <textarea name="address" rows="3" required style="width:100%; padding: 8px;"><%= address %></textarea>
                </div>

                <button type="submit" class="action-btn">Save Changes 💾</button>
            </form>

        </div>
    </div>

</body>
</html>