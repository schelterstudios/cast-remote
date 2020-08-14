//
//  TwitchChannelRow.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/9/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI
import struct Kingfisher.KFImage

struct ProviderRow: View {
    
    @ObservedObject var model: ProviderRowViewModel
    @State var testSelect = false
    
    var body: some View {
        ZStack {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(model.themeColor)
                    HStack(spacing: 0) {
                        if model.icon != nil {
                            Image(uiImage: model.icon!)
                        }
                        KFImage(model.thumbURL)
                            .resizable()
                            .frame(width: 26, height: 26)
                            .cornerRadius(7)
                    }

                    .padding(.horizontal, 2)
                }.frame(height: 30)
                Text(model.displayName)
                    .layoutPriority(2)
                Spacer()
                    .layoutPriority(1)
                if self.model.selected {
                    Image(systemName: "checkmark.square")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

struct ProviderRow_Previews: PreviewProvider {
    static var previews: some View {
        ProviderRow(model: ProviderRowViewModel(demoDTO: DemoJSON().twitchChannels[0]))
    }
}
