<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Welcome to BookHub</title>

    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📚</text></svg>">

    <style>
        /* styling for main theme colors used across the page */
        :root {
            --main-purple: #DDA0DD;
            --darker-purple: #BA55D3;
            --text-color: #333;
        }

        /* styling for overall page layout and background */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--main-purple);
            min-height: 100vh;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            box-sizing: border-box;
        }

        /* styling for main login/signup card container */
        .container {
            background-color: white;
            padding: 40px;
            border-radius: 15px;
            width: 100%;
            max-width: 400px;
            text-align: center;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }

        /* styling for main heading text */
        h1 {
            color: #333;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-size: 28px;
        }

        /* styling for paragraph text */
        p {
            color: #666;
            margin-top: 0;
            margin-bottom: 20px;
        }

        /* styling for input field group layout */
        .input-group {
            margin-bottom: 15px;
            text-align: left;
        }

        /* styling for input labels */
        .input-group label {
            font-size: 14px;
            color: #333;
            display: block;
            margin-bottom: 5px;
        }

        /* styling for input and select fields */
        input, select {
            width: 100%;
            padding: 10px;
            border: 1px solid #555;
            border-radius: 5px;
            font-size: 14px;
            box-sizing: border-box;
            background-color: #fff;
            color: #000;
        }

        /* styling for focused input fields */
        input:focus, select:focus {
            border: 2px solid #000;
            outline: none;
            padding: 9px;
        }

        /* styling for main action buttons */
        .btn-primary {
            background-color: var(--darker-purple);
            color: white;
            border: none;
            padding: 12px 30px;
            width: 100%;
            border-radius: 25px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            text-transform: uppercase;
            transition: 0.3s;
            margin-top: 15px;
            letter-spacing: 0.5px;
        }

        /* styling for button hover effect */
        .btn-primary:hover {
            background-color: #9932CC;
            transform: scale(1.02);
        }

        /* styling for form toggle text */
        .toggle-link {
            margin-top: 20px;
            font-size: 14px;
            color: #666;
            display: block;
        }

        /* styling for clickable toggle text */
        .toggle-link span {
            color: var(--darker-purple);
            font-weight: bold;
            cursor: pointer;
        }

        /* styling for toggle hover effect */
        .toggle-link span:hover {
            text-decoration: underline;
        }

        /* styling for hidden sections */
        .hidden {
            display: none;
        }

        /* styling for logo display */
        .logo {
            font-size: 50px;
            margin-bottom: 10px;
            display: block;
        }
    </style>

    <script>
        //function for switching between login and signup forms
        function toggleForms() {
            var loginForm = document.getElementById("login-section");
            var signupForm = document.getElementById("signup-section");

            if (loginForm.style.display === "none") {
                loginForm.style.display = "block";
                signupForm.style.display = "none";
            } else {
                loginForm.style.display = "none";
                signupForm.style.display = "block";
            }
        }
    </script>
</head>
<body>

    <!-- ---Authentication Page Container--- -->
    <div class="container">

        <!-- ---Logo & Title--- -->
        <span class="logo">📚</span>
        <h1>USM BookHub</h1>

        <!-- ---Login Section--- -->
        <div id="login-section">

            <p>Welcome back! Please login.</p>

            <!-- similar theme for login form inputs -->
            <form action="login" method="post">

                <div class="input-group">
                    <label>Email:</label>
                    <input type="email" name="email" placeholder="ali@student.usm.my">
                </div>

                <div class="input-group">
                    <label>Password:</label>
                    <input type="password" name="password">
                </div>

                <!-- ---Login Button--- -->
                <button type="submit" class="btn-primary">Login ➜</button>

                <div class="toggle-link">
                    Don't have an account? <span onclick="toggleForms()">Sign Up</span>
                </div>

            </form>
        </div>

        <!-- ---Signup Section--- -->
        <div id="signup-section" class="hidden" style="display: none;">

            <p>Create your student account.</p>

            <!-- similar theme for signup form inputs -->
            <form action="register" method="post">

                <div class="input-group">
                    <label>Full Name:</label>
                    <input type="text" name="fullName" placeholder="Ali Bin Abu">
                </div>

                <div class="input-group">
                    <label>USM Email:</label>
                    <input type="email" name="email" placeholder="ali@student.usm.my">
                </div>

                <div class="input-group">
                    <label>Password:</label>
                    <input type="password" name="password">
                </div>

                <div class="input-group">
                    <label>Phone Number:</label>
                    <input type="text" name="phone" placeholder="012-3456789">
                </div>

                <div class="input-group">
                    <label>Address:</label>
                    <input type="text" name="address" placeholder="Desasiswa Tekun">
                </div>

                <div class="input-group">
                    <label>Major:</label>
                    <input type="text" name="major" placeholder="Computer Science">
                </div>

                <!-- ---Register Button--- -->
                <button type="submit" class="btn-primary">Register Account</button>

                <div class="toggle-link">
                    Already have an account? <span onclick="toggleForms()">Login</span>
                </div>

            </form>
        </div>

    </div>

</body>
</html>
