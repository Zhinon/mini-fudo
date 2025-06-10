# Mini Fudo

> Microservicios en Ruby con autenticación segura, asincronismo real y arquitectura escalable.

Mini Fudo es la resolución de un challenge técnico de Fudo. Este proyecto demuestra cómo construir una arquitectura moderna basada en microservicios usando Ruby, con separación de responsabilidades, comunicación asíncrona real con RabbitMQ, autenticación robusta y respuestas comprimidas automáticamente.

---

## Tabla de contenidos

- [Características principales](#características-principales)
- [Instalación](#instalación)
- [Uso básico](#uso-básico)
- [Configuración](#configuración)
- [Arquitectura](#arquitectura)
- [Tecnologías utilizadas](#tecnologías-utilizadas)
- [Documentación adicional](#documentación-adicional)

---

## Características principales

- Autenticación segura con contraseñas hasheadas (con salt) y JWT con expiración a 24hs.
- Creación totalmente asíncrona de productos usando RabbitMQ y múltiples workers.
- Arquitectura modular y desacoplada con separación clara de responsabilidades.
- Escalabilidad horizontal mediante contenedores Docker independientes.
- Respuestas comprimidas automáticamente si el cliente envía `Accept-Encoding: gzip`.
- Claves API internas para proteger comunicaciones entre servicios.
- Migraciones de base de datos automáticas con Sequel.
- Orquestación completa con Docker Compose.

---

## Instalación

1. Clonar el repositorio y ubicarse en la carpeta raíz del proyecto:

    ```bash
    git clone <url-del-repo>
    cd mini-fudo
    ```

2. Levantar los servicios con Docker Compose:

    ```bash
    docker compose up --build -d
    ```

3. Ejecutar las migraciones de base de datos:

    ```bash
    (cd services/auth-service && make migrate)
    (cd services/product-service && make migrate)
    ```

Una vez completado, el API Gateway estará disponible en `http://localhost:8080`.

---

## Uso básico

Registro y obtención de token JWT:

```bash
curl -X POST http://localhost:8080/register \
  -H 'Content-Type: application/json' \
  -d '{"username":"miguel","password":"123456"}'

curl -X POST http://localhost:8080/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"miguel","password":"123456"}'
```

Creación asíncrona de un producto:

```bash
curl -X POST http://localhost:8080/products \
  -H 'Authorization: Bearer <token>' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Coca-Cola"}'
```

Listado de productos:

```bash
curl -X GET http://localhost:8080/products \
  -H 'Authorization: Bearer <token>'
```

Solicitud de respuestas comprimidas con GZIP:

```bash
curl -H 'Authorization: Bearer <token>' \
     -H 'Accept-Encoding: gzip' \
     http://localhost:8080/products -i --compressed
```

> La definición completa de endpoints está en [`openapi.yaml`](services/api-gateway/static/openapi.yaml).

---

## Configuración

Cada servicio define sus variables en un archivo `.env`. Estos archivos ya están configurados para pruebas locales. **Importante:** en entornos reales, nunca subas tus `.env` al repositorio.

---

## Arquitectura

Mini Fudo se compone de microservicios independientes en Ruby, comunicándose entre sí vía HTTP y RabbitMQ. Cada componente está containerizado para permitir despliegue controlado y escalable.

### Componentes

- **API Gateway**: Orquesta peticiones, valida tokens y se comunica con los servicios internos.
- **Auth Service**: Maneja registro de usuarios y autenticación mediante JWT.
- **Product Service**: Permite consultar productos; la creación se realiza de forma diferida.
- **Workers**: Escuchan mensajes en RabbitMQ y crean productos en segundo plano.
- **RabbitMQ**: Broker de mensajes con colas durables y soporte para Dead Letter Queues.
- **PostgreSQL**: Base de datos independiente por servicio.

Consulta [Docs/Architecture.md](/Docs/Architecture.md) para una descripción detallada de los componentes, flujo de mensajes y mecanismos de seguridad

## Tecnologías utilizadas

- **Ruby** (Rack, Sequel)
- **PostgreSQL**
- **RabbitMQ**
- **Docker** + **Docker Compose**
- **OpenAPI 3.0**
- **JWT**

---

## Documentación adicional

- [Definición de Fudo en menos de 100 palabras](./FUDO.md)
- [Definición de HTTP en menos de 50 palabras](./HTTP.md)
- [Definición de TCP en menos de 50 palabras](./TCP.md)
