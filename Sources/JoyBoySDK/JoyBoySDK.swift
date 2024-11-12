//
//  JoyBoySDK.swift
//  JoyBoySDK
//
//  Created by Prakash Skyraan on 12/11/24.
//

@_exported import JoyBoyPlayer
@_exported import JoyBoyLogin
import AVFoundation

@available(iOS 14.0, *)
public struct JoyBoySDK {
    public init() {}

    public func useFeatures() {
        _ = JoyBoyPlayer(player: AVPlayer(), isLoading: .constant(false))

        _ = JoyBoyLogin.apple
    }
}



