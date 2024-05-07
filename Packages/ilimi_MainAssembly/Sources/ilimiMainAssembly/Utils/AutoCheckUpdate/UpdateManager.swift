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

    static func getURLData(completion: @escaping (Result<GitHubRelease, Error>) -> ()) {
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
	
	static func showPopUp(_ appVer: String) {
		
	}

    static func checkUpdate() {
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
                    showPopUp(appVer)
                }

            case let .failure(error):
                DispatchQueue.main.async {
                    NotifierController.notify(message: error.localizedDescription)
                }
            }
        }
    }
}
