#include <Adafruit_PN532.h>
#define SCK  (24)
#define MOSI (25)
#define SS   (27)
#define MISO (26)

Adafruit_PN532 nfc(SCK, MISO, MOSI, SS);

void setup(void) {
  Serial.begin(115200);
  Serial.println("Looking for PN532...");

  nfc.begin();

  uint32_t versiondata = nfc.getFirmwareVersion();
  if (! versiondata) {
    Serial.print("Didn't find PN53x board");
    while (1); // halt
  }

  Serial.print("Found chip PN5"); 
  Serial.println((versiondata>>24) & 0xFF, HEX); 
  Serial.print("Firmware ver. "); 
  Serial.print((versiondata>>16) & 0xFF, DEC); 
  Serial.print('.'); 
  Serial.println((versiondata>>8) & 0xFF, DEC);


  nfc.SAMConfig();

  Serial.println("Waiting for an ISO14443A Card ...");
}


void loop(void) {
  uint8_t success;                          
  uint8_t uid[] = { 
    0, 0, 0, 0, 0, 0, 0   };  
  uint8_t uidLength;                        
  uint8_t currentblock;                     
  bool authenticated = false;               
  uint8_t data[16];                         


  uint8_t keya[6] = { 
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   };
  uint8_t keyb[6] = { 
    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF   };

  success = nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, uid, &uidLength);

  if (success) {
    Serial.println("Found an ISO14443A card");
    Serial.print("  UID Length: ");
    Serial.print(uidLength, DEC);
    Serial.println(" bytes");
    Serial.print("  UID Value: ");
    nfc.PrintHex(uid, uidLength);
    Serial.println("");

    if (uidLength == 4)
    {

      Serial.println("Seems to be a Mifare Classic card (4 byte UID)");

      for (currentblock = 0; currentblock < 64; currentblock++)
      {
        if (nfc.mifareclassic_IsFirstBlock(currentblock)) authenticated = false;

        if (!authenticated)
        {
          Serial.print("------------------------Sector ");
          Serial.print(currentblock/4, DEC);
          Serial.println("-------------------------");
          if (currentblock == 0)
          {
            success = nfc.mifareclassic_AuthenticateBlock (uid, uidLength, currentblock, 0, keya);
          }
          else
          {
            success = nfc.mifareclassic_AuthenticateBlock (uid, uidLength, currentblock, 0, keyb);
          }
          if (success)
          {
            authenticated = true;
          }
          else
          {
            Serial.println("Authentication error");
          }
        }        

        if (!authenticated)
        {
          Serial.print("Block ");
          Serial.print(currentblock, DEC);
          Serial.println(" unable to authenticate");
        }
        else
        {

          success = nfc.mifareclassic_ReadDataBlock(currentblock, data);
          if (success)
          {

            Serial.print("Block ");
            Serial.print(currentblock, DEC);
            if (currentblock < 10)
            {
              Serial.print("  ");
            }
            else
            {
              Serial.print(" ");
            }

            nfc.PrintHexChar(data, 16);
          }
          else
          {

            Serial.print("Block ");
            Serial.print(currentblock, DEC);
            Serial.println(" unable to read this block");
          }
        }       
      }
    }
    else
    {
      Serial.println("Ooops ... this doesn't seem to be a Mifare Classic card!"); 
    }
  }

  Serial.println("\n\nSend a character to run the mem dumper again!");
  Serial.flush();
  while (!Serial.available());
  Serial.flush();
}


