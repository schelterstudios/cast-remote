//
//  CastableRow.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/14/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI
import struct Kingfisher.KFImage

struct CastableRow: View {
    
    let model: CastableRowViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            KFImage(model.previewURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(model.title)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        if model.subtitle != nil {
                            Text(model.subtitle!)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
                HStack(spacing:4) {
                    Spacer()
                    Image(systemName: "eye")
                    Text("\(model.viewCount)")
                }
            }
        }
        .font(.caption)
    }
}

struct CastableRow_Previews: PreviewProvider {
    static var previews: some View {
        CastableRow(model: CastableRowViewModel(demoDTO: DemoJSON().twitchStreams[0]))
    }
}
