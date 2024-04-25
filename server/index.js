const express = require('express');
const app = express();

// Middleware para habilitar CORS
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*'); // Permitir solicitudes desde cualquier origen
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE'); // Métodos permitidos
  res.setHeader('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization'); // Encabezados permitidos
  res.setHeader('Access-Control-Allow-Credentials', true); // Permitir credenciales (cookies, autorización)
  next();
});

// Endpoint para obtener la lista de dispositivos Bluetooth
app.get('/bluetooth/devices', (req, res) => {
  // Aquí deberías obtener la lista de dispositivos Bluetooth
  // Puedes usar alguna biblioteca o herramienta para obtener esta lista
  const devices = [
    { name: 'Dispositivo 1', address: '00:11:22:33:44:55' },
    { name: 'Dispositivo 2', address: '11:22:33:44:55:66' },
    // Agrega más dispositivos según sea necesario
  ];

  // Envía la lista de dispositivos como respuesta en formato JSON
  res.json(devices);
});

// Inicia el servidor en el puerto 8080
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Servidor escuchando en el puerto ${PORT}`);
});
