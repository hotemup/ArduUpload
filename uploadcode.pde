#include <Adafruit_PN532.h>

//Setting up board pins
#define SCK (24)
#define MOSI (25)
#define SS (27)
#define MISO (26)
Adafruit_PN532 nfc(SCK, MISO, MOSI, SS);
//-------------------------------------------

const char * dataSend = "Test Info";

void setup(){
  Serial.begin(115200);
  nfc.begin();
  uint32_t versiondata = nfc.getFirmwareVersion();
  if(! versiondata){
    Serial.print("No luck finding the board.");
    while(1);
  }

  Serial.println("Linked...");  
  nfc.SAMConfig();
  Serial.println("Please place the RFID tag on the Mifare board, then press a key");
  Serial.flush();
  while (!Serial.available());
  Serial.flush();
}


void loop(){
  uint8_t  success;
  uint8_t  uid[] = {0,0,0,0,0,0,0};
  uint8_t  uidLength;
  bool auth = false;
  uint8_t key[6] = {0xFF,0xFF,0xFF,0xFF,0xFF,0xFF};
  success = nfc.mifareclassic_WriteNDEFURI(1, NDEF_URIPREFIX_HTTP_WWWDOT, dataSend);
if(success){
 Serial.println("Written");
  }else{
  Serial.println("Failed");
  }
}




