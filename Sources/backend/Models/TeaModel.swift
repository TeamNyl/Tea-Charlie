// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/Models/TeaModel.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Fluent
import Vapor

enum TeaStepKind: String, Codable, CaseIterable, @unchecked Sendable {
    case pick = "PICK"
    case wither = "WITHER"
    case killGreen = "KILL_GREEN"
    case shakeGreen = "SHAKE_GREEN"
    case roll = "ROLL"
    case dry = "DRY"
    case oxidize = "OXIDIZE"
    case pileFerment = "PILE_FERMENT"
    case sunDry = "SUN_DRY"
}

struct TeaStep: Content, Codable {
    var kind: TeaStepKind
    var p1: Float
    var p2: Float
    var p3: Float
    var p4: Float
}

struct TeaEntry: Content, Codable {
    var id: UUID
    var name: String
    var proc: [TeaStep]
}