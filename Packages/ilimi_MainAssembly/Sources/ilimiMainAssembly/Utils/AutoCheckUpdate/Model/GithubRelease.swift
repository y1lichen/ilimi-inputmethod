//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/5/8.
//

import Foundation

struct GitHubRelease: Codable {
    let tagName: String
    let htmlUrl: String
    let name: String
    let id: Int
}
