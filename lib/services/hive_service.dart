import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/category_model.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../utils/app_constants.dart';

/// A compatibility layer that preserves the old `HiveService` API shape
/// while storing data in a local SQLite database (sqflite).
///
/// This class provides the same static methods used throughout the app
/// (init, add/update/delete for categories/accounts/transactions) and
/// exposes lightweight in-memory "box" objects via `categoriesBox`,
/// `accountsBox`, and `transactionsBox` so existing viewmodels can call
/// `.values.toList()` as before.
class HiveService {
  static Database? _db;

  // In-memory caches used to emulate Hive boxes' synchronous access
  static final List<CategoryModel> _categories = [];
  static final List<AccountModel> _accounts = [];
  static final List<TransactionModel> _transactions = [];

  // Simple box-like wrapper used by viewmodels. Only implements the
  // members the app relies on (values, length, getAt).
  static InMemoryBox<CategoryModel> get categoriesBox => InMemoryBox(_categories);
  static InMemoryBox<AccountModel> get accountsBox => InMemoryBox(_accounts);
  static InMemoryBox<TransactionModel> get transactionsBox => InMemoryBox(_transactions);

  /// Initialize the database and load data into in-memory caches.
  static Future<void> init() async {
    if (_db != null) return;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, 'spending_tracker.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accounts (
            id TEXT PRIMARY KEY,
            name TEXT,
            colorValue INTEGER,
            balance REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            title TEXT,
            iconCode INTEGER,
            colorValue INTEGER,
            type INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            title TEXT,
            amount REAL,
            categoryId TEXT,
            accountId TEXT,
            date TEXT,
            type INTEGER,
            note TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE budgets (
            id TEXT PRIMARY KEY,
            amount REAL,
            categoryId TEXT,
            startDate TEXT,
            endDate TEXT
          )
        ''');
      },
    );

    // Load existing data
    await _loadAll();

    // Initialize default categories if empty
    if (_categories.isEmpty) {
      for (var category in AppConstants.defaultCategories) {
        final model = CategoryModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + (category['title'] as String),
          title: category['title'] as String,
          iconCode: category['iconCode'] as int,
          colorValue: category['colorValue'] as int,
          type: category['type'] as int? ?? 0,
        );
        await addCategory(model);
      }
    }
  }

  static Future<void> _loadAll() async {
    if (_db == null) return;

    final db = _db!;

    final accountsMaps = await db.query('accounts', orderBy: 'rowid');
    _accounts
      ..clear()
      ..addAll(accountsMaps.map((m) => AccountModel.fromMap(m)).toList());

    final categoriesMaps = await db.query('categories', orderBy: 'rowid');
    _categories
      ..clear()
      ..addAll(categoriesMaps.map((m) => CategoryModel.fromMap(m)).toList());

    final txMaps = await db.query('transactions', orderBy: 'rowid');
    _transactions
      ..clear()
      ..addAll(txMaps.map((m) => TransactionModel.fromMap(m)).toList());
  }

  // Category operations
  static Future<void> addCategory(CategoryModel category) async {
    if (_db == null) throw StateError('Database not initialized');
    await _db!.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    _categories.add(category);
  }

  static Future<void> updateCategory(int index, CategoryModel category) async {
    if (_db == null) throw StateError('Database not initialized');
    final old = _categories[index];
    await _db!.update('categories', category.toMap(), where: 'id = ?', whereArgs: [old.id]);
    _categories[index] = category;
  }

  static Future<void> deleteCategory(int index) async {
    if (_db == null) throw StateError('Database not initialized');
    final id = _categories[index].id;
    await _db!.delete('categories', where: 'id = ?', whereArgs: [id]);
    _categories.removeAt(index);
  }

  // Account operations
  static Future<void> addAccount(AccountModel account) async {
    if (_db == null) throw StateError('Database not initialized');
    await _db!.insert('accounts', account.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    _accounts.add(account);
  }

  static Future<void> updateAccount(int index, AccountModel account) async {
    if (_db == null) throw StateError('Database not initialized');
    final old = _accounts[index];
    await _db!.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [old.id]);
    _accounts[index] = account;
  }

  static Future<void> deleteAccount(int index) async {
    if (_db == null) throw StateError('Database not initialized');
    final id = _accounts[index].id;
    await _db!.delete('accounts', where: 'id = ?', whereArgs: [id]);
    _accounts.removeAt(index);
  }

  // Transaction operations
  static Future<void> addTransaction(TransactionModel transaction) async {
    if (_db == null) throw StateError('Database not initialized');
    await _db!.insert('transactions', transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    _transactions.add(transaction);

    // Update account balance
    for (int i = 0; i < _accounts.length; i++) {
      final account = _accounts[i];
      if (account.id == transaction.accountId) {
        if (transaction.isExpense) {
          account.balance -= transaction.amount;
        } else {
          account.balance += transaction.amount;
        }
        await _db!.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
        _accounts[i] = account;
        break;
      }
    }
  }

  static Future<void> updateTransaction(int index, TransactionModel transaction) async {
    if (_db == null) throw StateError('Database not initialized');
    final old = _transactions[index];
    await _db!.update('transactions', transaction.toMap(), where: 'id = ?', whereArgs: [old.id]);
    _transactions[index] = transaction;
  }

  static Future<void> deleteTransaction(int index) async {
    if (_db == null) throw StateError('Database not initialized');
    final transaction = _transactions[index];
    // Update account balance (reverse)
    for (int i = 0; i < _accounts.length; i++) {
      final account = _accounts[i];
      if (account.id == transaction.accountId) {
        if (transaction.isExpense) {
          account.balance += transaction.amount;
        } else {
          account.balance -= transaction.amount;
        }
        await _db!.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
        _accounts[i] = account;
        break;
      }
    }

    await _db!.delete('transactions', where: 'id = ?', whereArgs: [transaction.id]);
    _transactions.removeAt(index);
  }
}

class InMemoryBox<T> {
  final List<T> _list;
  InMemoryBox(this._list);

  Iterable<T> get values => _list;
  int get length => _list.length;
  T? getAt(int index) => index >= 0 && index < _list.length ? _list[index] : null;
}
