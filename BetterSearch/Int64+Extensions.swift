//
//  Int64+Extensions.swift
//  BetterSearch
//
//  Created by Mac on 8/2/19.
//  Copyright © 2019 FiniteLoop. All rights reserved.
//

import Foundation

extension Int64{
    func date() -> String {
        let date = Date(timeIntervalSinceReferenceDate: TimeInterval(self/1000000000))
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df.string(from: date)
    }
}
