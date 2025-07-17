// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Models/Responses.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Vapor

struct BasicHTTPResWithStatus: Content {
    let code: Int
    let message: String
}