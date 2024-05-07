//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/5/7.
//

import Foundation

// MARK: - CustomError

public enum CustomError {
    case noData, noConnection
}

// MARK: LocalizedError

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noData:
            return "no data"
        case .noConnection:
            return "no connection"
        }
    }
}
