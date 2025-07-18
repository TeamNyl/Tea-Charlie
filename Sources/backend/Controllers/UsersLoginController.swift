// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Controllers/UsersController.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Fluent
import Vapor

struct UUIDReturnWrapping: Content {
    var id: String
}

struct UserLoginRequest: Content {
    let identifier: String
    let password: String
}

struct RegisterRequest: Content {
    let email: String
    let password: String
    let username: String
}

struct UserLoginResponse: Content {
    let token: UUID
}

struct UsersController: RouteCollection {
    func boot(routes: any RoutesBuilder) {
        let userRoutes = routes.grouped("auth")
        userRoutes.post("login", use: login)
        userRoutes.post("register", use: register)
        userRoutes.post("logout", use: logout)
        userRoutes.get("validate-session", use: validate)
    }

    func login(req: Request) async throws -> Response {
        // Decode request body directly to UserLoginRequest
        guard let loginRequest = try? req.content.decode(UserLoginRequest.self) else {
            throw Abort(.badRequest, reason: "Malformed request body")
        }
        
        // Authenticate user with your UserManager
        guard let user = try await UserCredentialsManager.authenticateUser(
            identifier: loginRequest.identifier,
            password: loginRequest.password,
            db: req.db
        ) else {
            throw Abort(.forbidden, reason: "Invalid credentials")
        }

        let maxDevices = Int(SecretsManager.get(.maxLoginDevices) ?? "3") ?? 3

        let ttlTime = Double(SecretsManager.get(.loginTokenTTL)!)!
        let ttl = Date().addingTimeInterval(-ttlTime * 24 * 60 * 60)
        let activeTokens = try await Token.query(on: req.db)
            .with(\.$user) {
                $0.with(\.$userData)
            }
            .filter(\.$createdAt > ttl)
            .filter(\.$user.$id == user.id!)
            .count()

        print(activeTokens)

        guard activeTokens < maxDevices else {
            throw Abort(.tooManyRequests, reason: "Maximum number of logged-in devices reached.")
        }

        let tokenString = UUID().uuidString
        let token = Token(userID: try user.requireID(), token: tokenString)
        try await token.save(on: req.db)

        let res = Response(status: .ok)
        try res.content.encode(UUIDReturnWrapping(id: token.token))
        return res
    }

    func logout(req: Request) async throws -> Response {

        guard let logoutRequest = try? req.content.decode(UUIDReturnWrapping.self) else {
            throw Abort(.badRequest, reason: "Malformed request body")
        }
        guard !logoutRequest.id.isEmpty else {
            throw Abort(.badRequest, reason: "Missing logout session key")
        }

        guard let token = try await Token.query(on: req.db).with(\.$user)
            .filter(\.$token == logoutRequest.id)
            .first() else {
            throw Abort(.notFound, reason: "Session not found")
        }

        try await token.delete(on: req.db)

        let res = Response(status: .noContent)
        return res
    }

    func register(req: Request) async throws -> Response {
        guard let contentType = req.headers["Content-Type"].first,
            contentType.contains("application/json"),
            let registerRequest = try? req.content.decode(RegisterRequest.self) else {
            throw Abort(.badRequest, reason: "Content should be JSON")
        }

        
        guard !registerRequest.email.isEmpty,
            !registerRequest.password.isEmpty,
            !registerRequest.username.isEmpty else {
            throw Abort(.badRequest, reason: "Fields cannot be empty")
        }

        let user = User(
            email: registerRequest.email,
            passHash: try EncryptionManager.hashPassword(registerRequest.password), 
            username: registerRequest.username
        )
        
        // Check for repetition
        guard try await User.query(on: req.db)
            .with(\.$userData)
            .filter(\.$email == user.email).count() == 0 else {
            throw Abort(.conflict, reason: "Account email used")
        }

        try await user.save(on: req.db)
        let userID = try user.requireID()

        let userData = UserData(
            userID: userID,
            coins: Int(SecretsManager.get(.defaultCoins)!)!,
            mapX: 0.0,
            mapY: 0.0,
            createdTeas: [],
            achievements: []
        )
        try await userData.save(on: req.db)
        let res = Response(status: .created)
        try res.content.encode(UUIDReturnWrapping(id: userID.uuidString))
        return res
    }

    func validate(req: Request) async throws -> Response {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Session key not provided")
        }

        guard let _ = try await UserCredentialsManager.verifySessionToken(token, db: req.db) else {
            throw Abort(.forbidden)
        }

        return Response(status: .ok);
    }
}