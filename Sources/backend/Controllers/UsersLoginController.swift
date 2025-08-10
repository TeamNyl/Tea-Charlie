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
    var id: UUID
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

    private func decodeContent<T: Content>(from req: Request) async throws -> T {
        guard let content = try? req.content.decode(T.self) else {
            throw Abort(.badRequest, reason: "Malformed request body")
        }
        return content
    }

    private func validateSessionToken(req: Request) async throws -> UUID {
        guard let sessionKeyStr = req.cookies["sessionToken"],
              let sessionKey = UUID(sessionKeyStr.string) else {
            throw Abort(.unauthorized, reason: "Session token not provided")
        }
        return sessionKey
    }

    private func getMaxDevices() -> Int {
        return Int(SecretsManager.get(.maxLoginDevices) ?? "3") ?? 3
    }

    private func getTokenTTL() -> Double {
        return Double(SecretsManager.get(.loginTokenTTL)!)!
    }

    private func login(req: Request) async throws -> Response {
        let loginRequest = try await decodeContent(from: req) as UserLoginRequest
        
        guard let user = try await UserCredentialsManager.authenticateUser(
            identifier: loginRequest.identifier,
            password: loginRequest.password,
            db: req.db
        ) else {
            throw Abort(.forbidden, reason: "Invalid credentials")
        }

        let maxDevices = getMaxDevices()
        let ttlTime = getTokenTTL()
        let ttl = Date().addingTimeInterval(-ttlTime * 24 * 60 * 60)
        
        let activeTokens = try await LoginSession.query(on: req.db)
            .filter(\.$createdAt > ttl)
            .filter(\.$user.$id == user.id!)
            .count()
        
        print(activeTokens)

        guard activeTokens < maxDevices else {
            throw Abort(.tooManyRequests, reason: "Maximum number of logged-in devices reached.")
        }

        let tokenString = UUID()
        let token = LoginSession(userId: try user.requireID(), sessionKey: tokenString)
        try await token.save(on: req.db)

        let cookie = HTTPCookies.Value(
            string: token.sessionKey.uuidString,
            expires: Date().addingTimeInterval(ttlTime * 24 * 60 * 60),
            maxAge: Int(ttlTime * 24 * 60 * 60),
            path: "/",
            isSecure: true,
            isHTTPOnly: true,
            sameSite: .lax
        )

        let res = Response(status: .ok)
        res.cookies["sessionToken"] = cookie
        return res
    }

    private func logout(req: Request) async throws -> Response {
        let logoutRequest = try await validateSessionToken(req: req);

        guard let token = try await LoginSession.query(on: req.db)
            .filter(\.$sessionKey == logoutRequest)
            .first() else {
            throw Abort(.notFound, reason: "Session not found")
        }

        try await token.delete(on: req.db)
        return Response(status: .noContent)
    }

    private func register(req: Request) async throws -> Response {
        let registerRequest = try await decodeContent(from: req) as RegisterRequest

        guard !registerRequest.email.isEmpty, !registerRequest.password.isEmpty, !registerRequest.username.isEmpty else {
            throw Abort(.badRequest, reason: "Fields cannot be empty")
        }

        let user = User(
            email: registerRequest.email,
            username: registerRequest.username,
            passHash: try EncryptionManager.hashPassword(registerRequest.password)
        )
        
        guard try await User.query(on: req.db)
            .with(\.$userData)
            .filter(\.$email == user.email).count() == 0 else {
            throw Abort(.conflict, reason: "Account email used")
        }

        try await user.save(on: req.db)
        let userID = try user.requireID()

        let userData = UserData(
            userId: userID,
            achievements: []
        )
        try await userData.save(on: req.db)
        
        let res = Response(status: .created)
        try res.content.encode(UUIDReturnWrapping(id: userID))
        return res
    }

    private func validate(req: Request) async throws -> Response {
        let sessionKey = try await validateSessionToken(req: req)

        guard let _ = try await UserCredentialsManager.verifySessionToken(sessionKey.uuidString, db: req.db) else {
            throw Abort(.forbidden)
        }

        return Response(status: .ok)
    }
}