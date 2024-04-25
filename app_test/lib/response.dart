import 'package:flutter/material.dart';

class ColorInfoPage extends StatelessWidget {
  final Future<Color?> dominantColor;

  ColorInfoPage(this.dominantColor);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información del Color'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Este es un ejemplo de información relacionada al color.'),
            FutureBuilder<Color?>(
              future:      dominantColor,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  final color = snapshot.data!;
                  return Text("El color fue: $color");
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text('Cargando...'); // Puedes personalizar el texto de carga
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
