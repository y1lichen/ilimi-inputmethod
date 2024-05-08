//
//  File.swift
//
//
//  Created by 陳奕利 on 2024/5/7.
//

import Foundation

// MARK: - GitHubRelease

struct GitHubRelease: Codable {
    let tagName: String
    let name: String
    let id: Int
}

// MARK: - UpdateManager

class UpdateManager {
    static let url = URL(string: "https://api.github.com/repos/y1lichen/ilimi-inputmethod/releases/latest")

    static func getURLData(completion: @escaping (Result<GitHubRelease, Error>) -> Void) {
        let session = URLSession.shared

        // 創建 URLSessionDataTask
        let task = session.dataTask(with: url!) { data, response, error in
            // 檢查是否有錯誤
            if let error = error {
                print("發生錯誤：", error)
                completion(.failure(error))
                return
            }

            // 檢查是否有回應
            guard let httpResponse = response as? HTTPURLResponse else {
                print("無效的回應")
                return
            }

            // 檢查狀態碼
            guard httpResponse.statusCode == 200 else {
                print("無效的狀態碼：", httpResponse.statusCode)
                return
            }

            // 檢查是否有資料
            guard let data = data else {
                print("未收到資料")
                completion(.failure(CustomError.noData))
                return
            }

            // 解析 JSON 回應
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let release = try decoder.decode(GitHubRelease.self, from: data)

                completion(.success(release))
                //				for asset in release.assets {
                //					print("- 名稱：", asset.name)
                //					print("  下載連結：", asset.downloadUrl)
                //				}
            } catch {
                completion(.failure(error))
            }
        }

        // 開始任務
        task.resume()
    }

    // https://leetcode.com/problems/compare-version-numbers/description/
    // 參考leetcode吧
    private static func compareVersion(_ version1: String, _ version2: String) -> Int {
        let v1Components = version1.components(separatedBy: ".")
        let v2Components = version2.components(separatedBy: ".")

        var i = 0

        while i < max(v1Components.count, v2Components.count) {
            let v1 = i < v1Components.count ? Int(v1Components[i]) ?? 0 : 0
            let v2 = i < v2Components.count ? Int(v2Components[i]) ?? 0 : 0

            if v1 < v2 {
                return -1
            } else if v1 > v2 {
                return 1
            }
            i += 1
        }
        return 0
    }

	private static func showPopUp(_ appVer: String, _ remoteVer: String, _ isManual: Bool) {
        var res = compareVersion(appVer, remoteVer)
		if !isManual && res == 0 {
			return
		}
		var displayText = "你己經擁有最新版本\(appVer)"
		if res == 1 {
			displayText = "你擁有的是測試版本\(appVer)。目前發佈版本為\(remoteVer)。"
		} else if res == -1 {
			displayText = "最新版本為\(remoteVer)，你擁有的是測試版本\(appVer)。前往更新吧！"
		}

    }

	static func checkUpdate(_ isManual: Bool = false) {
        var appVer: String = ""
        if let infoDict = Bundle.main.infoDictionary {
            if !infoDict.isEmpty {
                appVer = infoDict["CFBundleShortVersionString"] as! String? ?? "unkown"
            }
        }
        getURLData { result in
            switch result {
            case let .success(data):
                DispatchQueue.main.async {
                    showPopUp(appVer, data.tagName, isManual)
                }

            case let .failure(error):
                DispatchQueue.main.async {
                    NotifierController.notify(message: error.localizedDescription)
                }
            }
        }
    }
}
