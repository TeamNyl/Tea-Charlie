// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/DTOs/TokenDTO.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Foundation
import Vapor

struct TokenDTO: Content {
    let token: String
    let createdAt: Date?
    
    init(from token: Token) {
        self.token = token.token
        self.createdAt = token.createdAt
    }
}
