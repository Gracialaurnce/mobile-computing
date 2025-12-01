// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/product_data.dart';
import '../widgets/product_card.dart';
import '../widgets/category_filter.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Product> _products;
  late List<Product> _filteredProducts;
  String _selectedCategory = 'All';
  String _sortBy = 'default';
  late TextEditingController _searchController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _products = [];
    _filteredProducts = [];
    _searchController = TextEditingController();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        final products = ProductData.getAllProducts();
        setState(() {
          _products = products;
          _filteredProducts = products;
          _isLoading = false;
        });
      }
    });
  }

  void _filterProducts(String query, String category) {
    setState(() {
      _selectedCategory = category;

      _filteredProducts = _products.where((product) {
        final matchesSearch =
            query.isEmpty ||
            product.productName.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase());

        final matchesCategory =
            category == 'All' ||
            product.categories.any(
              (cat) => cat.toLowerCase().contains(category.toLowerCase()),
            );

        return matchesSearch && matchesCategory;
      }).toList();

      _applySorting();
    });
  }

  void _applySorting() {
    switch (_sortBy) {
      case 'price_low':
        _filteredProducts.sort(
          (a, b) => a.currentPriceValue.compareTo(b.currentPriceValue),
        );
        break;
      case 'price_high':
        _filteredProducts.sort(
          (a, b) => b.currentPriceValue.compareTo(a.currentPriceValue),
        );
        break;
      case 'rating':
        _filteredProducts.sort(
          (a, b) => b.ratingValue.compareTo(a.ratingValue),
        );
        break;
      case 'discount':
        _filteredProducts.sort(
          (a, b) =>
              b.discountPercentageValue.compareTo(a.discountPercentageValue),
        );
        break;
      default:
        // Keep original order
        break;
    }
  }

  void _showSortDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort By',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ...[
                _SortOption('Default', 'default', Icons.sort),
                _SortOption(
                  'Price: Low to High',
                  'price_low',
                  Icons.arrow_upward,
                ),
                _SortOption(
                  'Price: High to Low',
                  'price_high',
                  Icons.arrow_downward,
                ),
                _SortOption('Highest Rating', 'rating', Icons.star),
                _SortOption('Biggest Discount', 'discount', Icons.discount),
              ].map((option) {
                return ListTile(
                  leading: Icon(option.icon, color: Color(0xFF0F4C81)),
                  title: Text(option.title),
                  trailing: _sortBy == option.value
                      ? Icon(Icons.check, color: Color(0xFF0F4C81))
                      : null,
                  onTap: () {
                    setState(() {
                      _sortBy = option.value;
                      _applySorting();
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shopping_bag, size: 28),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ElectroMart',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  'Premium Electronics',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications_none), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
        backgroundColor: Color(0xFF0F4C81),
        elevation: 4,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for cables, TVs, adapters...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF0F4C81),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      onChanged: (value) {
                        _filterProducts(value, _selectedCategory);
                      },
                    ),
                  ),
                  Container(height: 50, width: 1, color: Colors.grey[200]),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: Color(0xFF0F4C81)),
                    onPressed: () {
                      _showSortDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Categories Filter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, color: Color(0xFF0F4C81)),
                    SizedBox(width: 8),
                    Expanded(
                      child: CategoryFilter(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          _filterProducts(_searchController.text, category);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Products Count and Sort
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredProducts.length} Products Found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _showSortDialog(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.sort, size: 18, color: Color(0xFF0F4C81)),
                      SizedBox(width: 4),
                      Text(
                        'Sort',
                        style: TextStyle(
                          color: Color(0xFF0F4C81),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF0F4C81)),
                    ),
                  )
                : _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try different keywords or filters',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: ProductCard(product: product),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSortDialog(context);
        },
        backgroundColor: Color(0xFF0F4C81),
        child: Icon(Icons.tune, color: Colors.white),
        elevation: 4,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Color(0xFF0F4C81),
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _SortOption {
  final String title;
  final String value;
  final IconData icon;

  _SortOption(this.title, this.value, this.icon);
}
