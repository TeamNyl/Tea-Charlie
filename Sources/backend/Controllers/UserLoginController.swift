// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Controllers/UserLoginController.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Fluent
import Vapor

struct UserLoginController: RouteCollection {
    func boot(routes: any RoutesBuilder) {
        let userLogins = routes.grouped("login")

    }

    func login(req: Request) throws -> UUID {
        guard let contentType = req.headers["Content-Type"],
        contentType.contains("application/json"), 
        let bytes = req.body.bytes else {
            throw Abort(.badRequest, "Content should be JSON")
        }
        let json = try JSON(bytes: bytes)
        print("Got JSON: \(json)")

    }
}