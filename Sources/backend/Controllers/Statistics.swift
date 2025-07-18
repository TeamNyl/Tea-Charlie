// Created by Sean L. on Jul. 18.
// Last Updated by Sean L. on Jul. 18.
// 
// Tea Charlie - Backend
// Sources/backend/Controllers/Statistics.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

struct StatisticsRoutes: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let statsRoutes = routes.grouped("stats")
        statsRoutes.get("users", use: users)
    }
    func users(req: Request) async throws -> Response {
        let userCount = try await User.query(on: req.db).count()
        let tokenCount = try await Token.query(on: req.db).count()
        
        let res = Response(status: .ok)
        try res.content.encode(["user": userCount, "tokens": tokenCount])
        return res
    }
}