//
//  Int+Helpers.swift
//  ARStrike
//
//  Created by Taso Grigoriou on 12/12/18.
//  Copyright © 2018 Taso Grigoriou. All rights reserved.
//

import Foundation

extension Int {
    func isMultipleOfThree() -> Bool {
        return self % 3 == 0
    }
    
    func isMultipleOfSix() -> Bool {
        return self % 6 == 0
    }
}
