import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:fast_location/src/modules/history/page/history_page.dart';
import 'package:hive_flutter/hive_flutter.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String resultado = '';
  TextEditingController txtcep = TextEditingController();
  late Box<String> box;
  bool isLoading = false;
  bool cepNaoEncontrado = false;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    box = await Hive.openBox<String>('history');
  }

  void buscacep() async {
    setState(() {
      isLoading = true;
      resultado = '';
      cepNaoEncontrado = false;
    });

    String cep = txtcep.text.trim();
    String url = "https://viacep.com.br/ws/$cep/json/";

    try {
      http.Response response = await http.get(Uri.parse(url));
      Map<String, dynamic> dados = json.decode(response.body);

      // Verifica se há erro ou campos essenciais nulos
      if (dados.containsKey('erro') ||
          dados["logradouro"] == null ||
          dados["bairro"] == null ||
          dados["localidade"] == null ||
          dados["uf"] == null) {
        setState(() {
          resultado = "CEP não encontrado.";
          cepNaoEncontrado = true;
        });
      } else {
        String endereco =
            "${dados["logradouro"]}, ${dados["bairro"]}, ${dados["localidade"]}-${dados["uf"]} | CEP: ${dados["cep"]}";

        box.add(endereco);

        setState(() {
          resultado = endereco;
          cepNaoEncontrado = false;
        });
      }
    } catch (e) {
      setState(() {
        resultado = "Cep não encontrado.";
        cepNaoEncontrado = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Consulta de CEP")),
      body: FutureBuilder(
        future: _initializeHive(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar o Hive: ${snapshot.error}'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Consulta de CEP",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: txtcep,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Digite o CEP",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text("Consultar"),
                    onPressed: buscacep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (resultado.isNotEmpty)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: cepNaoEncontrado ? Colors.red[100] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          resultado,
                          style: TextStyle(
                            fontSize: 16,
                            color: cepNaoEncontrado ? Colors.red[800] : Colors.black,
                            fontWeight: cepNaoEncontrado ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text("Ver Histórico Completo"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Últimas Consultas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (context, Box<String> box, _) {
                      if (box.isEmpty) {
                        return const Center(child: Text('Nenhum histórico encontrado.'));
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: box.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.location_city),
                                title: Text(box.getAt(index) ?? ''),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}