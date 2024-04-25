import 'dart:ui';

import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  final String enfermedad;
  final String descripcion;
  final List<List<String>> cuidados;
  final Color color;

  const MyHomePage({
    Key? key,
    required this.enfermedad,
    required this.descripcion,
    required this.cuidados,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles del proceso"),
        backgroundColor: color,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  enfermedad,
                  style:
                      const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "¿Qué es?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              Text(descripcion),
              Container(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "¿Cómo nos cuidamos?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              Column(
                children: cuidados
                    .map(
                      (cuidado) => MyExpansionTile(
                        cuidadoNombre: cuidado[0],
                        cuidadoInfo: cuidado[1],
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyExpansionTile extends StatelessWidget {
  final String cuidadoNombre;
  final String cuidadoInfo;

  const MyExpansionTile({
    Key? key,
    required this.cuidadoNombre,
    required this.cuidadoInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        cuidadoNombre,
        style: TextStyle(fontSize: 18.0),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            cuidadoInfo,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }
}
