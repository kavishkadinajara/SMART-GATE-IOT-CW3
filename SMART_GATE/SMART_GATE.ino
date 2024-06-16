#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <Servo.h>
#include <time.h>
#include <Keypad.h>


#define DEBOUNCE_TIME 10
unsigned long lastKeyPressTime = 0;
// Firebase credentials
#define FIREBASE_HOST "https://smart-gate-f1f24-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "p4b5ePyxVjvXkpxZfqJMUfVfGuD6DQB7yqxAb5el"

const char* ssid = "******";
const char* password = "******";

// Define GPIO pins
#define GATE1_PIN D5 // GPIO pin connected to Gate 1 servo
#define GATE2_PIN D6 // GPIO pin connected to Gate 2 servo

// Define servo angles
#define GATE1_CLOSED_ANGLE 0 // Angle to close Gate 1
#define GATE1_OPEN_ANGLE 170 // Angle to open Gate 1
#define GATE2_CLOSED_ANGLE 0 // Angle to close Gate 2
#define GATE2_OPEN_ANGLE 170 // Angle to open Gate 2

// Define Firebase node
#define GATE_STATE_NODE "gates/main_gate"

// Create Servo objects
Servo gate1Servo;
Servo gate2Servo;

FirebaseData firebaseData;
FirebaseConfig config;
FirebaseAuth auth;

bool gate1State = false;
bool gate2State = false;

// Keypad setup
const byte ROWS = 1; // 1 row
const byte COLS = 4; // 4 columns
char keys[ROWS][COLS] = {
  {'1', '2', '3', '4'}
};
byte rowPins[ROWS] = {D4}; // Connect to the row pin of the keypad
byte colPins[COLS] = {D0, D1, D2, D3}; // Connect to the column pins of the keypad

Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);
String inputSequence = "";

void setup() {
  Serial.begin(9600);
  delay(100);

  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected.");

  // Initialize Firebase
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("Setup complete. Monitoring sensor state...");

  // Initialize NTP
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  while (!time(nullptr)) {
    Serial.print(".");
    delay(1000);
  }
  Serial.println("\nTime synchronized.");

  // Attach servos
  gate1Servo.attach(GATE1_PIN);
  gate2Servo.attach(GATE2_PIN);

  // Initialize gate state
  initializeGateState();
  delay(100);
}



void loop() {
  // Read keypad input
  char key = keypad.getKey();
  if (key) {
    // Debounce check
    if (millis() - lastKeyPressTime > DEBOUNCE_TIME) {
      Serial.print("Key pressed: ");
      Serial.println(key);
      inputSequence += key;
      Serial.print("Input sequence: ");
      Serial.println(inputSequence);

      // Toggling gates
      if (inputSequence.endsWith("123")) {
        Serial.println("Toggling Gate 1");
        if (gate1State) {
          closeGate1();
          Firebase.setBool(firebaseData, GATE_STATE_NODE "/isGate1Open", false);
        } else {
          openGate1();
          Firebase.setBool(firebaseData, GATE_STATE_NODE "/isGate1Open", true);
          Firebase.setString(firebaseData, GATE_STATE_NODE "/lastOpenedGate1", getTimeStamp());
        }
        inputSequence = ""; // Clear input sequence after action
      } else if (inputSequence.endsWith("432")) {
        Serial.println("Toggling Gate 2");
        if (gate2State) {
          closeGate2();
          Firebase.setBool(firebaseData, GATE_STATE_NODE "/isGate2Open", false);
        } else {
          openGate2();
          Firebase.setBool(firebaseData, GATE_STATE_NODE "/isGate2Open", true);
          Firebase.setString(firebaseData, GATE_STATE_NODE "/lastOpenedGate2", getTimeStamp());
        }
        inputSequence = ""; // Clear input sequence after action
      } else if (inputSequence.endsWith("324")) {
        Serial.println("Toggling both Gates");
        if (gate1State) {
          closeGate1();
          Firebase.setBool(firebaseData, GATE_STATE_NODE "/isGate1Open", false);
        } else {
          openGate1();
          Firebase.setBool(firebaseData, GATE_STATE_NODE "/isGate1Open", true);
          Firebase.setString(firebaseData, GATE_STATE_NODE "/lastOpenedGate1", getTimeStamp());
        }
        if (gate2State) {
          closeGate2();
          Firebase.setBool(firebaseData, GATE_STATE_NODE "/isGate2Open", false);
        } else {
          openGate2();
          Firebase.setBool(firebaseData, GATE_STATE_NODE "/isGate2Open", true);
          Firebase.setString(firebaseData, GATE_STATE_NODE "/lastOpenedGate2", getTimeStamp());
        }
        inputSequence = ""; // Clear input sequence after action
      }

      // Clear input sequence if it's too long (to avoid infinite growth)
      if (inputSequence.length() > 4) {
        inputSequence = "";
      }

      // Update last key press time
      lastKeyPressTime = millis();
    }
  }

  // Check Firebase for changes and update gate states accordingly
  checkFirebaseState();
}



void checkFirebaseState() {
  // Listen for changes in Firebase gate state
  if (Firebase.getBool(firebaseData, GATE_STATE_NODE "/isGate1Open")) {
    bool isGate1Open = firebaseData.boolData();
   // Serial.print("Gate1 state from Firebase: ");
   // Serial.println(isGate1Open);
    if (isGate1Open && !gate1State) {
      openGate1();
      gate1State = true;
    } else if (!isGate1Open && gate1State) {
      closeGate1();
      gate1State = false;
    }
  } else {
    Serial.print("Failed to get Gate1 state: ");
    Serial.println(firebaseData.errorReason());
  }

  if (Firebase.getBool(firebaseData, GATE_STATE_NODE "/isGate2Open")) {
    bool isGate2Open = firebaseData.boolData();
   // Serial.print("Gate2 state from Firebase: ");
   // Serial.println(isGate2Open);
    if (isGate2Open && !gate2State) {
      openGate2();
      gate2State = true;
    } else if (!isGate2Open && gate2State) {
      closeGate2();
      gate2State = false;
    }
  } else {
    Serial.print("Failed to get Gate2 state: ");
    Serial.println(firebaseData.errorReason());
  }
}

void initializeGateState() {
  // Set initial gate states from Firebase
  if (Firebase.getBool(firebaseData, GATE_STATE_NODE "/isGate1Open")) {
    gate1State = firebaseData.boolData();
    Serial.print("Initial Gate1 state: ");
    Serial.println(gate1State);
    if (gate1State) {
      openGate1();
    } else {
      closeGate1();
    }
  } else {
    Serial.print("Failed to get initial Gate1 state: ");
    Serial.println(firebaseData.errorReason());
  }

  if (Firebase.getBool(firebaseData, GATE_STATE_NODE "/isGate2Open")) {
    gate2State = firebaseData.boolData();
    Serial.print("Initial Gate2 state: ");
    Serial.println(gate2State);
    if (gate2State) {
      openGate2();
    } else {
      closeGate2();
    }
  } else {
    Serial.print("Failed to get initial Gate2 state: ");
    Serial.println(firebaseData.errorReason());
  }

  delay(2500);
}

String getTimeStamp() {
  time_t now = time(nullptr);
  struct tm* p_tm = localtime(&now);

  char timestamp[30];
  sprintf(timestamp, "%04d-%02d-%02dT%02d:%02d:%02d",
          (1900 + p_tm->tm_year),
          (1 + p_tm->tm_mon),
          p_tm->tm_mday,
          p_tm->tm_hour,
          p_tm->tm_min,
          p_tm->tm_sec);

  return String(timestamp);
}

void openGate1() {
  Serial.println("Opening Gate 1");
  for (int angle = GATE1_CLOSED_ANGLE; angle <= GATE1_OPEN_ANGLE; angle++) {
    gate1Servo.write(angle);
    delay(25); // Adjust the delay if needed for smoother movement
  }
  gate1State = true;
}

void closeGate1() {
  Serial.println("Closing Gate 1");
  for (int angle = GATE1_OPEN_ANGLE; angle >= GATE1_CLOSED_ANGLE; angle--) {
    gate1Servo.write(angle);
    delay(25); // Adjust the delay if needed for smoother movement
  }
  gate1State = false;
}

void openGate2() {
  Serial.println("Opening Gate 2");
  for (int angle = GATE2_CLOSED_ANGLE; angle <= GATE2_OPEN_ANGLE; angle++) {
    gate2Servo.write(angle);
    delay(25); // Adjust the delay if needed for smoother movement
  }
  gate2State = true;
}

void closeGate2() {
  Serial.println("Closing Gate 2");
  for (int angle = GATE2_OPEN_ANGLE; angle >= GATE2_CLOSED_ANGLE; angle--) {
    gate2Servo.write(angle);
    delay(25); // Adjust the delay if needed for smoother movement
  }
  gate2State = false;
}