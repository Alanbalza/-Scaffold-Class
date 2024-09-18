import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Flores',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Flutter Flores App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.local_florist), text: 'Catálogo'),
            Tab(icon: Icon(Icons.add), text: 'Registrar Flor'),
            Tab(icon: Icon(Icons.contact_mail), text: 'Contacto'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CatalogTab(),       // Catálogo de flores
          RegisterFlowerTab(), // Registro de flores
          const ContactTab(),  // Información de contacto
        ],
      ),
    );
  }
}

class CatalogTab extends StatefulWidget {
  @override
  _CatalogTabState createState() => _CatalogTabState();
}

class _CatalogTabState extends State<CatalogTab> {
  late Future<List<dynamic>> flores;

  @override
  void initState() {
    super.initState();
    flores = fetchFlores();
  }

  Future<List<dynamic>> fetchFlores() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/flores')); // Ajusta la URL de tu API
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar las flores');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: flores,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var flor = snapshot.data![index];
              return ListTile(
                leading: Icon(Icons.local_florist, color: Colors.green),
                title: Text(flor['nombre']),
                subtitle: Text(flor['descripcion']),
              );
            },
          );
        } else {
          return const Center(child: Text('No hay flores disponibles.'));
        }
      },
    );
  }
}

class RegisterFlowerTab extends StatefulWidget {
  @override
  _RegisterFlowerTabState createState() => _RegisterFlowerTabState();
}

class _RegisterFlowerTabState extends State<RegisterFlowerTab> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _descripcion = '';

  Future<void> submitFlower() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/flores'), // Ajusta la URL de tu API
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': _nombre,
          'descripcion': _descripcion,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flor registrada con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar la flor')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre de la Flor'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nombre de la flor';
                }
                return null;
              },
              onSaved: (value) {
                _nombre = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Descripción'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la descripción';
                }
                return null;
              },
              onSaved: (value) {
                _descripcion = value!;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
            onPressed: submitFlower,
              style: ElevatedButton.styleFrom(
               backgroundColor: Colors.green, // Cambia 'primary' por 'backgroundColor'
               ),
               child: const Text('Registrar Flor'),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactTab extends StatelessWidget {
  const ContactTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.contact_mail, size: 100, color: Colors.green),
          SizedBox(height: 20),
          Text(
            'Contacto: contacto@floreria.com',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(
            'Teléfono: +123 456 7890',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
