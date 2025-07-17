// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Controllers/UserInfoUpdateController.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor
import Fluent

struct UserPosition: Content {
    var x: Float
    var y: Float
}

struct UserCoin: Content {
    var coins: Int
}

struct UserInfoUpdateController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let infoUpdateController = routes.grouped("user")
        infoUpdateController.post("move", use: setPosition)
        infoUpdateController.get("position", use: getPosition)
        infoUpdateController.post("coins", use: setCoins)
        infoUpdateController.get("coins", use: getCoins)

    }

    func setPosition(req: Request) async throws -> UserPosition {
        let pos = try req.content.decode(UserPosition.self)

        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.forbidden, reason: "Session key not provided")
        }

        guard let user = try await UserCredentialsManager.verifySessionToken(token, db: req.db) else {
            throw Abort(.forbidden, reason: "Invalid Session key")
        }

        if let _ = user.userData {} else {
            user.userData = .init()
        }

        user.userData!.mapX = pos.x
        user.userData!.mapY = pos.y

        if let userData = user.userData {
            // Update existing userData
            userData.mapX = pos.x
            userData.mapY = pos.y
            try await userData.save(on: req.db)
        } else {
            // Create new UserData linked to this user
            let newUserData = UserData(userID: try user.requireID())
            newUserData.mapX = pos.x
            newUserData.mapY = pos.y
            try await newUserData.save(on: req.db)
        }

        return pos
    }

    func getPosition(req: Request) async throws -> UserPosition {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.forbidden, reason: "Session key not provided")
        }

        guard let user = try await UserCredentialsManager.verifySessionToken(token, db: req.db) else {
            throw Abort(.forbidden, reason: "Invalid Session key")
        }
        let x = user.userData!.mapX
        let y = user.userData!.mapY

        return UserPosition(x: x, y: y)
    }

    func setCoins(req: Request) async throws -> UserCoin {
        let coins = try req.content.decode(UserCoin.self)

        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.forbidden, reason: "Session key not provided")
        }

        guard let user = try await UserCredentialsManager.verifySessionToken(token, db: req.db) else {
            throw Abort(.forbidden, reason: "Invalid Session key")
        }
        if let userData = user.userData {
            userData.coins = coins.coins
            try await userData.save(on: req.db)
        } else {
            let newUserData = UserData(userID: try user.requireID())
            newUserData.coins = coins.coins
            try await newUserData.save(on: req.db)
        }

        try await user.save(on: req.db)
        return coins
    }

    func getCoins(req: Request) async throws -> UserCoin {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.forbidden, reason: "Session key not provided")
        }

        guard let user = try await UserCredentialsManager.verifySessionToken(token, db: req.db) else {
            throw Abort(.forbidden, reason: "Invalid Session key")
        }

        return UserCoin(coins: user.userData!.coins)
    }
}