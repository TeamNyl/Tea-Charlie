// Created by Sean L. on Aug. 8.
// Last Updated by Sean L. on Aug. 8.
// 
// Tea Charlie - Backend
// Sources/backend/Controllers/RoomsController.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent
import Foundation

struct RoomCreationDTO: Content {
    var name: String
}

struct RoomReturningDTO: Content {
    var id: UUID
    var name: String
}

struct RoomsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let roomsRoute = routes.grouped("rooms")
        // Protected routes: Validate session first before access
        roomsRoute.grouped("validate-session").get(use: validate)
        roomsRoute.post("create", use: createRoom)
    }

    func createRoom(req: Request) async throws -> Response {
        // Validate user session from cookies
        let _ = try await validate(req: req)
        
        // Decode request body.
        let roomData: RoomCreationDTO
        do {
            roomData = try req.content.decode(RoomCreationDTO.self)
        } catch {
            throw Abort(.badRequest, reason: "Malformed request body: \(error)")
        }

        // Create and save room.
        guard let sessionKeyStr = req.cookies["sessionToken"],
              let sessionKey = UUID(sessionKeyStr.string),
              let session = try await LoginSession.query(on: req.db)
                  .filter(\.$sessionKey == sessionKey)
                  .first() else {
            throw Abort(.unauthorized, reason: "Invalid session token")
        }

        let room = Room(name: roomData.name, creatorId: session.$user.id)
        try await room.create(on: req.db)

        // Create DTO for response.
        guard let roomId = room.id else {
            throw Abort(.internalServerError, reason: "Failed to get room ID after creation")
        }
        let returningRoom = RoomReturningDTO(id: roomId, name: room.name)

        // Create and encode response.
        let res = Response(status: .created)
        try res.content.encode(returningRoom)
        return res
    }

    func joinRoom(req: Request) async throws -> Response {
        let res = Response(status: .ok)
        return res
    }

    func validate(req: Request) async throws -> Response {
        // Retrieve session token from cookies
        guard let sessionKeyStr = req.cookies["sessionToken"],
              let sessionKey = UUID(sessionKeyStr.string) else {
            throw Abort(.unauthorized, reason: "Session token not provided")
        }

        // Validate session token
        guard let _ = try await UserCredentialsManager.verifySessionToken(sessionKey.uuidString, db: req.db) else {
            throw Abort(.forbidden, reason: "Invalid session token")
        }

        return Response(status: .ok)
    }
}
