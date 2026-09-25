#include <Arduino.h>

// Rölenin bağlı olduğu dijital pin
const int RELAY_PIN = 7;

void setup() {
  // Seri haberleşmeyi başlat (Hata takibi ve durum bilgisi için)
  Serial.begin(115200);
  Serial.println("Arduino Mega 2560 - Röle Testi Başlatılıyor...");

  // Röle pinini çıkış olarak ayarla
  pinMode(RELAY_PIN, OUTPUT);

  // Röle modüllerinin büyük çoğunluğu LOW (0V) tetiklemelidir (Active LOW).
  // Başlangıçta rölenin KAPALI olmasını sağlamak için varsayılan olarak HIGH veriyoruz.
  digitalWrite(RELAY_PIN, HIGH);
}

void loop() {
  // --- RÖLEYİ AÇ (Ampul Yansın) ---
  // Eğer röleniz LOW tetiklemeli ise LOW röleyi çeker/açar.
  // (Eğer HIGH tetiklemeli bir röle kullanıyorsanız LOW yerine HIGH yazmalısınız)
  Serial.println("Röle AÇILDI -> Ampul Yanıyor");
  digitalWrite(RELAY_PIN, LOW); 
  delay(3000); // 3 saniye bekle

  // --- RÖLEYİ KAPAT (Ampul Sönsün) ---
  Serial.println("Röle KAPATILDI -> Ampul Söndü");
  digitalWrite(RELAY_PIN, HIGH);
  delay(3000); // 3 saniye bekle
}

