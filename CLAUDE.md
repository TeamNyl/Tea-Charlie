# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tea Charlie is a Swift Vapor web application backend that provides a RESTful API for managing user accounts, authentication, and tea-related game data. The application uses PostgreSQL for data persistence with Fluent ORM.

## Architecture

### Core Components

- **Entry Point**: `Sources/backend/entrypoint.swift` - Main application entry point using async/await
- **Configuration**: `Sources/backend/configure.swift` - Database setup, middleware, and application configuration
- **Routes**: `Sources/backend/routes.swift` - API route definitions and controller registration (UsersController, UserInfoUpdateController, StatisticsRoutes)
- **Secrets Management**: `Sources/backend/SecretsManager.swift` - Environment variable and secrets handling

### Data Layer

- **Models**: Core data models (User, Auth, TeaModel, Achievements, Data)
- **DTOs**: Data transfer objects for API requests/responses (UserDTO, TeaDTO, UserDataDTO, TokenDTO)
- **Services**: UserManager and Hasher utilities in `Sources/backend/Controllers/Services/`
- **Migrations**: Database schema definitions in `Sources/backend/Migrations/SetupDB.swift`

### Controllers

- **UsersLoginController**: Authentication endpoints (/auth/register, /auth/login, /auth/logout, /auth/validate)
- **UserInfoUpdateController**: User data management with WebSocket support for real-time position updates
  - REST endpoints: PUT /user/move, GET /user/position, PUT /user/coins, GET /user/coins
  - WebSocket endpoint: /user/position/ws for real-time position tracking
- **StatisticsRoutes**: Application statistics and metrics

### Database Schema

The application uses three main tables:
- `users` - User accounts with email, password hash, username
- `tokens` - Session management tokens
- `user_data` - Game data including coins, map position, created teas, achievements

## Development Commands

### Local Development

```bash
# Build the application
swift build

# Run in development mode
swift run backend serve --env development --hostname 0.0.0.0 --port 8080

# Run database migrations
swift run backend migrate
```

### Docker Development

```bash
# Build Docker images
docker compose build

# Start the application with database
docker compose up app

# Start only the database
docker compose up db

# Run migrations in Docker
docker compose run migrate

# Stop all services
docker compose down

# Stop all services and remove volumes
docker compose down -v
```

### Database Operations

```bash
# Run migrations
swift run backend migrate --yes

# Revert migrations
swift run backend migrate --revert --yes
```

## Configuration

### Environment Variables

Required environment variables (see `.env` for development):
- `DB_USERNAME`, `DB_PASSWORD`, `DB_NAME`, `DB_HOSTNAME`, `DB_PORT` - Database connection
- `DB_DELETE_TOKEN`, `DB_WRITE_TOKEN` - Database operation tokens
- `ADMIN_PANEL_TOKEN` - Admin panel access token
- `MAX_LOGIN_DEVICES` - Maximum concurrent login sessions per user (default: 3)
- `DEFAULT_COINS` - Starting coins for new users (default: 400)
- `LOGIN_TOKEN_TTL` - Token time-to-live in days (default: 7)

### Secrets Management

- **Development**: Uses SwiftDotenv to load `.env` file
- **Production**: Reads secrets from `/run/secrets/` directory (Docker secrets)

## Key Features

- **Authentication**: JWT-like session token system with multi-device support
- **CORS**: Configured for cross-origin requests
- **Database**: PostgreSQL with Fluent ORM and proper migrations
- **Tea Game Logic**: Support for tea creation steps, achievements, and user progression
- **WebSocket Integration**: Real-time position tracking with /user/position/ws endpoint
- **Security**: Password hashing, token-based authentication, environment-based secrets

## API Documentation

#### Authentication Routes (/auth/)
- POST /auth/register - User registration
- POST /auth/login - User authentication
- POST /auth/logout - Session termination
- POST /auth/validate - Token validation

#### User Data Routes (/user/)
- PUT /user/move - Update user position
- GET /user/position - Get user position
- PUT /user/coins - Update user coins
- GET /user/coins - Get user coins
- WebSocket /user/position/ws - Real-time position updates

#### Statistics Routes
- Various statistics and metrics endpoints

Detailed API documentation is available in the `docs/` directory (if present)

## Dependencies

- **Vapor 4.115.0+** - Web framework
- **Fluent 4.9.0+** - ORM
- **FluentPostgresDriver 2.8.0+** - PostgreSQL driver
- **SwiftNIO 2.65.0+** - Networking
- **SwiftDotenv 2.0.0+** - Environment configuration