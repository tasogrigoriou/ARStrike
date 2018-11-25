//
//  String+Helpers.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 11/21/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation

extension String {
    static func name(_ obj: AnyClass) -> String {
        return NSStringFromClass(obj.self)
    }
}
