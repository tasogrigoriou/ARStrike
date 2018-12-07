//
//  UIDevice+Helpers.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 12/6/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import UIKit
import AVFoundation

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
