// (c) 2022 and onwards The ilimi-IME Project (3-Clause BSD license).
// ====================
// This code is released under the 3-Clause BSD license (SPDX-License-Identifier: BSD-3-Clause)

import AppKit
import SwiftUI

public struct MainView: View {
    // MARK: Lifecycle

    public init() {
        if FileManager.default.fileExists(atPath: kTargetPartialPath) {
            let currentBundle = Bundle(path: kTargetPartialPath)
            let shortVersion = currentBundle?.infoDictionary?["CFBundleShortVersionString"] as? String
            let currentVersion = currentBundle?.infoDictionary?[kCFBundleVersionKey as String] as? String
            if shortVersion != nil, let currentVersion = currentVersion,
               currentVersion.compare(installingVersion, options: .numeric) == .orderedAscending {
                self.isUpgrading = true
            }
        }
    }

    // MARK: Public

    public var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        if let icon = NSImage(named: "IconSansMargin") {
                            Image(nsImage: icon).resizable().frame(width: 90, height: 90)
                        }
                        VStack(alignment: .leading) {
                            HStack {
                                Text("i18n:installer.APP_NAME").fontWeight(.heavy).lineLimit(1)
                                Text("v\(versionString) Build \(installingVersion)").lineLimit(1)
                            }.fixedSize()
                            Text(Self.strCopyrightLabel).font(.custom("Tahoma", size: 11))
                            Text("i18n:installer.DEV_CREW").font(.custom("Tahoma", size: 11)).padding([.vertical], 2)
                        }
                    }
                    GroupBox(label: Text("i18n:installer.LICENSE_TITLE")) {
                        ScrollView(.vertical, showsIndicators: true) {
                            HStack {
                                Text(eulaContent).textSelection(.enabled)
                                    .frame(maxWidth: 455)
                                    .font(.custom("Tahoma", size: 11))
                                Spacer()
                            }
                        }.padding(4).frame(height: 128)
                    }
                    Text("i18n:installer.EULA_PROMPT_NOTICE").bold().padding(.bottom, 2)
                }
                Divider()
                HStack(alignment: .top) {
                    Text("i18n:installer.REPO_URL_TEXT")
                        .font(.custom("Tahoma", size: 11))
                        .opacity(0.5)
                        .frame(maxWidth: .infinity)
                    VStack(spacing: 4) {
                        Button { installationButtonClicked() } label: {
                            Text(isUpgrading ? "i18n:installer.DO_APP_UPGRADE" : "i18n:installer.ACCEPT_INSTALLATION")
                                .bold().frame(width: 114)
                        }
                        .keyboardShortcut(.defaultAction)
                        .disabled(!isCancelButtonEnabled)
                        Button(role: .cancel) { NSApp.terminateWithDelay() } label: {
                            Text("i18n:installer.CANCEL_INSTALLATION").frame(width: 114)
                        }
                        .keyboardShortcut(.cancelAction)
                        .disabled(!isAgreeButtonEnabled)
                    }.fixedSize(horizontal: true, vertical: true)
                }
                Spacer()
            }
            .font(.custom("Tahoma", size: 12))
            .padding(4)
        }
        // ALERTS
        .alert(AlertType.installationFailed.title, isPresented: $isShowingAlertForFailedInstallation) {
            Button(role: .cancel) { NSApp.terminateWithDelay() } label: { Text("Cancel") }
        } message: {
            Text(AlertType.installationFailed.message)
        }
        .alert(AlertType.missingAfterRegistration.title, isPresented: $isShowingAlertForMissingPostInstall) {
            Button(role: .cancel) { NSApp.terminateWithDelay() } label: { Text("Abort") }
        } message: {
            Text(AlertType.missingAfterRegistration.message)
        }
        .alert(currentAlertContent.title, isPresented: $isShowingPostInstallNotification) {
            Button(role: .cancel) { NSApp.terminateWithDelay() } label: {
                Text(currentAlertContent == .postInstallWarning ? "Continue" : "OK")
            }
        } message: {
            Text(currentAlertContent.message)
        }
        // SHEET FOR STOPPING THE OLD VERSION
        .sheet(isPresented: $pendingSheetPresenting) {
            // TODO: Tasks after sheet gets closed by `dismiss()`.
        } content: {
            Text("i18n:installer.STOPPING_THE_OLD_VERSION").frame(width: 407, height: 144)
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        if Reloc.isAppBundleTranslocated(atPath: kTargetPartialPath) == false {
                            pendingSheetPresenting = false
                            isTranslocationFinished = true
                            installInputMethod(
                                previousExists: true,
                                previousVersionNotFullyDeactivatedWarning: false
                            )
                        }
                        timeRemaining -= 1
                    } else {
                        pendingSheetPresenting = false
                        isTranslocationFinished = false
                        installInputMethod(
                            previousExists: true,
                            previousVersionNotFullyDeactivatedWarning: true
                        )
                    }
                }
        }
        // OTHER
        .padding(12)
        .frame(width: 533, alignment: .topLeading)
        .navigationTitle(mainWindowTitle)
        .fixedSize()
        .foregroundStyle(Color(nsColor: NSColor.textColor))
        .background(Color(nsColor: NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(
            minWidth: 533,
            idealWidth: 533,
            maxWidth: 533,
            minHeight: 386,
            idealHeight: 386,
            maxHeight: 386,
            alignment: .top
        )
    }

    // MARK: Internal

    static let strCopyrightLabel = Bundle.main
        .localizedInfoDictionary?["NSHumanReadableCopyright"] as? String ?? "BAD_COPYRIGHT_LABEL"

    @State var pendingSheetPresenting = false
    @State var isShowingAlertForFailedInstallation = false
    @State var isShowingAlertForMissingPostInstall = false
    @State var isShowingPostInstallNotification = false
    @State var currentAlertContent: AlertType = .nothing
    @State var isCancelButtonEnabled = true
    @State var isAgreeButtonEnabled = true
    @State var isPreviousVersionNotFullyDeactivated = false
    @State var isTranslocationFinished: Bool?
    @State var isUpgrading = false

    var translocationRemovalStartTime: Date?

    @State var timeRemaining = 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func installationButtonClicked() {
        isCancelButtonEnabled = false
        isAgreeButtonEnabled = false
        removeThenInstallInputMethod()
    }
}
