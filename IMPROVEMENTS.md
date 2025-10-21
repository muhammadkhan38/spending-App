# Spending Tracker - Improved Version

A beautiful and feature-rich spending tracker application built with Flutter, following MVVM architecture with GetX state management.

## ✨ Features

### 1. **Spending Tab**
- **Toggle between Expense and Income** - View your expenses or income with a single tap
- **Total Balance Display** - See your overall balance at a glance with a beautiful gradient card
- **Summary Cards** - Quick view of total income and expense
- **Filtered Transaction List** - View expenses or income transactions based on your selection
- **Category Icons** - Each transaction displays with its category icon and color

### 2. **Transactions Tab**
- **Complete Transaction List** - View all your transactions sorted by date
- **Add New Transaction** - Comprehensive form to add transactions with:
  - Title
  - Amount
  - Category selection
  - Account selection
  - Date picker
  - Optional notes
  - Type (Expense/Income) toggle
- **Swipe to Delete** - Easily delete transactions with a swipe gesture
- **Confirmation Dialog** - Prevents accidental deletions
- **Empty State** - Beautiful placeholder when no transactions exist

### 3. **Categories Tab**
- **Grid Layout** - Beautiful grid view of all categories
- **Icon & Color Display** - Each category shows with its custom icon and color
- **Add New Category**:
  - Custom title
  - Choose from 20+ icons
  - Select from 18 colors
  - Live preview
- **Edit Categories** - Tap any category to edit its properties
- **Delete Categories** - Remove categories with confirmation
- **Pre-loaded Categories** - 10 default categories to get started

### 4. **Accounts Tab**
- **Total Balance Overview** - See combined balance across all accounts
- **Account List** - View all your accounts (Cash, Bank, Credit Card, etc.)
- **Add New Account**:
  - Account name
  - Initial balance
  - Custom color
- **Edit Accounts** - Update account details
- **Auto Balance Updates** - Account balances update automatically with transactions
- **Delete Accounts** - Remove accounts with confirmation

## 🏗️ Architecture

### MVVM with GetX
- **Models** (`lib/models/`): Data models with Hive adapters for persistence
  - `CategoryModel` - Category data structure
  - `AccountModel` - Account data structure
  - `TransactionModel` - Transaction data structure

- **Views** (`lib/views/`): UI components
  - `SpendingView` - Expense/Income dashboard
  - `TransactionsView` - Transaction management
  - `CategoriesView` - Category management
  - `AccountView` - Account management
  - `HomeView` - Main navigation with TabBar

- **ViewModels** (`lib/viewmodels/`): Business logic with GetX controllers
  - `CategoryViewModel` - Category CRUD operations
  - `AccountViewModel` - Account CRUD operations
  - `TransactionViewModel` - Transaction CRUD operations

## 🎨 Design System

### Custom Reusable Components
Located in `lib/widgets/`:
- **CustomButton** - Reusable button with variants (filled, outlined)
- **CustomCard** - Elevated card with consistent styling
- **CustomTextField** - Styled text input with labels
- **CategoryIcon** - Icon display with colored background
- **ColorCircle** - Color selector component
- **IconSelector** - Icon picker component

### Theme (`lib/utils/app_theme.dart`)
- **Modern Color Palette**:
  - Primary: Purple (`#6B4EFF`)
  - Secondary: Cyan (`#1AC8ED`)
  - Expense: Pink (`#FF6584`)
  - Income: Green (`#4CAF50`)
- **Gradient Backgrounds**
- **Consistent Border Radius** (12-16px)
- **Elevation Shadows**
- **Typography Styles**

## 💾 Data Persistence

### Hive Local Database
- **Fast and Efficient** - NoSQL database optimized for Flutter
- **Type-Safe** - Generated adapters ensure data integrity
- **Three Boxes**:
  - `categories` - Stores category data
  - `accounts` - Stores account data
  - `transactions` - Stores transaction data

### Automatic Balance Management
- Transactions automatically update account balances
- Balance recalculated on transaction add/delete
- Maintains data consistency

## 📦 Dependencies

```yaml
dependencies:
  get: ^4.6.6                    # State management
  hive: ^2.2.3                   # Local database
  hive_flutter: ^1.1.0           # Hive Flutter integration
  intl: ^0.19.0                  # Date formatting
  flutter_iconpicker: ^3.2.4     # Icon selection
  fl_chart: ^0.69.0              # Charts (for future features)

dev_dependencies:
  hive_generator: ^2.0.1         # Code generation
  build_runner: ^2.4.13          # Build tools
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK (3.9.0 or higher)

### Installation

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Generate Hive adapters**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## 📱 How to Use

### Adding Your First Transaction

1. **Create an Account**:
   - Go to **Accounts** tab
   - Tap the **+ Add Account** button
   - Enter account name (e.g., "Cash", "Bank Account")
   - Select a color
   - Set initial balance
   - Tap **Add**

2. **Add a Transaction**:
   - Go to **Transactions** tab
   - Tap the **+ Add Transaction** button
   - Toggle **Expense** or **Income**
   - Enter title and amount
   - Select category and account
   - Choose date
   - Add optional note
   - Tap **Add**

3. **View Your Spending**:
   - Go to **Spending** tab
   - Toggle between Expense and Income to see filtered views
   - View your total balance and transaction summaries

### Managing Categories

1. Go to **Categories** tab
2. Tap any category to edit (change icon, color, or name)
3. Tap **+ Add Category** to create a new one
4. Choose from 20+ icons and 18 colors
5. Preview before saving

## 🎯 Future Enhancements

- [ ] Charts and graphs for spending visualization
- [ ] Budget tracking
- [ ] Recurring transactions
- [ ] Export to CSV/PDF
- [ ] Dark mode theme
- [ ] Multi-currency support
- [ ] Cloud sync
- [ ] Biometric authentication

## 🐛 Troubleshooting

### If you encounter build errors:
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### If Hive data is corrupted:
Delete the app data and reinstall, or navigate to the app data directory and delete the Hive boxes manually.

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

---

**Built with ❤️ using Flutter, GetX, and Hive**
