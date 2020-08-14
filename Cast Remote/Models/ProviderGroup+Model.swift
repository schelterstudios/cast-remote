//
//  ProviderGroup+Model.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/14/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import Foundation

extension ProviderGroup {
    
    func moveProviders(fromOffsets: IndexSet, toOffset: Int) {
        guard var arr = providers?.array else { return }
        arr.move(fromOffsets: fromOffsets, toOffset: toOffset)
        self.providers = NSOrderedSet(array: arr)
    }
}
