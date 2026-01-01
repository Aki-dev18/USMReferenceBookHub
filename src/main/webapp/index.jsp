<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Welcome to BookHub</title>
    <style>
        /* --- 1. CSS VARIABLES (Purple Theme) --- */
        :root {
            --main-purple: #DDA0DD; /* Light Purple */
            --darker-purple: #BA55D3; /* Darker Purple */
            --deep-purple: #800080;
            --text-color: #333;
            --bg-gray: #f4f4f4;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-gray);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh; /* Full screen height */
            margin: 0;
        }

        /* --- 2. THE MAIN CARD --- */
        .container {
            background-color: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0px 10px 25px rgba(0,0,0,0.1);
            width: 400px;
            text-align: center;
            border-top: 5px solid var(--darker-purple);
        }

        h1 { color: var(--deep-purple); margin-bottom: 5px; }
        p { color: #666; margin-top: 0; }

        /* --- 3. FORM INPUTS --- */
        .input-group {
            margin-bottom: 15px;
            text-align: left;
        }

        .input-group label {
            font-size: 12px;
            font-weight: bold;
            color: #555;
            display: block;
            margin-bottom: 5px;
        }

        input, select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            box-sizing: border-box; /* Ensures padding doesn't break width */
        }

        input:focus {
            border-color: var(--darker-purple);
            outline: none;
        }

        /* --- 4. BUTTONS --- */
        .btn-primary {
            background-color: var(--darker-purple);
            color: white;
            border: none;
            padding: 12px;
            width: 100%;
            border-radius: 25px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s;
            margin-top: 10px;
        }

        .btn-primary:hover { background-color: var(--deep-purple); }

        .toggle-link {
            margin-top: 15px;
            font-size: 14px;
            color: #666;
        }

        .toggle-link span {
            color: var(--deep-purple);
            font-weight: bold;
            cursor: pointer;
            text-decoration: underline;
        }

        /* --- 5. HIDE/SHOW LOGIC --- */
        .hidden { display: none; }

        /* Logo styling */
        .logo { font-size: 40px; margin-bottom: 10px; display: block;}
    </style>

    <script>
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

    <div class="container">

        <span class="logo">📚</span>
        <h1>USM BookHub</h1>

        <div id="login-section">
            <p>Welcome back! Please login.</p>

            <form action="login" method="post">
                <div class="input-group">
                    <label>Email</label>
                    <input type="email" name="email" placeholder="ali@student.usm.my" required>
                </div>
                <div class="input-group">
                    <label>Password</label>
                    <input type="password" name="password" placeholder="••••••••" required>
                </div>

                <button type="submit" class="btn-primary">LOGIN</button>
            </form>

            <div class="toggle-link">
                Don't have an account? <span onclick="toggleForms()">Sign Up</span>
            </div>
        </div>

        <div id="signup-section" class="hidden" style="display: none;">
            <p>Create your student account.</p>

            <form action="register" method="post">

                <div class="input-group">
                    <label>Full Name</label>
                    <input type="text" name="fullName" placeholder="Ali Bin Abu" required>
                </div>

                <div class="input-group">
                    <label>USM Email</label>
                    <input type="email" name="email" placeholder="ali@student.usm.my" required>
                </div>

                <div class="input-group">
                    <label>Password</label>
                    <input type="password" name="password" required>
                </div>

                <div class="input-group">
                    <label>Phone Number</label>
                    <input type="text" name="phone" placeholder="012-3456789">
                </div>

                <div class="input-group">
                    <label>Dorm / Address</label>
                    <input type="text" name="address" placeholder="Desasiswa Tekun">
                </div>

                <div class="input-group">
                    <label>Major</label>
                    <select name="major">
                        <option value="Computer Science">Computer Science</option>
                        <option value="Accounting">Accounting</option>
                        <option value="Engineering">Engineering</option>
                        <option value="Arts">Arts</option>
                        <option value="Other">Other</option>
                    </select>
                </div>

                <button type="submit" class="btn-primary">CREATE ACCOUNT</button>
            </form>

            <div class="toggle-link">
                Already have an account? <span onclick="toggleForms()">Login</span>
            </div>
        </div>

    </div>

</body>
</html>
