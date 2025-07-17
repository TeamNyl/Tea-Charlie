// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/DTOs/UserDTO.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Foundation
import Vapor

struct UserDTO: Content {
    let id: UUID?
    let email: String
    let username: String?
    let createdAt: Date?
    
    // Init from User model
    init(from user: User) {
        self.id = user.id
        self.email = user.email
        self.username = user.username
        self.createdAt = user.createdAt
    }
}
