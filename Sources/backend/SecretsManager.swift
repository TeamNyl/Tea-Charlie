// Created by Sean L. on Jun. 26.
// Last Updated by Sean L. on Jul. 17.
// 
// Tea Charlie - Backend
// Sources/backend/SecretsManager.swift
// 
// Makabaka1880, 2025. All rights reserved.

#if DEBUG
import SwiftDotenv
#endif
import Foundation

enum Tokens: String, CaseIterable {
    // DB Configs
	case dbDeleteToken      = "DB_DELETE_TOKEN"
	case dbWriteToken       = "DB_WRITE_TOKEN"
	case dbUsername         = "DB_USERNAME"
	case dbPassword         = "DB_PASSWORD"
	case dbHostName         = "DB_HOSTNAME"
    case dbPort             = "DB_PORT"
    case dbName             = "DB_NAME"
	case adminPanelToken    = "ADMIN_PANEL_TOKEN"
	case maintenanceMode    = "MAINTENANCE_MODE"
	case loginTokenTTL      = "LOGIN_TOKEN_TTL"

    // Application level configs
    case maxLoginDevices    = "MAX_LOGIN_DEVICES"
    case defaultCoins       = "DEFAULT_COINS"
}

class SecretsManager {
	static func configure() {
		#if DEBUG
		do {
			try Dotenv.configure()
			print("✅ Loaded .env")
		} catch let e {
			print("⚠️ Could not load .env file \(e)")
		}
		#else
		let secretsPath = "/run/secrets"
		let fm = FileManager.default

		for token in Tokens.allCases {
			let filename = token.rawValue
			let fullPath = secretsPath + "/" + filename

			if fm.fileExists(atPath: fullPath),
				let contents = try? String(contentsOfFile: fullPath, encoding: .utf8) {
				let trimmed = contents.trimmingCharacters(in: .whitespacesAndNewlines)
				setenv(filename, trimmed, 1)
				print("🔐 Loaded secret: \(filename)")
			} else {
				print("⚠️ Missing or unreadable secret: \(filename)")
			}
		}
		#endif
	}

	static func authenticate(token: Tokens, against test: String) -> Bool {
		guard let actual = ProcessInfo.processInfo.environment[token.rawValue] else {
			print("⚠️ Token \(token.rawValue) not found in environment")
			return false
		}

		return actual == test
	}
    static func get(_ token: Tokens) -> String? {
        return ProcessInfo.processInfo.environment[token.rawValue]
    }
}