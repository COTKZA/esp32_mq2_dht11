<?php
$servername = "localhost"; // Change to your database server
$username = "root";        // Change to your MySQL username
$password = "";            // Change to your MySQL password
$dbname = "esp32_mq2_dht11"; // Change to your MySQL database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Set character set to utf8mb4 to support a wide range of characters
if (!$conn->set_charset("utf8mb4")) {
    die("Error loading character set utf8mb4: " . $conn->error);
}
?>
