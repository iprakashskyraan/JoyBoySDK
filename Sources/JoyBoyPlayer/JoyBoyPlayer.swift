//
//  JoyBoyPlayer.swift
//  JoyBoySDK
//
//  Created by Prakash Skyraan on 21/09/24.
//

import SwiftUI
import AVKit
import MediaPlayer

@available(iOS 14.0, *)
public struct JoyBoyPlayer: UIViewControllerRepresentable {
    public var player: AVPlayer
    @Binding public var isLoading: Bool

    @State private var observerAdded: Bool = false

    public init(player: AVPlayer, isLoading: Binding<Bool>) {
        self.player = player
        self._isLoading = isLoading
    }

    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let viewController = AVPlayerViewController()
        viewController.player = player
        viewController.showsPlaybackControls = false

        configureAudioSession()

        if !observerAdded {
            NotificationCenter.default.addObserver(
                context.coordinator,
                selector: #selector(context.coordinator.videoDidEnd(_:)),
                name: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
            DispatchQueue.main.async {
                observerAdded = true
            }
        }

        return viewController
    }

    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.showsPlaybackControls = false
        uiViewController.player = player
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self, $isLoading)
    }

    public static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        if let currentItem = uiViewController.player?.currentItem {
            NotificationCenter.default.removeObserver(
                coordinator,
                name: .AVPlayerItemDidPlayToEndTime,
                object: currentItem
            )
        }
        coordinator.parent.hideMediaControlsInNotificationBanner()
    }

    public class Coordinator: NSObject {
        var parent: JoyBoyPlayer
        @Binding var isLoading: Bool

        init(_ parent: JoyBoyPlayer, _ isLoading: Binding<Bool>) {
            self.parent = parent
            self._isLoading = isLoading
        }

        public override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey : Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            if keyPath == "timeControlStatus", let player = object as? AVPlayer {
                DispatchQueue.main.async { [self] in
                    switch player.timeControlStatus {
                    case .playing:
                        isLoading = false
                        print("Video Playing....")
                    case .waitingToPlayAtSpecifiedRate:
                        isLoading = true
                    case .paused:
                        isLoading = false
                    @unknown default:
                        isLoading = true
                    }
                }
            }
        }

        @objc func videoDidEnd(_ notification: Notification) {
            DispatchQueue.main.async {
                self.parent.player.seek(to: .zero)
                self.parent.player.play()
            }
        }
    }

    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, options: .mixWithOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }

    private func hideMediaControlsInNotificationBanner() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = false
        commandCenter.pauseCommand.isEnabled = false
        commandCenter.stopCommand.isEnabled = false
        commandCenter.togglePlayPauseCommand.isEnabled = false
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
