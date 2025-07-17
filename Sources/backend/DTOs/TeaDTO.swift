// Created by Sean L. on Jul. 17.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/DTOs/TeaDTO.swift
// 
// Makabaka1880, 2025. All rights reserved.

import Foundation
import Vapor

struct TeaStepDTO: Content {
    let kind: TeaStepKind
    let p1: Float?
    let p2: Float?
    let p3: Float?
    let p4: Float?
    
    init(from step: TeaStep) {
        self.kind = step.kind
        self.p1 = step.p1
        self.p2 = step.p2
        self.p3 = step.p3
        self.p4 = step.p4
    }
}

struct TeaEntryDTO: Content {
    let id: UUID
    let name: String
    let proc: [TeaStepDTO]
    
    init(from entry: TeaEntry) {
        self.id = entry.id
        self.name = entry.name
        self.proc = entry.proc.map { TeaStepDTO(from: $0) }
    }
}
