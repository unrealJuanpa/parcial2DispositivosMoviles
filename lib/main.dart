import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class Registro {
  String titulo;
  String estado;
  String descripcion;

  Registro(
      {required this.titulo, required this.estado, required this.descripcion});
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Registro> registros = [];
  String nc = "❌ No completada";
  String tc = "✅ Finalizada";

  final StreamController<List<Registro>> _streamController =
      StreamController<List<Registro>>();

  @override
  void dispose() {
    // Cerrar el controlador del flujo cuando el widget se elimina
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
                title: Text('My Tasks App 🤠'),
                backgroundColor: Colors.green[700]),
            body: Center(
                child: Column(children: <Widget>[
              Center(
                child: Text(""),
              ),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      // _createModal(context);
                      registroModal(
                          context, 'Crear Tarea', -1, true, '', nc, '');
                    },
                    child: Text("Crear nueva tarea")),
              ),
              Expanded(
                  child: StreamBuilder(
                      stream: _streamController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Registro>? regs = snapshot.data;
                          return ListView.builder(
                            itemCount: regs?.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text('${regs?[index].titulo}'),
                                subtitle: Text('${regs?[index].estado}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          if (registros[index].estado == nc) {
                                            registros[index].estado = tc;
                                            _streamController.add(registros);
                                          } else {
                                            registros[index].estado = nc;
                                            _streamController.add(registros);
                                          }
                                        },
                                        icon: (registros[index].estado == nc)
                                            ? Icon(Icons.check)
                                            : Icon(Icons.close)),
                                    IconButton(
                                        onPressed: () {
                                          registroModal(
                                              context,
                                              'Edición de tarea',
                                              index,
                                              true,
                                              registros[index].titulo,
                                              registros[index].estado,
                                              registros[index].descripcion);
                                        },
                                        icon: Icon(Icons.edit)),
                                    IconButton(
                                        onPressed: () {
                                          registros.removeAt(index);
                                          _streamController.add(registros);
                                        },
                                        icon: Icon(Icons.delete)),
                                  ],
                                ),
                                onTap: () {
                                  registroModal(
                                      context,
                                      'Detalles de tarea',
                                      -1,
                                      false,
                                      registros[index].titulo,
                                      registros[index].estado,
                                      registros[index].descripcion);
                                },
                              );
                            },
                          );
                        } else {
                          // return CircularProgressIndicator();

                          return Text("\nSin tareas :)");
                        }
                      }))
            ]))));
  }

  // '', 0, null

  void registroModal(BuildContext context, String cabezal, int orden,
      bool allowedit, String titulo, String estado, String descripcion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(cabezal),
          ),
          content: Column(children: [
            Text("Datos del registro"),
            Text(""),
            TextFormField(
              enabled: allowedit,
              style: TextStyle(
                color: Colors
                    .black, // Establece el color del texto cuando está deshabilitado
              ),
              initialValue: titulo,
              decoration: InputDecoration(labelText: 'Titulo'),
              onChanged: (value) {
                titulo = value;
              },
            ),
            TextFormField(
              enabled: false,
              style: TextStyle(
                color: Colors
                    .black, // Establece el color del texto cuando está deshabilitado
              ),
              initialValue: estado,
              decoration: InputDecoration(labelText: 'Estado'),
              onChanged: (value) {
                estado = value;
              },
            ),
            TextFormField(
              enabled: allowedit,
              style: TextStyle(
                color: Colors
                    .black, // Establece el color del texto cuando está deshabilitado
              ),
              initialValue: descripcion,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(labelText: 'Descripción'),
              onChanged: (value) {
                descripcion = value;
              },
            ),
          ]),
          actions: <Widget>[
            Visibility(
              visible: allowedit,
              child: TextButton(
                onPressed: () {
                  if (titulo.isNotEmpty &&
                      estado.isNotEmpty &&
                      descripcion.isNotEmpty) {
                    if (orden <= -1) {
                      registros.add(Registro(
                          titulo: titulo,
                          estado: estado,
                          descripcion: descripcion));
                    } else {
                      registros[orden] = Registro(
                          titulo: titulo,
                          estado: estado,
                          descripcion: descripcion);
                    }

                    _streamController.add(registros);
                    Navigator.of(context).pop();
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text("Por favor, complete todos los datos"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cerrar'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Guardar'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
