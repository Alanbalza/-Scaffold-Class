import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyBakeryApp());

class MyBakeryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BakeryHomePage(),
    );
  }
}

class BakeryHomePage extends StatefulWidget {
  @override
  _BakeryHomePageState createState() => _BakeryHomePageState();
}

class _BakeryHomePageState extends State<BakeryHomePage> {
  int _selectedIndex = 0;

  List<Widget> _pages = [BakeryProductsPage(), BakeryOrderPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panadería La Delicia'),
        backgroundColor: Colors.brown[400],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bakery_dining),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Pedido',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

// Página de productos de panadería
class BakeryProductsPage extends StatefulWidget {
  @override
  _BakeryProductsPageState createState() => _BakeryProductsPageState();
}

class _BakeryProductsPageState extends State<BakeryProductsPage> {
  Future<List<dynamic>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/productos'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar los productos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(products[index]['image']),
                title: Text(products[index]['title']),
                subtitle: Text("\$${products[index]['price']}"),
              );
            },
          );
        }
      },
    );
  }
}

// Página para hacer un pedido
class BakeryOrderPage extends StatefulWidget {
  @override
  _BakeryOrderPageState createState() => _BakeryOrderPageState();
}

class _BakeryOrderPageState extends State<BakeryOrderPage> {
  final _nameController = TextEditingController();
  final _orderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Tu nombre'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _orderController,
            decoration: InputDecoration(labelText: 'Tu pedido'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              String name = _nameController.text;
              String order = _orderController.text;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gracias $name, tu pedido: "$order" ha sido registrado')),
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.brown),
            ),
            child: Text('Enviar Pedido'),
          ),
        ],
      ),
    );
  }
}
