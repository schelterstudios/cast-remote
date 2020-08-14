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
                        .fill(Color.accentColor)
                    //Circle().fill(Color.black)
                    //    .frame(width: 26, height: 26)
                    KFImage(model.thumbURL)
                        .resizable()
                        .frame(width: 26, height: 26)
                        .cornerRadius(7)
                }.frame(width: 30, height: 30)
                Text(model.displayName)
                Spacer()
                if self.model.selected {
                    Image(uiImage: #imageLiteral(resourceName: "Star"))
                        .resizable()
                        .colorMultiply(Color.accentColor)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.model.toggleSelect()
        }
    }
}

struct ProviderRow_Previews: PreviewProvider {
    static var previews: some View {
        ProviderRow(model: ProviderRowViewModel(demoDTO: DemoJSON().twitchChannels[0]))
    }
}
