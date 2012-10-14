#include <Adafruit_PN532.h>
#define SCK  (2)
#define MOSI (3)
#define SS   (4)
#define MISO (5)

Adafruit_PN532 nfc(SCK, MISO, MOSI, SS);

const char * url = "Brian";

void setup(void) {
  Serial.begin(115200);
  Serial.println("Looking for PN532...");

  nfc.begin();

  uint32_t versiondata = nfc.getFirmwareVersion();
  if (! versiondata) {
    Serial.print("Didn't find PN53x board");
    while (1);
  }
  
  Serial.print("Found chip PN5"); Serial.println((versiondata>>24) & 0xFF, HEX); 
  Serial.print("Firmware ver. "); Serial.print((versiondata>>16) & 0xFF, DEC); 
  Serial.print('.'); Serial.println((versiondata>>8) & 0xFF, DEC);
  
  nfc.SAMConfig();
  
  Serial.println("");
  Serial.println("Place your Mifare Classic card on the reader to format with NDEF");
  Serial.println("and press any key to continue ...");
  Serial.flush();
  while (!Serial.available());
  Serial.flush();
}

void loop(void) {
  uint8_t success;                          
  uint8_t uid[] = { 0, 0, 0, 0, 0, 0, 0 };  
  uint8_t uidLength;                        
  bool authenticated = false;               

  uint8_t keya[6] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
    
  success = nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, uid, &uidLength);
  
  if (success) 
  {
    Serial.println("Found an ISO14443A card");
    Serial.print("  UID Lenugth: ");Serial.print(uidLength, DEC);Serial.println(" bytes");
    Serial.print("  UID Value: ");
    nfc.PrintHex(uid, uidLength);
    Serial.println("");
    
    if (uidLength != 4)
    {
      Serial.println("Ooops ... this doesn't seem to be a Mifare Classic card!"); 
      return;
    }
    
    Serial.println("Seems to be a Mifare Classic card (4 byte UID)");

    success = nfc.mifareclassic_AuthenticateBlock (uid, uidLength, 0, 0, keya);
    if (!success)
    {
      Serial.println("Unable to authenticate block 0 to enable card formatting!");
      return;
    }
    success = nfc.mifareclassic_FormatNDEF();
    if (!success)
    {
      Serial.println("Unable to format the card for NDEF");
      return;
    }
    
    Serial.println("Card has been formatted for NDEF data using MAD1");
    
    success = nfc.mifareclassic_AuthenticateBlock (uid, uidLength, 4, 0, keya);

    if (!success)
    {
      Serial.println("Authentication failed.");
      return;
    }
    
    Serial.println("Writing URI to sector 1 as an NDEF Message");
    
    if (strlen(url) > 38)
    {
      Serial.println("URI is too long ... must be less than 38 characters long");
      return;
    }
    
    success = nfc.mifareclassic_WriteNDEFURI(1, NDEF_URIPREFIX_HTTP_WWWDOT, url);
    if (success)
    {
      Serial.println("NDEF URI Record written to sector 1");
    }
    else
    {
      Serial.println("NDEF Record creation failed! :(");
    }
  }
  
  Serial.println("\n\nDone!");
  Serial.flush();
  while (!Serial.available());
  Serial.flush();
}
