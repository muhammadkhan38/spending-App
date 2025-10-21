import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/account_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import 'spending_view.dart';
import 'transactions_view.dart';
import 'categories_view.dart';
import 'account_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize ViewModels
    Get.put(CategoryViewModel());
    Get.put(AccountViewModel());
    Get.put(TransactionViewModel());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(


         // title: const Text('Spending Tracker'),
          elevation: 0,
         // toolbarHeight: 50,
          bottom: TabBar(
            controller: _tabController,
            indicatorWeight: 2.0,          // ↓ makes the indicator thinner
            labelPadding: EdgeInsets.zero, // ↓ reduces text padding
            indicatorPadding: EdgeInsets.zero,



            tabs: const [

              Tab(
                icon: Icon(Icons.pie_chart,size: 20,),
                text: 'Spending',



              ),
              Tab(
                icon: Icon(Icons.receipt_long),
                text: 'Transactions',
              ),
              Tab(
                icon: Icon(Icons.category),
                text: 'Categories',
              ),
              Tab(
                icon: Icon(Icons.account_balance_wallet),
                text: 'Accounts',
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SpendingView(),
          TransactionsView(),
          CategoriesView(),
          AccountView(),
        ],
      ),
    );
  }
}
