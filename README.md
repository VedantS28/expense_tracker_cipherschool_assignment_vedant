# CipherSchools Flutter Assignment - Expense Tracker

##  **Expense Tracker Application**

###   **Objective**
This project is a personal expense tracker app built using **Flutter** and **Firebase**, designed to help users track their financial data with a clean UI, authentication, and real-time notifications.

---

### 🔥 **Features**

- **User Interface:** 
  - Clean and intuitive design using **Material Design** components.
  - Organized folder structure for better scalability.
- **Core Functionalities:**
  - Add, view, and delete expense and income entries.
  - Categorize expenses into groups: `Food`, `Travel`, `Shopping`, and `Subscriptions`.
  - Supports seamless synchronization of transaction data between offline and online modes, ensuring that all entries are accurately reflected on the home page regardless of connectivity status using HIVE.

#### 🎁 **Bonus Features**
- **Budget Management:**
  - Users can set budgets for both **overall spending** and **category-wise** (Food, Travel, etc.).
  - Real-time tracking and visual representation of expenses against the budget.
- **Firebase Notifications:**
  - Real-time notification alerts using **Firebase Cloud Messaging (FCM)**.
  - Notifications for reaching or exceeding budget limits.

---

### 🛠️ **Tech Stack**
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase 
- **Local Storage:** Hive and Shared Preference 
- **State Management:** Provider
- **Notifications:** Firebase Cloud Messaging (FCM)

---

### 📂 **Folder Structure**
```
lib
 ┣ constants
 ┃ ┗ category_constants.dart
 ┣ models
 ┃ ┣ hive_models
 ┃ ┃ ┣ transaction.dart
 ┃ ┃ ┗ transaction.g.dart
 ┃ ┣ budget.dart
 ┃ ┣ expense.dart
 ┃ ┣ income.dart
 ┃ ┗ user.dart
 ┣ routes
 ┃ ┗ routes.dart
 ┣ services
 ┃ ┣ auth_service.dart
 ┃ ┣ budget_service.dart
 ┃ ┣ local_storage_service.dart
 ┃ ┣ notification_service.dart
 ┃ ┣ profile_service.dart
 ┃ ┗ transaction_service.dart
 ┣ styles
 ┃ ┗ styles.dart
 ┣ viewmodels
 ┃ ┣ authentication_provider.dart
 ┃ ┣ budget_provider.dart
 ┃ ┣ notification_provider.dart
 ┃ ┣ profile_provider.dart
 ┃ ┣ transaction_provider.dart
 ┃ ┗ user_provider.dart
 ┣ views
 ┃ ┣ about
 ┃ ┃ ┗ about_screen.dart
 ┃ ┣ auth
 ┃ ┃ ┣ login_screen.dart
 ┃ ┃ ┗ signup_screen.dart
 ┃ ┣ budget
 ┃ ┃ ┗ budget_list_screen.dart
 ┃ ┣ main
 ┃ ┃ ┣ home_screen.dart
 ┃ ┃ ┗ main_screen.dart
 ┃ ┣ notification
 ┃ ┃ ┗ notification_screen.dart
 ┃ ┣ profile
 ┃ ┃ ┗ profile_screen.dart
 ┃ ┣ splashscreens
 ┃ ┃ ┣ getting_started_screen.dart
 ┃ ┃ ┗ splash_screen.dart
 ┃ ┗ transactions
 ┃ ┃ ┣ add_transaction_screen.dart
 ┃ ┃ ┗ transaction_screen.dart
 ┣ firebase_options.dart
 ┗ main.dart
```

---

### 🚦 **Installation and Usage**
1. **Clone the Repository**
```
git clone https://github.com/yourusername/CipherSchools-Flutter-Assignment.git
cd CipherSchools-Flutter-Assignment
```
2. **Install Dependencies**
```
flutter pub get
```
3. **Run the Application**
```
flutter run
```

---

### 🎥 **Demo and APK**
- **[Watch Working Video](#)**  
- **[Download APK](#)**  

---

### 👤 **Submitted By**
- **Name:** Vedant Shrivastava  
- **GitHub:** [https://github.com/VedantS28](#)  
- **LinkedIn:** [https://www.linkedin.com/in/vedants28/](#)  
