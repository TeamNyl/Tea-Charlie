import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: SecretsManager.get(.dbHostName),
        port: SecretsManager.get(.dbPort),
        username: SecretsManager.get(.dbUsername),
        password: SecretsManager.get(.dbPassword),
        database: SecretsManager.get(.dbName),
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateUsers())
    
    // register routes
    try routes(app)
}
