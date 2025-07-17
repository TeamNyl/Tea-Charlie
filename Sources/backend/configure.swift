// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/configure.swift
// 
// Makabaka1880, 2025. All rights reserved.

import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: SecretsManager.get(.dbHostName)!,
        port: Int(SecretsManager.get(.dbPort)!)!,
        username: SecretsManager.get(.dbUsername)!,
        password: SecretsManager.get(.dbPassword)!,
        database: SecretsManager.get(.dbName)!,
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateUsers())
    
    // register routes
    try routes(app)
}
