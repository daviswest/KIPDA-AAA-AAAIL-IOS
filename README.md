# KIPDA Notify - iOS App

**A senior capstone project for the Kentuckiana Planning and Development Agency (KIPDA).**

## About the Project
KIPDA Notify is an **iOS application** designed to **deliver real-time notifications** to older individuals and those with disabilities. Built with **Swift** and leveraging **Firebase** for database management and authentication, the app ensures timely and accessible communication.

### Key Features
✅ **Real-Time Notifications** – Instantly deliver updates to users.  
✅ **Accessibility-Focused** – Thoroughly tested with **native iOS accessibility features**.  
✅ **Localization Support** – Includes **localizable strings**, with potential for automated translation integration.  
✅ **Secure Authentication** – Uses **Firebase Authentication** to manage user access.  
✅ **Cloud-Backed Data** – Firebase stores and synchronizes notifications and user preferences.  

## Installation & Setup

### Prerequisites
- macOS with **Xcode installed**
- **CocoaPods** for dependency management
- A valid **Firebase configuration file** (`GoogleService-Info.plist`)

### 1. Clone the Repository
```sh
git clone https://github.com/daviswest/KIPDA-AAA-AAAIL-IOS.git
cd KIPDA-AAA-AAAIL-IOS
```

### 2. Install Dependencies
```sh
pod install
```

### 3. Firebase Setup
Since Firebase is used for authentication and the database, you'll need to add your own `GoogleService-Info.plist` file:
1. Go to [Firebase Console](https://console.firebase.google.com/) and create a project.
2. Download the `GoogleService-Info.plist` for iOS.
3. Place it in the project directory:
   ```
   KIPDA-AAA-AAAIL-IOS/
   ├── Capstone App/
   │   ├── Capstone App/
   │   ├── ├──GoogleService-Info.plist
   ```
4. Ensure the file is added to Xcode (if applicable).

### 4. Run the App
```sh
open KIPDA-AAA-AAAIL-IOS.xcworkspace
```
- Select a simulator or connected device.
- Press **Cmd + R** to build and run the project.

## Tech Stack
- **Language:** Swift
- **Database & Auth:** Firebase
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Accessibility:** Native iOS VoiceOver, Dynamic Type, High Contrast
- **Localization:** Localizable strings (future support for automatic translation)

## Contributors
This project was developed as part of a **senior capstone project** by:
**[Davis West, Saam Dejbani, Baraka Mulungula, Noureldin Abdelaziz, Jonathan Vessels]**

🚀 Special thanks to **Kentuckiana Planning and Development Agency (KIPDA)** for their collaboration and guidance.

## Security & API Keys
The API keys and Firebase configuration are **not included** in this repository for security reasons. Please refer to the **Firebase Setup** section above to configure your own credentials. Contact [davis.west20@gmail.com](mailto:davis.west20@gmail.com) for future database access.


## Future Improvements
**Automated Translation:** Integrate Google Translate API for real-time language translation.  
**Expanded Accessibility:** Additional improvements for users with visual or motor impairments.  
**Enhanced Notifications:** Customizable user preferences and richer notification options.  
**LLM Integration:** LLM fine-tuned on curated KIPDA data to efficiently connect users with essential resources.

## License
This project is for educational and non-commercial use. Contact the maintainers for more details.