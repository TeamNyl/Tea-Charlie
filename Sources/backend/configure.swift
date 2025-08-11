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
import Leaf

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

    app.migrations.add(CreateUser())
    app.migrations.add(CreateLoginSession())
    app.migrations.add(CreateUserData())
    app.migrations.add(CreateRoom())
    app.migrations.add(CreateUserStatus())

    let corsConfig = CORSMiddleware.Configuration(
        allowedOrigin: .any(["http://localhost:5173", "https://user.teacharlie.com"]),
        allowedMethods: [.GET, .POST, .DELETE, .OPTIONS, .PUT],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .cookie, .accessControlAllowOrigin, .accessControlAllowCredentials, .accessControlAllowHeaders, .accessControlAllowMethods],
        allowCredentials: true
    )

    // MARK: Middlewares
    app.middleware.use(CORSMiddleware(configuration: corsConfig), at: .beginning)

    // Register leaf
    app.views.use(.leaf)

    // register routes
    try routes(app)
}
