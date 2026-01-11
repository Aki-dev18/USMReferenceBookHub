<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Welcome to BookHub</title>

    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📚</text></svg>">

    <style>
        /* --- 1. THEME VARIABLES --- */
        :root {
            --main-purple: #DDA0DD;
            --darker-purple: #BA55D3;
            --text-color: #333;
        }

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

        /* --- 2. MAIN CARD --- */
        .container {
            background-color: white;
            padding: 40px;
            border-radius: 15px;
            width: 100%;
            max-width: 400px;
            text-align: center;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }

        h1 {
            color: #333;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-size: 28px;
        }

        p { color: #666; margin-top: 0; margin-bottom: 20px; }

        /* --- 3. INPUTS --- */
        .input-group {
            margin-bottom: 15px;
            text-align: left;
        }

        .input-group label {
            font-size: 14px;
            color: #333;
            display: block;
            margin-bottom: 5px;
        }

        input, select {
            width: 100%;
            padding: 10px;
            border: 1px solid #555; /* Darker border */
            border-radius: 5px;
            font-size: 14px;
            box-sizing: border-box;
            background-color: #fff;
            color: #000;
        }

        input:focus, select:focus {
            border: 2px solid #000; /* Thicker Black Border on Click */
            outline: none;
            padding: 9px;
        }

        /* --- 4. BUTTONS --- */
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

        .btn-primary:hover {
            background-color: #9932CC;
            transform: scale(1.02);
        }

        .toggle-link {
            margin-top: 20px;
            font-size: 14px;
            color: #666;
            display: block;
        }

        .toggle-link span {
            color: var(--darker-purple);
            font-weight: bold;
            cursor: pointer;
        }

        .toggle-link span:hover { text-decoration: underline; }

        /* --- 5. UTILS --- */
        .hidden { display: none; }
        .logo { font-size: 50px; margin-bottom: 10px; display: block;}
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
                    <label>Email:</label>
                    <input type="email" name="email" placeholder="ali@student.usm.my">
                </div>
                <div class="input-group">
                    <label>Password:</label>
                    <input type="password" name="password">
                </div>

                <button type="submit" class="btn-primary">Login ➜</button>

                <div class="toggle-link">
                    Don't have an account? <span onclick="toggleForms()">Sign Up</span>
                </div>
            </form>
        </div>

        <div id="signup-section" class="hidden" style="display: none;">
            <p>Create your student account.</p>

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

                <button type="submit" class="btn-primary">Register Account</button>

                <div class="toggle-link">
                    Already have an account? <span onclick="toggleForms()">Login</span>
                </div>
            </form>
        </div>

    </div>

</body>
</html>
