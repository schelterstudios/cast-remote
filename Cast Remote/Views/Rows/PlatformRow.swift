//
//  PlatformRow.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI

struct PlatformRow: View {
    
    let model: PlatformRowViewModel
    
    var body: some View {
        HStack {
            Image(uiImage: model.logo)
                .resizable()
                .frame(width: 50, height: 50)
            Text(model.displayName)
            Spacer()
        }
    }
}

struct PlatformRow_Previews: PreviewProvider {
    static var previews: some View {
        PlatformRow(model: PlatformRowViewModel(type: .twitch))
    }
}
