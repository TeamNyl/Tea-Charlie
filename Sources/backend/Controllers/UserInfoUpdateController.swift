// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Controllers/UserInfoUpdateController.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent
import Logging

struct UserPosition: Content {
    var x: Float
    var y: Float
}

struct UserCoin: Content {
    var coins: Int
}

struct WebSocketMessage: Codable {
    let type: String
    let token: String?
    let position: UserPosition?
}

struct WebSocketResponse: Codable {
    let success: Bool
    let message: String
    let position: UserPosition?
}

actor TokenBox {
    private var token: String? = nil
    
    func setToken(_ token: String?) {
        self.token = token
    }
    
    func getToken() -> String? {
        return self.token
    }
}

struct UserInfoUpdateController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let infoUpdateController = routes.grouped("user")
        infoUpdateController.put("move", use: setPosition)
        infoUpdateController.get("position", use: getPosition)
        infoUpdateController.put("coins", use: setCoins)
        infoUpdateController.get("coins", use: getCoins)
        infoUpdateController.webSocket("position", "ws", onUpgrade: handlePositionWebSocket)
    }

    func setPosition(req: Request) async throws -> Response {
        let logger = req.logger
        let pos = try req.content.decode(UserPosition.self)
        logger.info("Setting user position to (\(pos.x), \(pos.y))")

        guard let token = req.headers.bearerAuthorization?.token else {
            logger.warning("Set position request missing bearer token")
            throw Abort(.unauthorized, reason: "Session key not provided")
        }

        guard let user = try await UserCredentialsManager.verifySessionToken(token, db: req.db) else {
            logger.warning("Set position request with invalid token")
            throw Abort(.forbidden, reason: "Invalid Session key")
        }

        if let userData = user.userData {
            // Update existing userData
            userData.mapX = pos.x
            userData.mapY = pos.y
            try await userData.save(on: req.db)
            logger.info("Updated position for user \(user.id?.description ?? "unknown") to (\(pos.x), \(pos.y))")
        } else {
            // Create new UserData linked to this user
            let newUserData = UserData(userID: try user.requireID())
            newUserData.mapX = pos.x
            newUserData.mapY = pos.y
            try await newUserData.save(on: req.db)
            user.userData = newUserData
            try await user.save(on: req.db)
            logger.info("Created new userData with position (\(pos.x), \(pos.y)) for user \(user.id?.description ?? "unknown")")
        }
        
        let res = Response(status: .ok)
        try res.content.encode(pos)
        return res
    }

    func getPosition(req: Request) async throws -> Response {
        let logger = req.logger
        logger.info("Getting user position")
        
        guard let token = req.headers.bearerAuthorization?.token else {
            logger.warning("Position request missing bearer token")
            throw Abort(.unauthorized, reason: "Session key not provided")
        }

        guard let user = try await UserCredentialsManager.verifySessionToken(token, db: req.db) else {
            logger.warning("Position request with invalid token")
            throw Abort(.forbidden, reason: "Invalid Session key")
        }
        
        guard let userData = user.userData else {
            logger.error("User \(user.id?.description ?? "unknown") has no position data")
            throw Abort(.notFound, reason: "User position data not found")
        }
        
        let x = userData.mapX
        let y = userData.mapY
        
        logger.info("Retrieved position for user \(user.id?.description ?? "unknown"): (\(x), \(y))")

        let res = Response(status: .ok)
        try res.content.encode(UserPosition(x: x, y: y))
        return res
    }

    func setCoins(req: Request) async throws -> UserCoin {
        let logger = req.logger
        let coins = try req.content.decode(UserCoin.self)
        logger.info("Setting user coins to \(coins.coins)")

        guard let token = req.headers.bearerAuthorization?.token else {
            logger.warning("Set coins request missing bearer token")
            throw Abort(.unauthorized, reason: "Session key not provided")
        }

        guard let user = try await UserCredentialsManager.verifySessionToken(token, db: req.db) else {
            logger.warning("Set coins request with invalid token")
            throw Abort(.forbidden, reason: "Invalid Session key")
        }
        
        if let userData = user.userData {
            userData.coins = coins.coins
            try await userData.save(on: req.db)
            logger.info("Updated coins for user \(user.id?.description ?? "unknown") to \(coins.coins)")
        } else {
            let newUserData = UserData(userID: try user.requireID())
            newUserData.coins = coins.coins
            try await newUserData.save(on: req.db)
            user.userData = newUserData
            try await user.save(on: req.db)
            logger.info("Created new userData with coins \(coins.coins) for user \(user.id?.description ?? "unknown")")
        }

        return coins
    }

    func getCoins(req: Request) async throws -> UserCoin {
        let logger = req.logger
        logger.info("Getting user coins")
        
        guard let token = req.headers.bearerAuthorization?.token else {
            logger.warning("Coins request missing bearer token")
            throw Abort(.unauthorized, reason: "Session key not provided")
        }

        guard let user = try await UserCredentialsManager.verifySessionToken(token, db: req.db) else {
            logger.warning("Coins request with invalid token")
            throw Abort(.forbidden, reason: "Invalid Session key")
        }
        
        guard let userData = user.userData else {
            logger.error("User \(user.id?.description ?? "unknown") has no coin data")
            throw Abort(.notFound, reason: "User coin data not found")
        }
        
        logger.info("Retrieved coins for user \(user.id?.description ?? "unknown"): \(userData.coins)")

        return UserCoin(coins: userData.coins)
    }
    
    func handlePositionWebSocket(req: Request, ws: WebSocket) {
        let logger = req.logger
        logger.info("WebSocket connection established")
        
        let tokenBox = TokenBox()
        
        ws.onText { ws, text in
            Task {
                do {
                    let data = text.data(using: .utf8) ?? Data()
                    let decoder = JSONDecoder()
                    
                    if let message = try? decoder.decode(WebSocketMessage.self, from: data) {
                        logger.debug("WebSocket received message type: \(message.type)")
                        switch message.type {
                        case "auth":
                            let newToken = await self.handleAuth(ws: ws, token: message.token, req: req)
                            await tokenBox.setToken(newToken)
                        case "position":
                            if let position = message.position {
                                let currentToken = await tokenBox.getToken()
                                await self.handlePositionUpdate(ws: ws, position: position, token: currentToken, req: req)
                            }
                        default:
                            logger.warning("WebSocket unknown message type: \(message.type)")
                            await self.sendError(ws: ws, message: "Unknown message type")
                        }
                    } else {
                        logger.warning("WebSocket invalid message format")
                        await self.sendError(ws: ws, message: "Invalid message format")
                    }
                } catch {
                    logger.error("WebSocket message processing failed: \(error)")
                    await self.sendError(ws: ws, message: "Failed to process message")
                }
            }
        }
        
        ws.onBinary { ws, buffer in
            Task {
                logger.warning("WebSocket received unsupported binary message")
                await self.sendError(ws: ws, message: "Binary messages not supported")
            }
        }
        
        ws.onClose.whenComplete { _ in
            logger.info("WebSocket connection closed")
        }
    }
    
    private func handleAuth(ws: WebSocket, token: String?, req: Request) async -> String? {
        let logger = req.logger
        logger.info("WebSocket authentication attempt")
        
        guard let token = token else {
            logger.warning("WebSocket authentication missing token")
            await sendError(ws: ws, message: "Token required")
            return nil
        }
        
        do {
            guard let user = try await UserCredentialsManager.verifySessionToken(token, db: req.db) else {
                logger.warning("WebSocket authentication with invalid token")
                await sendError(ws: ws, message: "Invalid token")
                return nil
            }
            
            logger.info("WebSocket authenticated user \(user.id?.description ?? "unknown")")
            await sendSuccess(ws: ws, message: "Authenticated successfully")
            
        } catch {
            logger.error("WebSocket authentication failed: \(error)")
            await sendError(ws: ws, message: "Authentication failed")
        }
        return token
    }
    
    private func handlePositionUpdate(ws: WebSocket, position: UserPosition, token: String?, req: Request) async {
        let logger = req.logger
        logger.info("WebSocket position update to (\(position.x), \(position.y))")
        
        guard let token = token else {
            logger.warning("WebSocket position update missing token")
            await sendError(ws: ws, message: "Token required")
            return
        }
        
        do {
            guard let user = try await UserCredentialsManager.verifySessionToken(token, db: req.db) else {
                logger.warning("WebSocket position update with invalid token")
                await sendError(ws: ws, message: "Invalid token")
                return
            }
            
            if let userData = user.userData {
                userData.mapX = position.x
                userData.mapY = position.y
                try await userData.save(on: req.db)
                logger.info("WebSocket updated position for user \(user.id?.description ?? "unknown") to (\(position.x), \(position.y))")
            } else {
                let newUserData = UserData(userID: try user.requireID())
                newUserData.mapX = position.x
                newUserData.mapY = position.y
                try await newUserData.save(on: req.db)
                user.userData = newUserData
                try await user.save(on: req.db)
                logger.info("WebSocket created new userData with position (\(position.x), \(position.y)) for user \(user.id?.description ?? "unknown")")
            }
            
            await sendPositionResponse(ws: ws, position: position, message: "Position updated successfully")
            
        } catch {
            logger.error("WebSocket position update failed: \(error)")
            await sendError(ws: ws, message: "Failed to update position")
        }
    }
    
    private func sendError(ws: WebSocket, message: String) async {
        let response = WebSocketResponse(success: false, message: message, position: nil)
        if let data = try? JSONEncoder().encode(response),
            let json = String(data: data, encoding: .utf8) {
            try? await ws.send(json)
        }
    }
    
    private func sendSuccess(ws: WebSocket, message: String) async {
        let response = WebSocketResponse(success: true, message: message, position: nil)
        if let data = try? JSONEncoder().encode(response),
            let json = String(data: data, encoding: .utf8) {
            try? await ws.send(json)
        }
    }
    
    private func sendPositionResponse(ws: WebSocket, position: UserPosition, message: String) async {
        let response = WebSocketResponse(success: true, message: message, position: position)
        if let data = try? JSONEncoder().encode(response),
            let json = String(data: data, encoding: .utf8) {
            try? await ws.send(json)
        }
    }
}