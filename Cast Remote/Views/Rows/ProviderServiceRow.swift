//
//  ProviderServiceRow.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI

struct ProviderServiceRow: View {
    
    let model: ProviderServiceRowViewModel
    
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

struct ProviderServiceRow_Previews: PreviewProvider {
    static var previews: some View {
        ProviderServiceRow(model: ProviderServiceRowViewModel(type: .twitch))
    }
}
