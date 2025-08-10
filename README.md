# Tea Charlie - Vapor Backend
[![Build and Push Image](https://github.com/ShanghaiHackathon-2025/Tea-Charlie/actions/workflows/ci.yml/badge.svg)](https://github.com/ShanghaiHackathon-2025/Tea-Charlie/actions/workflows/ci.yml)

Tea Charlie is a Swift Vapor web application backend that provides a RESTful API for managing user accounts, authentication, and tea-related game data. The application uses PostgreSQL for data persistence with Fluent ORM.

## Features

- **User Authentication**: JWT-like session token system with multi-device support (up to 3 concurrent sessions)
- **Real-time Updates**: WebSocket integration for live position tracking
- **Game Data Management**: User positions, coins, tea creation, and achievements
- **Statistics**: User and session analytics
- **Security**: Password hashing, token-based authentication, environment-based secrets
- **CORS Support**: Configured for cross-origin requests

## Quick Start

### Prerequisites

- Swift 6.0+
- PostgreSQL database
- Docker (optional, for containerized deployment)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd backend
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your database configuration
   ```

3. **Install dependencies and build**
   ```bash
   swift build
   ```

4. **Run database migrations**
   ```bash
   swift run backend migrate --yes
   ```

5. **Start the server**
   ```bash
   swift run backend serve --env development --hostname 0.0.0.0 --port 8080
   ```

### Docker Development

1. **Start with Docker Compose**
   ```bash
   # Start database and application
   docker compose up app
   
   # Or start only database
   docker compose up db
   ```

2. **Run migrations**
   ```bash
   docker compose run migrate
   ```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_USERNAME` | Database username | - |
| `DB_PASSWORD` | Database password | - |
| `DB_NAME` | Database name | - |
| `DB_HOSTNAME` | Database host | localhost |
| `DB_PORT` | Database port | 5432 |
| `DB_DELETE_TOKEN` | Database deletion operations token | - |
| `DB_WRITE_TOKEN` | Database write operations token | - |
| `ADMIN_PANEL_TOKEN` | Admin panel access token | - |
| `MAX_LOGIN_DEVICES` | Maximum concurrent login sessions per user | 3 |
| `DEFAULT_COINS` | Starting coins for new users | 400 |
| `LOGIN_TOKEN_TTL` | Token time-to-live in days | 7 |

## API Documentation

### Authentication Endpoints (`/auth/`)
- `POST /auth/register` - User registration
- `POST /auth/login` - User authentication  
- `POST /auth/logout` - Session termination
- `GET /auth/validate` - Token validation

### User Data Endpoints (`/user/`)
- `GET /user/position` - Get user position
- `PUT /user/move` - Update user position
- `GET /user/coins` - Get user coins
- `PUT /user/coins` - Update user coins
- `WS /user/position/ws` - Real-time position updates

### Statistics Endpoints (`/stats/`)
- `GET /stats/users` - User and session statistics

Detailed API documentation is available in the [`docs/`](./docs) directory:
- [Authentication API](./docs/user-auth.md)
- [User Info Retrieval](./docs/user-info.md)  
- [User Data Updates](./docs/user-update.md)
- [WebSocket Integration](./docs/user-websocket.md)
- [Statistics API](./docs/statistics.md)

## Architecture

### Core Components

- **Entry Point**: `Sources/backend/entrypoint.swift` - Main application entry point
- **Configuration**: `Sources/backend/configure.swift` - Database setup and middleware
- **Routes**: `Sources/backend/routes.swift` - API route definitions
- **Controllers**: User authentication, data management, and statistics
- **Models**: Core data models with Fluent ORM
- **Migrations**: Database schema definitions

### Database Schema

- **users** - User accounts (email, password, username)
- **tokens** - Session management tokens
- **user_data** - Game data (coins, position, achievements)

## Development Commands

```bash
# Build the application
swift build

# Run in development mode
swift run backend serve --env development --hostname 0.0.0.0 --port 8080

# Run database migrations
swift run backend migrate --yes

# Revert migrations
swift run backend migrate --revert --yes
```

## Docker Commands

```bash
# Build Docker images
docker compose build

# Start services
docker compose up app

# Stop services
docker compose down

# Stop services and remove volumes
docker compose down -v
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a Pull Request

## License

© Makabaka1880, 2025. All rights reserved.