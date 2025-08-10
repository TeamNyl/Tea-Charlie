// Created by Sean L. on Aug. 10.
// Last Updated by Sean L. on Aug. 10.
// 
// Tea Charlie - Backend
// Sources/backend/Controllers/UserInfoController.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Fluent
import Vapor

struct UserInfoController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let userinfos = routes.grouped("user");
        userinfos.get(use: getUserInfo);
    }

    func getUserInfo(req: Request) async throws -> Response {
        let sessionKey = try await validateSessionToken(req: req);
        let session = try await LoginSession.query(on: req.db)
            .filter(\.$sessionKey == sessionKey)
            .with(\.$user).first()
        guard let user = session?.user else { throw Abort(.notFound, reason: "User not found") }
        let res = Response(status: .ok)
        try res.content.encode(UserPublicDTO(user: user))
        return res
    }

    private func validateSessionToken(req: Request) async throws -> UUID {
        guard let sessionKeyStr = req.cookies["sessionToken"],
              let sessionKey = UUID(sessionKeyStr.string) else {
            throw Abort(.unauthorized, reason: "Session token not provided")
        }
        return sessionKey
    }

    private func validate(req: Request) async throws -> Response {
        let sessionKey = try await validateSessionToken(req: req)

        guard let _ = try await UserCredentialsManager.verifySessionToken(sessionKey.uuidString, db: req.db) else {
            throw Abort(.forbidden)
        }

        return Response(status: .ok)
    }
}