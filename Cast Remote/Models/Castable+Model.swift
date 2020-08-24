//
//  Castable+Model.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/22/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation

extension Castable {
    var thumbURL: URL? { thumbRAW.flatMap{ URL(string: $0) } }
    var previewURL: URL? { previewRAW.flatMap{ URL(string: $0) } }
    var castURL: URL? {
        get { castRAW.flatMap{ URL(string: $0) } }
        set { castRAW = newValue?.absoluteString }
    }
}
