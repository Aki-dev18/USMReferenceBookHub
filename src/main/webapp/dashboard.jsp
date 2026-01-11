<%@ page import="com.usm.bookhub.util.FileManager" %>
<%@ page import="java.io.File" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    // 1. Security Check
    String userID = (String) session.getAttribute("userID");
    String userName = (String) session.getAttribute("userName");

    if (userName == null || userID == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. Fetch Full User Details
    // 🟢 FIXED: We pass 'application' (which is the JSP word for ServletContext)
    String[] userDetails = FileManager.getUserByID(application, userID);

    // Default values
    String email = "N/A";
    String phone = "N/A";
    String address = "N/A";
    String major = "N/A";

    // 3. Extract data if found
    if (userDetails != null && userDetails.length >= 7) {
        email = userDetails[1];
        phone = userDetails[4];
        address = userDetails[5];
        major = userDetails[6];
    }
%>

<html>
<head>
    <title>BookHub Dashboard</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📚</text></svg>">
    <style>
        /* --- 1. CSS VARIABLES --- */
        :root {
            --main-purple: #DDA0DD;
            --darker-purple: #BA55D3;
            --text-color: #333;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #ffffff;
        }

        /* --- 2. HEADER --- */
        .header {
            background-color: var(--main-purple);
            color: white;
            text-align: center;
            padding: 30px 20px;
            position: relative;
        }

        .header h1 {
            margin: 10px 0 0 0;
            font-size: 32px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

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

        /* --- 3. PROFILE SECTION --- */
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

        .info-row {
            display: flex;
            align-items: flex-start;
            margin: 8px 0;
            font-size: 18px;
            color: #444;
            line-height: 1.4;
        }

        .info-label {
            font-weight: bold;
            min-width: 90px;
            color: #333;
        }

        .info-value { flex: 1; }

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
            background-color: #f4f4f4;
            border: 3px dashed #ccc;
            border-radius: 25px;
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
            color: #888;
            font-weight: bold;
            font-size: 14px;
            padding: 10px;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.05);
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

        /* --- 4. TABS & STICKY WRAPPER --- */
        .sticky-wrapper {
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0px 4px 6px rgba(0,0,0,0.1);
        }

        .tab-bar {
            background-color: var(--main-purple);
            display: flex;
            width: 100%;
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

        /* --- MODAL STYLES --- */
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

        .modal-content {
            background-color: white;
            margin: 10% auto;
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

        input[type="file"] {
            margin: 20px 0;
            padding: 10px;
            border: 1px dashed #ccc;
            width: 100%;
            box-sizing: border-box;
        }

        /* Container to give some breathing room */
        .inventory-container {
            padding: 20px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-top: 20px;
        }

        /* The Table Style */
        .modern-table {
            width: 100%;
            border-collapse: collapse; /* Removes the double lines */
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .modern-table th {
            background-color: #a25ccf; /* Matches your purple theme */
            color: white;
            padding: 12px;
            text-align: left;
            text-transform: uppercase;
            font-size: 0.85rem;
            letter-spacing: 1px;
        }

        .modern-table td {
            padding: 15px 12px;
            border-bottom: 1px solid #eee;
            color: #444;
        }

        /* Hover effect to make it feel interactive */
        .modern-table tbody tr:hover {
            background-color: #f9f0ff;
        }

        .book-title {
            font-weight: bold;
            color: #333;
        }

        .book-price {
            color: #a25ccf;
            font-weight: 600;
        }

        /* Status Badge */
        .status-tag {
            background: #d4edda;
            color: #155724;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: bold;
        }

        .empty-msg {
            text-align: center;
            padding: 30px;
            color: #888;}

        .btn-delete {
            background-color: #ff5e62;
            color: white;
            border: none;
            padding: 5px 12px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.8rem;
            transition: background 0.3s ease;
        }

        .btn-delete:hover {
            background-color: #d4145a; /* Darker pink/red on hover */
        }

        /* Adjusting the tag color if it's "Sold" vs "Available" */
        .status-tag {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: bold;
            background: #e0e0e0;
        }
        /* Marketplace Section*/
                /* Container for the books */
                .book-grid {
                    display: grid;
                    /* This magic line makes them side-by-side and wrap automatically */
                    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                    gap: 20px; /* Space between the cards */
                    padding: 20px 0;
                }

                /* Styling for individual cards to make them look uniform */
                .book-card {
                    background: white;
                    border: 1px solid #ddd;
                    border-radius: 8px;
                    padding: 15px;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                    display: flex;
                    flex-direction: column; /* Stacks image, title, price vertically inside the card */
                    transition: transform 0.2s;
                }

                .book-card:hover {
                    transform: translateY(-5px); /* Nice little lift effect on hover */
                    box-shadow: 0 5px 15px rgba(0,0,0,0.2);
                }

                     .book-title {
                         font-size: 16px;
                         font-weight: bold;
                         margin: 10px 0;
                         color: #333;
                         white-space: nowrap;
                         overflow: hidden;
                         text-overflow: ellipsis; /* Adds "..." if title is too long */
                     }

                     .book-price {
                         color: #27ae60;
                         font-weight: bold;
                         font-size: 18px;
                         margin-bottom: 10px;
                     }

        /*----------------------HISTORY CLASSES SECTION BEGINNING----------------------*/
        /* Main wrapper for the history section*/
        .history-container {
            display: flex;
            gap: 20px;
            text-align: left;
        }
        /*Sub-container to contain each purchase history and renting history*/
        .history-box {
            flex: 1;
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        /*Class to style the header title of each sub-container*/
        .history-box h3 {
            border-bottom: 2px solid var(--main-purple);
            padding-bottom: 10px;
            margin-top: 0;
            color: var(--darker-purple);
        }
        /*Class to stylize items inside each sub-container*/
        .history-item {
            background: white;
            border: 1px solid #eee;
            padding: 10px;
            margin-bottom: 10px;
            border-radius: 5px;
            font-size: 14px;
        }
        /*To stylize the date and transaction*/
        .record-and-date {
            font-size: 12px;
            color: #888;
            float: right;
        }
        /*----------------------HISTORY CLASSES SECTION END----------------------*/
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

        function openQRModal() { document.getElementById("qrModal").style.display = "block"; }
        function closeQRModal() { document.getElementById("qrModal").style.display = "none"; }

        function openEditModal() { document.getElementById("editModal").style.display = "block"; }
        function closeEditModal() { document.getElementById("editModal").style.display = "none"; }

        window.onclick = function(event) {
            var m1 = document.getElementById("qrModal");
            var m2 = document.getElementById("editModal");
            if (event.target == m1) m1.style.display = "none";
            if (event.target == m2) m2.style.display = "none";
        }

        function openAddBookModal() { document.getElementById("addBookModal").style.display = "block"; }
        function closeAddBookModal() { document.getElementById("addBookModal").style.display = "none"; }

        function handleStatusChange(selectElement, bookId) {
            const status = selectElement.value;
            const customerIdInput = document.getElementById('customerId_' + bookId);

            // Create or find a hidden input for returnDate
            let returnDateInput = document.getElementById('returnDate_' + bookId);
            if (!returnDateInput) {
                returnDateInput = document.createElement('input');
                returnDateInput.type = 'hidden';
                returnDateInput.name = 'returnDate';
                returnDateInput.id = 'returnDate_' + bookId;
                document.getElementById('statusForm_' + bookId).appendChild(returnDateInput);
            }

            if (status === "Rented" || status === "Purchased") {
                const customerId = prompt("Please enter the Customer ID for this transaction:");
                if (customerId === null || customerId.trim() === "") {
                    alert("Customer ID is required!");
                    selectElement.value = "Available";
                    return;
                }
                customerIdInput.value = customerId;

                // NEW: Ask for Return Date ONLY if Rented
                if (status === "Rented") {
                    const rDate = prompt("Enter Expected Return Date (YYYY-MM-DD):", "2026-01-17");
                    returnDateInput.value = (rDate && rDate.trim() !== "") ? rDate : "N/A";
                } else {
                    returnDateInput.value = "N/A";
                }
            }

            document.getElementById('statusForm_' + bookId).submit();
        }

        function openEditBookModal(id, title, sale, rent) {
            document.getElementById("editBookId").value = id;
            document.getElementById("editTitle").value = title;
            document.getElementById("editSalePrice").value = sale;
            document.getElementById("editRentPrice").value = rent;
            document.getElementById("editBookModal").style.display = "block";
        }

        function closeEditBookModal() {
            document.getElementById("editBookModal").style.display = "none";
        }

        // Update your existing window.onclick to handle closing the new modal
        const originalOnClick = window.onclick;
        window.onclick = function(event) {
            if (originalOnClick) originalOnClick(event);
            var mEdit = document.getElementById("editBookModal");
            if (event.target == mEdit) mEdit.style.display = "none";
        }

        // 🟢 UPDATED: SEARCH BOTH MARKETPLACE (CARDS) AND INVENTORY (TABLE)
        function searchBooks() {
            var input = document.getElementById("searchInput");
            var filter = input.value.toUpperCase();

            // --- 1. SEARCH MARKETPLACE (CARDS) ---
            var cards = document.getElementsByClassName("book-card");
            for (var i = 0; i < cards.length; i++) {
                var titleElement = cards[i].getElementsByClassName("book-title")[0];
                if (titleElement) {
                    var txtValue = titleElement.textContent || titleElement.innerText;
                    if (txtValue.toUpperCase().indexOf(filter) > -1) {
                        cards[i].style.display = "";
                    } else {
                        cards[i].style.display = "none";
                    }
                }
            }

            // --- 3. SEARCH HISTORY (ITEMS) ---
            var historyItems = document.getElementsByClassName("history-item");
            for (var k = 0; k < historyItems.length; k++) {
                // In your code, the Title is inside the <strong> tag
                var titleStrong = historyItems[k].getElementsByTagName("strong")[0];

                if (titleStrong) {
                    var txtValue = titleStrong.textContent || titleStrong.innerText;
                    historyItems[k].style.display = (txtValue.toUpperCase().indexOf(filter) > -1) ? "block" : "none";
                }
            }

            // --- 3. SEARCH INVENTORY (TABLE ROWS) ---
            // Find the table and get all rows inside the body
            var table = document.querySelector(".modern-table tbody");
            if (table) {
                var rows = table.getElementsByTagName("tr");

                for (var j = 0; j < rows.length; j++) {
                    // Look for the cell with class "book-title"
                    var titleCell = rows[j].getElementsByClassName("book-title")[0];

                    if (titleCell) {
                        var txtValue = titleCell.textContent || titleCell.innerText;
                        if (txtValue.toUpperCase().indexOf(filter) > -1) {
                            rows[j].style.display = "";
                        } else {
                            rows[j].style.display = "none";
                        }
                    }
                }
            }
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
                <span class="info-label">User ID:</span>
                <span class="info-value"><%= userID %></span>
            </div>

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
                String qrPath = null;
                String[] exts = {".jpg", ".jpeg", ".png"};

                // 🟢 FIXED: NO MORE HARDCODED PATHS!
                // We ask 'application.getRealPath' to find the folder on ANY computer.
                for (String ext : exts) {
                    String relativePath = "/images/profiles/" + userID + ext;
                    String realPath = application.getRealPath(relativePath);

                    File checkFile = new File(realPath);
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
            <button class="action-btn" onclick="location.href='chat.jsp'">Chat 💬</button>
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
            <input type="text" id="searchInput" class="search-input" placeholder="Type book name..." onkeyup="searchBooks()">
        </div>
    </div>


    <div class="content-area">
            <%-- -------------------------------------MARKETPLACE SECTION------------------------------------------ --%>
            <div id="Marketplace" class="tab-content" style="display: block;">
                <div class="inner-content">
                    <h2>🛒 The Marketplace</h2>
                    <p>
                        <c:choose>
                            <c:when test="${bookList == null}">
                                The Servlet did not run (bookList is NULL). You bypassed the controller.
                            </c:when>
                            <c:when test="${empty bookList}">
                                The Servlet ran, but found 0 books (bookList is EMPTY). Check books.txt path or format.
                            </c:when>
                            <c:otherwise>
                                Success! Found ${bookList.size()} books.
                            </c:otherwise>
                        </c:choose>
                    </p>
                    <p>Here you will see a list of books for sale.</p>
                    <div class="book-grid">
                        <c:forEach items="${bookList}" var="book">
                            <div class="book-card">
                                <div style="height: 120px; background: #f0f0f0; margin-bottom: 10px; display: flex; align-items: center; justify-content: center; color: #aaa;">
                                    <img
                                        src="${pageContext.request.contextPath}/images/books/${book.bookID}.jpg"
                                        alt="${book.title}"
                                        style="width: 100%; height: 150px; object-fit: cover; border-radius: 4px; margin-bottom: 10px;"
                                        onerror="
                                                if (this.src.endsWith('.jpg')) {
                                                    this.src = '${pageContext.request.contextPath}/images/books/${book.bookID}.png';
                                                }
                                                // 2. If .png fails, try .jpeg
                                                else if (this.src.endsWith('.png')) {
                                                    this.src = '${pageContext.request.contextPath}/images/books/${book.bookID}.jpeg';
                                                }
                                                // 3. If everything fails, hide the image and show the fallback div
                                                else {
                                                    this.style.display='none';
                                                    this.nextElementSibling.style.display='flex';
                                                }"
                                    />
                                </div>
                                <div class="book-title" title="${book.title}">${book.title}</div>
                                <div class="book-buyPrice">
                                    Buy: RM <fmt:formatNumber value="${book.salePrice}" type="number" minFractionDigits="2" maxFractionDigits="2" />
                                </div>
                                <div class="book-rentPrice">
                                    Rent: RM <fmt:formatNumber value="${book.rentPrice}" type="number" minFractionDigits="2" maxFractionDigits="2" />
                                </div>
                                <c:if test="${book.userID != sessionScope.userID}">
                                    <button class="action-btn"
                                            style="width: 100%; padding: 10px; margin-top: 10px; font-size: 14px;"
                                            onclick="location.href='chat.jsp?withUser=${book.userID}'">
                                        Chat with Seller 💬
                                    </button>
                                </c:if>

                                <c:if test="${book.userID == sessionScope.userID}">
                                    <div style="margin-top: 10px; padding: 10px; background: #eee; border-radius: 20px; color: #555; font-size: 14px; text-align: center;">
                                        👤 You own this book
                                    </div>
                                </c:if>
                            </div>
                        </c:forEach>
                        <c:if test="${empty bookList}">
                            <p style="grid-column: 1/-1; text-align: center; color: #777;">
                                No books available at the moment.
                            </p>
                        </c:if>
                    </div>
                </div>
            </div>

            <%-- -------------------------------------HISTORY SECTION------------------------------------------ --%>
            <div id="History" class="tab-content">
                <div class="inner-content">
                    <h2>📜 Order History</h2>
                    <p>Here are your past transactions.</p>
                    <%
                        java.util.List<String[]> myPurchases = new java.util.ArrayList<>();
                        java.util.List<String[]> myRents = new java.util.ArrayList<>();

                        java.util.List<String> allOrders = FileManager.readAllLines(application, "record.txt");

                        for (String line: allOrders) {
                            String[] parts = line.split("\\|");
                            if (parts.length >= 7) {
                                String transactionID = parts[0];
                                String orderBookTitle = parts[1];
                                String buyerID = parts[2];
                                String sellerID = parts[3];
                                String type = parts[4];
                                String price = parts[5];
                                String date = parts[6];

                                if (buyerID.equals(userID)) {
                                    String sellerName = "Unknown";
                                    String []sellerInfo = FileManager.getUserByID(application, sellerID);

                                    if (sellerInfo != null) sellerName = sellerInfo[3];

                                    String[] displayData = {orderBookTitle, sellerName, price, date, transactionID};

                                    if (type.equalsIgnoreCase("Purchase")){
                                        myPurchases.add(displayData);
                                    }else if (type.equalsIgnoreCase("Rent")){
                                        myRents.add(displayData);
                                    }
                                }
                            }
                        }
                    %>

                    <div class="history-container">
                        <div class="history-box">
                            <h3>Purchase History</h3>
                            <% if (myPurchases.isEmpty()) { %>
                            <p style="color:#aaa; text-align:center;">No purchases yet.</p>
                            <% } else{
                                for (String[] item : myPurchases) { %>
                            <div class="history-item">
                                <div class="record-and-date" style="text-align: right;">
                                    <span style="display: block; font-weight: bold; color: var(--darker-purple); margin-bottom: 2px;">#<%= item[4] %></span>
                                    <span><%= item[3] %></span>
                                </div>
                                <strong><%= item[0] %></strong><br>
                                Seller: <%= item[1] %><br>
                                <span style="color: green; font-weight: bold;"> RM <%= item[2]%></span>
                            </div>
                            <% }
                            } %>
                        </div>

                        <div class="history-box">
                            <h3>Renting History</h3>
                            <% if (myRents.isEmpty()) { %>
                            <p style="color:#aaa; text-align:center;">No rentals yet.</p>
                            <% } else {
                                for (String[] item : myRents) { %>
                            <div class="history-item">
                                <div class="record-and-date" style="text-align: right;">
                                    <span style="display: block; font-weight: bold; color: var(--darker-purple); margin-bottom: 2px;">#<%= item[4] %></span>
                                    <span><%= item[3] %></span>
                                </div>
                                <strong><%= item[0] %></strong><br>
                                Renter: <%= item[1] %><br>
                                <span style="color: orange; font-weight: bold;">RM <%= item[2] %></span>
                            </div>
                            <%  }
                            } %>
                        </div>
                    </div>
                </div>
            </div>

        <%-- -------------------------------------INVENTORY SECTION------------------------------------------ --%>
                <div id="Inventory" class="tab-content">
                    <div class="inventory-container">
                        <table class="modern-table">
                            <thead>
                            <tr>
                                <th>Cover</th>
                                <th>Title</th>
                                <th>Selling Price</th>
                                <th>Renting Price</th>
                                <th style="text-align: center;">Status</th>
                                <th style="text-align: center;">Action</th>
                            </tr>
                            </thead>
                            <tbody>
                            <%
                                List<String[]> books = (List<String[]>) request.getAttribute("userBooks");
                                if (books != null && !books.isEmpty()) {
                                    for (String[] book : books) {

                                        // --- IMAGE LOGIC START ---
                                        String bookId = book[0];
                                        String imagePath = "images/books/default.png";
                                        String[] extensions = {".jpeg", ".jpg", ".png"};

                                        for (String ext : extensions) {
                                            String testPath = "/images/books/" + bookId + ext;
                                            if (new java.io.File(application.getRealPath(testPath)).exists()) {
                                                // Added System.currentTimeMillis() to prevent browser caching
                                                imagePath = "images/books/" + bookId + ext + "?t=" + System.currentTimeMillis();
                                                break;
                                            }
                                        }
                            %>
                            <tr>
                                <td>
                                    <img src="<%= imagePath %>" width="60" height="80"
                                         style="border-radius: 5px; object-fit: cover; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                                </td>
                                <td class="book-title"><%= book[1] %></td>
                                <td class="book-price">RM <%= book[2] %></td>
                                <td class="book-price" style="color: var(--darker-purple);">RM <%= book[3] %></td>
                                <td>
                                    <form id="statusForm_<%= book[0] %>" action="updateStatus" method="POST" style="margin:0;">
                                        <input type="hidden" name="bookId" value="<%= book[0] %>">
                                        <input type="hidden" name="customerId" id="customerId_<%= book[0] %>" value="">

                                        <select name="newStatus" onchange="handleStatusChange(this, '<%= book[0] %>')"
                                                style="padding: 5px; border-radius: 5px; border: 1px solid #ccc; font-weight: bold;
                                                        background-color: <%= book[5].equalsIgnoreCase("Available") ? "#d4edda" : "#f8d7da" %>;
                                                        color: <%= book[5].equalsIgnoreCase("Available") ? "#155724" : "#721c24" %>;">

                                            <option value="Available" <%= book[5].equalsIgnoreCase("Available") ? "selected" : "" %>>Available</option>
                                            <option value="Rented" <%= book[5].equalsIgnoreCase("Rented") ? "selected" : "" %>>Rented</option>
                                            <option value="Purchased" <%= book[5].equalsIgnoreCase("Purchased") ? "selected" : "" %>>Purchased</option>
                                        </select>
                                    </form>
                                </td>
                                <td style="width: 180px;"> <div style="display: flex; gap: 5px; justify-content: flex-start; align-items: center;">

                                    <button type="button" class="action-btn"
                                            style="width: 80px; padding: 6px 0; background-color: #4a90e2; font-size: 11px; border-radius: 20px;"
                                            onclick="openEditBookModal('<%= book[0] %>', '<%= book[1].replace("'", "\\'") %>', '<%= book[2] %>', '<%= book[3] %>')">
                                        ✏️ EDIT
                                    </button>

                                    <form action="deleteBook" method="POST" style="margin: 0;">
                                        <input type="hidden" name="bookId" value="<%= book[0] %>">
                                        <button type="submit" class="action-btn"
                                                style="width: 80px; padding: 6px 0; background-color: #ff5e62; font-size: 11px; border-radius: 20px;"
                                                onclick="return confirm('Remove this book?')">
                                            🗑️ REMOVE
                                        </button>
                                    </form>

                                </div>
                                </td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr><td colspan="6" class="empty-msg">No books found in your inventory.</td></tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div> </div> ```



    <div id="qrModal" class="modal">
        <div class="modal-content">
            <span class="close-btn" onclick="closeQRModal()">&times;</span>
            <h2>Update QR Code 📱</h2>
            <p>Upload a screenshot of your TNG or DuitNow QR.</p>
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

    <div id="addBookModal" class="modal">
        <div class="modal-content">
            <span class="close-btn" onclick="closeAddBookModal()">&times;</span>
            <h2>Sell a Book 📕</h2>
            <p>Enter the details below.</p>

            <form action="addBook" method="post" enctype="multipart/form-data">

                <div style="text-align: left; margin-bottom: 10px;">
                    <label>Book Title:</label><br>
                    <input type="text" name="title" placeholder="e.g. Intro to Java Programming" required style="width:100%; padding: 8px;">
               </div>

                <div style="display: flex; gap: 10px; margin-bottom: 10px;">
                    <div style="flex: 1; text-align: left;">
                        <label>Sale Price (RM):</label><br>
                        <input type="number" name="salePrice" step="0.01" placeholder="50.00" required style="width:100%; padding: 8px;">
                    </div>
                    <div style="flex: 1; text-align: left;">
                        <label>Rent Price (RM/week):</label><br>
                        <input type="number" name="rentPrice" step="0.01" placeholder="5.00" required style="width:100%; padding: 8px;">
                    </div>
                </div>

                <div style="text-align: left; margin-bottom: 10px;">
                    <label>Book Cover Image:</label><br>
                    <input type="file" name="bookImage" accept="image/*" required>
                </div>

                <button type="submit" class="action-btn">List Book Now 🚀</button>
            </form>
        </div>
    </div>

    <div id="editBookModal" class="modal">
        <div class="modal-content" style="width: 450px;">
            <span class="close-btn" onclick="closeEditBookModal()">&times;</span>
            <h2>Edit Book Details 📕</h2>
            <form action="editBook" method="post" enctype="multipart/form-data">
                <input type="hidden" name="bookId" id="editBookId">

                <div style="text-align: left; margin-bottom: 15px;">
                    <label>Book Title:</label>
                    <input type="text" name="title" id="editTitle" required style="width:100%; padding: 10px; border-radius: 5px; border: 1px solid #ccc;">
                </div>

                <div style="display: flex; gap: 10px; margin-bottom: 15px;">
                    <div style="flex: 1; text-align: left;">
                        <label>Sale Price (RM):</label>
                        <input type="number" name="salePrice" id="editSalePrice" step="0.01" required style="width:100%; padding: 10px; border-radius: 5px; border: 1px solid #ccc;">
                    </div>
                    <div style="flex: 1; text-align: left;">
                        <label>Rent Price (RM):</label>
                        <input type="number" name="rentPrice" id="editRentPrice" step="0.01" required style="width:100%; padding: 10px; border-radius: 5px; border: 1px solid #ccc;">
                    </div>
                </div>

                <div style="text-align: left; margin-bottom: 15px;">
                    <label>Update Cover Image (Optional):</label><br>
                    <input type="file" name="bookImage" accept="image/*" style="width:100%; padding: 8px; margin-top: 5px;">
                    <small style="color: #666;">Leave empty to keep current image.</small>
                </div>

                <button type="submit" class="action-btn" style="background-color: #BA55D3; width: 100%;">SAVE CHANGES 💾</button>
            </form>
        </div>
    </div>

</body>
</html>