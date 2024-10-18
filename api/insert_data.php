<?php
include 'config.php';

// Check if data is sent via POST
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $temperature = $_POST['temperature'];
    $humidity = $_POST['humidity'];
    $gas = $_POST['gas'];

    // Prepare SQL query
    $sql = "INSERT INTO esp32_data (date, time, temperature, humidity, gas) VALUES (CURDATE(), CURTIME(), ?, ?, ?)";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ddi", $temperature, $humidity, $gas);

    // Execute the query
    if ($stmt->execute()) {
        echo "Data inserted successfully";
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }

    $stmt->close();
}

$conn->close();
?>
