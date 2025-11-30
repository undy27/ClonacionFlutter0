# Etapa 1: Construcción de la App Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copiar solo los archivos necesarios para las dependencias primero (optimización de caché)
COPY src/pubspec.yaml src/pubspec.lock ./
RUN flutter pub get

# Copiar el resto del código fuente
COPY src/ .

# Construir la aplicación para la web
RUN flutter build web --release

# Etapa 2: Servidor Web (Nginx) para servir la app
FROM nginx:alpine

# Copiar los archivos construidos al directorio de Nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponer el puerto 80
EXPOSE 80

# Iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]
