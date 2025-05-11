
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:fast_location/src/modules/home/home.dart'; 
import 'dart:async';

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();

    // Usando o Timer para redirecionar para a Home após 3 segundos
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()), // Redireciona para a tela inicial
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Cor de fundo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Adicione aqui o logo ou algum ícone, se necessário
            AnimatedOpacity(
              opacity: 1.0, // Aqui você pode alterar para um valor variável para criar a animação de opacidade
              duration: Duration(seconds: 2), // Duração da animação
              child: Icon(
                Icons.location_on,
                size: 100,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 2),
              child: Text(
                "Fast Location",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}