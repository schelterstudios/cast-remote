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
            RoundedRectangle(cornerRadius: 15)
                .fill(self.model.selected ? Color.purple : Color.white)
                .frame(height: 30)
            HStack {
                ZStack {
                    Circle().fill(Color.purple)
                    Circle().fill(Color.black)
                        .frame(width: 26, height: 26)
                    KFImage(model.thumbURL)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .cornerRadius(25)
                }.frame(width: 30, height: 30)
                Text(model.displayName)
                Spacer()
            }
        }.onTapGesture {
            self.model.toggleSelect()
        }
    }
}

struct ProviderRow_Previews: PreviewProvider {
    static var previews: some View {
        ProviderRow(model: ProviderRowViewModel(demoDTO: DemoJSON().twitchChannels[0]))
    }
}
