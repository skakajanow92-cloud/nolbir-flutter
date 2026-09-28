#include <Arduino.h>
#include <Servo.h>
#include <DHT.h>
#include <IRremote.hpp>

// Pin Tanımlamaları
const int RELAY_PIN = 22;
const int SERVO_PIN = 2;
const int DHT_PIN = 4;
const int IR_RECEIVE_PIN = 18;
const int WATER_SENSOR_PIN = A2; // Water Sensor Signal (S) Pini

#define DHTTYPE DHT11

// Joystick Pin Tanımlamaları
const int JOY_X_PIN = A0;
const int JOY_Y_PIN = A1;
const int JOY_SW_PIN = 3;

// 74HC595 Shift Register Pinleri
const int DS_PIN = 11;
const int LATCH_PIN = 12;
const int CLOCK_PIN = 13;

// Digit Pinleri
const int digitPins[4] = {30, 31, 32, 33};

Servo myServo;
DHT dht(DHT_PIN, DHTTYPE);

// Ortak Katot Karakterler (0-9, 'C', 'H', 'L')
const byte digitPatterns[13] = {
    0b00111111, // 0 -> Index 0
    0b00000110, // 1 -> Index 1
    0b01011011, // 2 -> Index 2
    0b01001111, // 3 -> Index 3
    0b01100110, // 4 -> Index 4
    0b01101101, // 5 -> Index 5
    0b01111101, // 6 -> Index 6
    0b00000111, // 7 -> Index 7
    0b01111111, // 8 -> Index 8
    0b01101111, // 9 -> Index 9
    0b00111001, // 'C' -> Index 10
    0b01110110, // 'H' -> Index 11
    0b00111000  // 'L' -> Index 12 (Water Level)
};

#define PATTERN_BLANK 0b00000000

int temperature = 0;
int humidity = 0;
int waterLevelPercent = 0; // %0 - %99 arası su seviyesi
int currentServoAngle = 0;
bool relayState = LOW;

unsigned long lastDHTReadTime = 0;
unsigned long lastWaterReadTime = 0;
unsigned long lastSerialTime = 0;

// Ekran Modları: 0 -> Sıcaklık (C), 1 -> Nem (H), 2 -> Su Seviyesi (L)
int displayMode = 0;

void displaySensorData()
{
  byte patternsToDisplay[4];

  if (displayMode == 0)
  {
    // 1 Tuşu (0x0C): Sıcaklık Gösterimi (örn:  25C)
    patternsToDisplay[0] = PATTERN_BLANK;
    patternsToDisplay[1] = digitPatterns[(temperature / 10) % 10];
    patternsToDisplay[2] = digitPatterns[temperature % 10];
    patternsToDisplay[3] = digitPatterns[10]; // 'C'
  }
  else if (displayMode == 1)
  {
    // 2 Tuşu (0x18): Nem Gösterimi (örn: H 45)
    patternsToDisplay[0] = digitPatterns[11]; // 'H'
    patternsToDisplay[1] = PATTERN_BLANK;
    patternsToDisplay[2] = digitPatterns[(humidity / 10) % 10];
    patternsToDisplay[3] = digitPatterns[humidity % 10];
  }
  else if (displayMode == 2)
  {
    // 3 Tuşu (0x5E): Su Seviyesi Gösterimi (örn: L 85)
    patternsToDisplay[0] = digitPatterns[12]; // 'L'
    patternsToDisplay[1] = PATTERN_BLANK;
    patternsToDisplay[2] = digitPatterns[(waterLevelPercent / 10) % 10];
    patternsToDisplay[3] = digitPatterns[waterLevelPercent % 10];
  }

  for (int i = 0; i < 4; i++)
  {
    for (int d = 0; d < 4; d++)
    {
      digitalWrite(digitPins[d], HIGH);
    }

    digitalWrite(LATCH_PIN, LOW);
    shiftOut(DS_PIN, CLOCK_PIN, MSBFIRST, patternsToDisplay[i]);
    digitalWrite(LATCH_PIN, HIGH);

    digitalWrite(digitPins[i], LOW);
    delayMicroseconds(1000);
  }
}

void handleIRRemote()
{
  if (IrReceiver.decode())
  {
    uint16_t command = IrReceiver.decodedIRData.command;

    switch (command)
    {
    case 0x0C: // 1 Tuşu -> Ekranı Sıcaklık Moduna Al
      displayMode = 0;
      Serial.println("Mod Değişti: SICAKLIK");
      break;

    case 0x18: // 2 Tuşu -> Ekranı Nem Moduna Al
      displayMode = 1;
      Serial.println("Mod Değişti: NEM");
      break;

    case 0x5E: // 3 Tuşu -> Ekranı Su Seviyesi Moduna Al
      displayMode = 2;
      Serial.println("Mod Değişti: SU SEVİYESİ");
      break;

    case 0x45: // CH- -> Röleyi Kapat
      relayState = LOW;
      digitalWrite(RELAY_PIN, HIGH);
      Serial.println("Röle: KAPALI");
      break;

    case 0x47: // CH+ -> Röleyi Aç
      relayState = HIGH;
      digitalWrite(RELAY_PIN, LOW);
      Serial.println("Röle: AÇIK");
      break;

    case 0x44: // PREV -> Servoyu Sola Döndür
      currentServoAngle = constrain(currentServoAngle - 10, 0, 180);
      myServo.write(currentServoAngle);
      break;

    case 0x40: // NEXT -> Servoyu Sağa Döndür
      currentServoAngle = constrain(currentServoAngle + 10, 0, 180);
      myServo.write(currentServoAngle);
      break;

    default:
      break;
    }

    IrReceiver.resume();
  }
}

void setup()
{
  Serial.begin(115200);

  dht.begin();
  IrReceiver.begin(IR_RECEIVE_PIN, ENABLE_LED_FEEDBACK);

  pinMode(JOY_SW_PIN, INPUT_PULLUP);
  pinMode(WATER_SENSOR_PIN, INPUT);
  pinMode(DS_PIN, OUTPUT);
  pinMode(LATCH_PIN, OUTPUT);
  pinMode(CLOCK_PIN, OUTPUT);

  for (int i = 0; i < 4; i++)
  {
    pinMode(digitPins[i], OUTPUT);
    digitalWrite(digitPins[i], HIGH);
  }

  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, HIGH);

  myServo.attach(SERVO_PIN);
  myServo.write(currentServoAngle);
}

void loop()
{
  // 1. Ekran Yenileme
  displaySensorData();

  // 2. IR Kumanda Komutlarını İşle
  handleIRRemote();

  // 3. Joystick Kontrolü
  int xVal = analogRead(JOY_X_PIN);
  if (xVal < 400 || xVal > 600)
  {
    currentServoAngle = map(xVal, 0, 1023, 0, 180);
    myServo.write(currentServoAngle);
  }

  // 4. DHT11 Okuma (2 saniyede bir)
  if (millis() - lastDHTReadTime >= 2000)
  {
    lastDHTReadTime = millis();
    float h = dht.readHumidity();
    float t = dht.readTemperature();

    if (!isnan(h) && !isnan(t))
    {
      humidity = (int)h;
      temperature = (int)t;
    }
  }

  // 5. Water Sensor Okuma (500 ms'de bir)
  if (millis() - lastWaterReadTime >= 500)
  {
    lastWaterReadTime = millis();
    int rawWaterVal = analogRead(WATER_SENSOR_PIN);
    // Sensör kuru iken ~0, su temasında maksimum ~700 okunur.
    // Değeri %0 - %99 aralığına haritalandırıyoruz:
    waterLevelPercent = map(rawWaterVal, 0, 700, 0, 99);
    waterLevelPercent = constrain(waterLevelPercent, 0, 99);
  }

  // 6. Serial Monitor Çıktısı (1 saniyede bir)
  if (millis() - lastSerialTime >= 1000)
  {
    lastSerialTime = millis();
    Serial.print("Sıcaklık: ");
    Serial.print(temperature);
    Serial.print(" C | ");
    Serial.print("Nem: %");
    Serial.print(humidity);
    Serial.print(" | ");
    Serial.print("Su Seviyesi: %");
    Serial.println(waterLevelPercent);
  }
}