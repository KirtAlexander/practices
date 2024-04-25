import 'dart:async';
import 'dart:io';
import 'package:app/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:color_models/color_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

const umbral = 150.0;

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  Future<Color?> _analyzeColor() async {
    if (_selectedImage != null) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(FileImage(_selectedImage!));
      final dominantColor = paletteGenerator.dominantColor?.color;

      if (dominantColor != null) {
        return encontrarColorMasCercano(
            dominantColor, coloresPredefinidos, umbral);
      }
    }

    return null;
  }

  Future<Color?> _analyzeColorFromPath(String imagePath) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(FileImage(File(imagePath)));
    return paletteGenerator.dominantColor?.color;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(  
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Toma la foto del pañal'),
        backgroundColor: const Color.fromARGB(255, 157, 195, 231),
      ),
      body: Column(
        
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("Pañal detector de riesgo de enfermedades", textAlign: TextAlign.center,style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 157, 195, 231)
              ),),
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                    child: SizedBox(
                      width: 500,
                      height: 400,
                      child: CameraPreview(_controller),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.getImage(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      Color? analyzedColor =
                          await _analyzeColorFromPath(pickedFile.path);
                      Future<Color?>? futureColor = Future.value(analyzedColor);
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DisplayPictureScreen(
                            imagePath: pickedFile.path,
                            dominantColor: futureColor,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Adjuntar Foto'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _initializeControllerFuture;
                      final image = await _controller.takePicture();

                      if (!mounted) return;
                      setState(() {
                        _selectedImage = File(image.path);
                      });

                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DisplayPictureScreen(
                            imagePath: image.path,
                            dominantColor: _analyzeColor(),
                          ),
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text('Tomar Foto'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final Future<Color?>? dominantColor;

  const DisplayPictureScreen({
    Key? key,
    required this.imagePath,
    required this.dominantColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vista previa de la foto del pañal'),
        backgroundColor: const Color.fromARGB(255, 157, 195, 231),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
            child: AspectRatio(
              aspectRatio: 1.1,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              FutureBuilder<Color?>(
                future: dominantColor,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      final color = snapshot.data!;
                      final colorInfo =
                          EnfermedadesData.obtenerInformacionColor(color);

                      return Column(
                        children: [
                          Text(
                              colorInfo['enfermedad'] ??
                                  'Información Desconocida',
                              style: TextStyle(
                                  color: getColorForText(color),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              colorInfo['descripcion'] ??
                                  'Información Desconocida',
                              style: TextStyle(
                                color: getColorForText(color),
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    Color? analyzedColor = snapshot.data;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyHomePage(
                                          enfermedad: colorInfo['enfermedad'],
                                          descripcion:
                                              colorInfo['descripcion'] ??
                                                  'Información Desconocida',
                                          cuidados: colorInfo['cuidados']
                                                  ?.cast<List<String>>() ??
                                              [],
                                          color: analyzedColor ?? Colors.black,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Confirmar Carga'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Rehacer Foto'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Text("Color no disponible");
                    }
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Text("Cargando...");
                  } else {
                    return const Text("Color no disponible");
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final List<Color> coloresPredefinidos = [
  const Color.fromARGB(255, 243, 117, 14),
  const Color.fromARGB(255, 157, 195, 231),
  const Color.fromARGB(255, 146, 209, 79),
  const Color.fromARGB(255, 0, 255, 0),
];

double calcularDistanciaColorLab(Color color1, Color color2) {
  final labColor1 = RgbColor(
    color1.red / 255,
    color1.green / 255,
    color1.blue / 255,
  ).toLabColor();

  final labColor2 = RgbColor(
    color2.red / 255,
    color2.green / 255,
    color2.blue / 255,
  ).toLabColor();

  final lightnessDiff = (labColor1.lightness - labColor2.lightness).abs();
  final aDiff = (labColor1.a - labColor2.a).abs();
  final bDiff = (labColor1.b - labColor2.b).abs();

  return (lightnessDiff + aDiff + bDiff).toDouble();
}

Color encontrarColorMasCercano(
    Color colorDominante, List<Color> colores, double umbral) {
  Color? colorMasCercano;
  double distanciaMasCorta = double.infinity;

  for (final color in colores) {
    final distancia = calcularDistanciaColorLab(colorDominante, color);
    if (distancia < distanciaMasCorta) {
      distanciaMasCorta = distancia;
      colorMasCercano = color;
    }
  }

  if (distanciaMasCorta <= umbral) {
    return colorMasCercano ?? Colors.transparent;
  } else {
    return Colors.transparent;
  }
}

Color getColorForText(Color colorDominante) {
  return colorDominante;
}

class EnfermedadesData {
  static final Map<Color, Map<String, dynamic>> enfermedades = {
    coloresPredefinidos[0]: {
      'enfermedad': 'Diabetes',
      'descripcion':
          'Es una enfermedad crónica que ocurre cuando el cuerpo no puede producir suficiente insulina o no puede utilizarla eficazmente. La insulina es una hormona que regula el nivel de azúcar en la sangre. Cuando hay un problema con la producción o uso de insulina, el nivel de azúcar en la sangre puede aumentar demasiado y causar problemas de salud a largo plazo.',
      'cuidados': [
        [
          'Mantén un Peso Saludable',
          'Mantener un peso corporal saludable reduce el riesgo de desarrollar diabetes tipo 2. La pérdida de peso puede mejorar la sensibilidad a la insulina y reducir la presión arterial'
        ],
        [
          'Come de Forma Saludable',
          'Adopta una dieta equilibrada y rica en alimentos saludables, como frutas, verduras, granos enteros y proteínas magras. Limita la ingesta de grasas saturadas y evita el consumo excesivo de azúcares y alimentos procesados'
        ],
        [
          'Realiza Actividad Física Regular',
          'El ejercicio regular ayuda a mantener un peso saludable y mejora la sensibilidad a la insulina. Intenta incorporar al menos 150 minutos de actividad aeróbica moderada por semana, como caminar, nadar o andar en bicicleta'
        ],
        [
          'Controla tus Niveles de Azúcar en Sangre',
          'Realiza chequeos regulares de glucosa en sangre, especialmente si tienes factores de riesgo para la diabetes. Esto te ayudará a detectar cualquier problema en una etapa temprana.'
        ],
      ],
    },
    coloresPredefinidos[1]: {
      'enfermedad': 'Insuficiencia renal',
      'descripcion':
          'Afección en la cual los riñones dejan de funcionar y no pueden eliminar los desperdicios y el agua adicional de la sangre, o mantener en equilibrio las sustancias químicas del cuerpo. La insuficiencia renal aguda o grave se presenta repentinamente (por ejemplo, después de una lesión), y puede tratarse y curarse.',
      'cuidados': [
        [
          'Presion arterial saludable',
          'La hipertensión arterial puede dañar los vasos sanguíneos de los riñones. Controlar la presión arterial a través de la dieta, ejercicio y, si es necesario, medicamentos, puede ayudar a prevenir el daño renal'
        ],
        [
          'Controla niveles de glucosa',
          'Mantener niveles de glucosa en sangre dentro del rango normal es esencial para prevenir el daño renal, especialmente en personas con diabetes'
        ],
        [
          'Hidratación Adecuada',
          ' El agua ayuda a eliminar las toxinas del cuerpo y mantiene los riñones funcionando correctamente. La cantidad de agua necesaria puede variar según la edad, el clima y la actividad física, pero como regla general, asegúrate de beber suficientes líquidos.'
        ],
        [
          'Lleva una Dieta Saludable y Equilibrada',
          'Reducir el consumo de sodio y mantener una dieta equilibrada, rica en frutas, verduras, granos enteros y proteínas magras, puede ayudar a prevenir la formación de cálculos renales y reducir la carga sobre los riñones'
        ]
      ],
    },
    coloresPredefinidos[2]: {
      'enfermedad': 'Infeccion en vias urinarias',
      'descripcion':
          'Son enfermedades causadas por la presencia y multiplicación de microorganismos, como bacterias, en el sistema urinario. Estas infecciones pueden afectar diferentes partes del sistema urinario, como la vejiga, los riñones o la uretra. Los síntomas comunes incluyen dolor al orinar, necesidad frecuente de orinar y sensación de ardor',
      'cuidados': [
        ['Buena Higiene Personal', 'Lávate bien las manos después de usar el baño y antes de comer. Al limpiarte después de usar el baño, hazlo de adelante hacia atrás para evitar la transferencia de bacterias desde el área anal al tracto urinario.'],
        ['Bebe Suficiente Agua', 'Mantén una hidratación adecuada. Beber suficiente agua ayuda a diluir la concentración de bacterias en el tracto urinario y favorece la eliminación de toxinas a través de la orina.'],
        ['Evita Retener la Orina', 'No te aguantes las ganas de orinar. Vaciar la vejiga regularmente ayuda a eliminar bacterias que pueden acumularse en el tracto urinario.'],
        ['Usa Ropa Interior de Algodón', 'Opta por ropa interior de algodón y evita prendas ajustadas que puedan retener la humedad. La ropa interior de algodón permite una mejor ventilación y ayuda a mantener seco el área genital.']
      ],
    },
    coloresPredefinidos[3]: {
      'enfermedad': 'Infeccion en vias urinarias',
      'descripcion':
          'Son enfermedades causadas por la presencia y multiplicación de microorganismos, como bacterias, en el sistema urinario. Estas infecciones pueden afectar diferentes partes del sistema urinario, como la vejiga, los riñones o la uretra. Los síntomas comunes incluyen dolor al orinar, necesidad frecuente de orinar y sensación de ardor',
      'cuidados': [
        ['Buena Higiene Personal', 'Lávate bien las manos después de usar el baño y antes de comer. Al limpiarte después de usar el baño, hazlo de adelante hacia atrás para evitar la transferencia de bacterias desde el área anal al tracto urinario.'],
        ['Bebe Suficiente Agua', 'Mantén una hidratación adecuada. Beber suficiente agua ayuda a diluir la concentración de bacterias en el tracto urinario y favorece la eliminación de toxinas a través de la orina.'],
        ['Evita Retener la Orina', 'No te aguantes las ganas de orinar. Vaciar la vejiga regularmente ayuda a eliminar bacterias que pueden acumularse en el tracto urinario.'],
        ['Usa Ropa Interior de Algodón', 'Opta por ropa interior de algodón y evita prendas ajustadas que puedan retener la humedad. La ropa interior de algodón permite una mejor ventilación y ayuda a mantener seco el área genital.']
      ],
    },
  };

  static Map<String, dynamic> obtenerInformacionColor(Color? color) {
    if (color != null) {
      Color colorMasCercano =
          encontrarColorMasCercano(color, coloresPredefinidos, umbral);

      return enfermedades[colorMasCercano] ?? {};
    } else {
      return {};
    }
  }
}
