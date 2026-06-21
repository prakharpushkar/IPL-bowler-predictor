# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Build for web
RUN flutter build web --release

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy built web app from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
