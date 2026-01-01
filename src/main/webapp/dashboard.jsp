<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- === 1. INSERT JAVA CODE HERE (Security Check) === --%>
<%
    // Check if the user is logged in
    String userName = (String) session.getAttribute("userName");
    String userID = (String) session.getAttribute("userID");

    // If no user is found in the session, kick them back to index.jsp
    if (userName == null || userID == null) {
        response.sendRedirect("index.jsp");
        return;
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

        .profile-buttons {
            display: flex;
            flex-direction: column;
            gap: 10px;
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

            <p><strong>Email:</strong> ali@student.usm.my (Placeholder)</p>
            <p><strong>Phone:</strong> 012-3456789</p>
            <p><strong>Address:</strong> Desasiswa Tekun, USM</p>
            <p><strong>Major:</strong> Computer Science</p>
        </div>

        <div class="profile-buttons">
            <button class="action-btn">Chat 💬</button>
            <button class="action-btn">Edit Profile ✏️</button>
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

</body>
</html>