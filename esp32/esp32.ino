#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>

#define DHTPIN 22      // Pin for DHT11
#define DHTTYPE DHT11  // Type DHT11
#define MQ2_PIN 34     // Pin for MQ-2

const char* ssid = "cotkza";        // Your WiFi SSID
const char* password = "12345678";  // Your WiFi Password
const char* serverName = "http://192.168.100.110/esp32_mq2_dht11/api/insert_data.php";  // Your PHP script URL

DHT dht(DHTPIN, DHTTYPE); // Create DHT object

void setup() {
    Serial.begin(115200);
    WiFi.begin(ssid, password);
    
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.println("Connecting to WiFi...");
    }
    
    Serial.println("Connected to WiFi");
    
    dht.begin(); // Start DHT11 sensor
}

void loop() {
    // Read data from DHT11
    float temperature = dht.readTemperature();
    float humidity = dht.readHumidity();

    // Read data from MQ-2
    int gasValueRaw = analogRead(MQ2_PIN);

    // Convert gas value to percentage
    int gasValue = (gasValueRaw * 100) / 1023;

    // Send data to PHP script
    sendToServer(temperature, humidity, gasValue);

    delay(1000); // Delay 10 seconds before sending data again
}

void sendToServer(float temperature, float humidity, int gasValue) {
    if (WiFi.status() == WL_CONNECTED) {
        HTTPClient http;

        // Specify the URL and initiate connection
        http.begin(serverName);

        // Specify request header
        http.addHeader("Content-Type", "application/x-www-form-urlencoded");

        // Prepare POST data
        String postData = "temperature=" + String(temperature) + 
                          "&humidity=" + String(humidity) + 
                          "&gas=" + String(gasValue);

        // Send HTTP POST request
        int httpResponseCode = http.POST(postData);

        // Handle the response
        if (httpResponseCode > 0) {
            String response = http.getString();
            Serial.println(httpResponseCode);
            Serial.println(response);
        } else {
            Serial.println("Error on sending POST: " + String(httpResponseCode));
        }

        // Close the connection
        http.end();
    }
}
