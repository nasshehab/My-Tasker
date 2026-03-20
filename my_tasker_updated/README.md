# মাই ট্যাস্কার — My Tasker

পড়াশোনার পরিকল্পনা, অভ্যাস ট্র্যাকিং ও মাসিক PDF রিপোর্ট অ্যাপ।

---

## Build with Codemagic (Recommended)

1. Push this repo to **GitHub**
2. Go to [codemagic.io](https://codemagic.io) → connect GitHub
3. Select this repo → it auto-detects `codemagic.yaml`
4. Run **android-release** workflow → APK emailed to you

---

## Build locally

**Requirements:** Flutter 3.27+, Java 17, Android SDK

```bash
# Replace font (optional — FreeSans fallback already included)
# cp /path/to/Abu_JM_Akkash.ttf assets/fonts/Abu_JM_Akkash.ttf

flutter pub get
flutter build apk --release --split-per-abi
```

APK: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

---

## Font

The app uses **Abu JM Akkash** for Bangla text.  
A FreeSans fallback is included so the app builds without errors.  
Replace `assets/fonts/Abu_JM_Akkash.ttf` with the real font for correct Bangla rendering.

---

## Developer

**Nowshad Abrar Shehab** — Developer  
📧 shehab.eidgah2006@gmail.com  
🌐 [facebook.com/nowshadabrarshehab](https://www.facebook.com/nowshadabrarshehab)  
💬 [wa.me/8801855841672](https://wa.me/8801855841672)
