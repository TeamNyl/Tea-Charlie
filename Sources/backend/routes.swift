// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/routes.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: UsersController())
    try app.register(collection: UserInfoUpdateController())
    try app.register(collection: StatisticsRoutes())
}
