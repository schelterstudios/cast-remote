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

    @ObservedObject var model: CastableRowViewModel
    
    var body: some View {
        
        ZStack {
            if model.size == .large {
                RoundedRectangle(cornerRadius: 10).fill(model.themeColor)
            }
        
            HStack(spacing: 10) {
                if model.size >= .medium {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(model.themeColor)
                        ZStack(alignment: .leading) {
                            KFImage(model.thumbURL)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: model.size == .large ? 100 : 60)
                                .cornerRadius(7)
                            if model.icon != nil {
                                ZStack {
                                    Rectangle()
                                        .fill(model.themeColor)
                                        .frame(width: 28, height: model.size == .large ? 100 : 60)
                                    Image(uiImage: model.icon!)
                                }
                            }
                        }
                        .padding(2)
                        .layoutPriority(1)
                    }.layoutPriority(1)
                
                } else if model.size == .small {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(model.themeColor)
                        HStack(spacing: 0) {
                            if model.icon != nil {
                                Image(uiImage: model.icon!)
                            }
                            KFImage(model.providerThumbURL)
                                .resizable()
                                .frame(width: 36, height: 36)
                                .cornerRadius(7)
                        }

                        .padding(.horizontal, 2)
                    }
                    .frame(height: 40)
                }
                
                VStack(spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(model.title)
                                .fontWeight(.bold)
                                .lineLimit(model.size == .large ? 2 : 1)
                            if model.size >= .medium && model.subtitle != nil {
                                Text(model.subtitle!)
                                    .lineLimit(model.size == .large ? 2 : 1)
                            }
                        }
                        Spacer()
                    }
                    HStack(spacing:4) {
                        if model.status != .none {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                HStack(spacing: 4) {
                                    if model.status == .casting {
                                        Image(systemName: "play.fill")
                                        Text("Casting")
                                    } else if model.status == .failed {
                                        Image(systemName: "exclamationmark.triangle")
                                        Text("Failed")
                                    } else {
                                        Image(systemName: "antenna.radiowaves.left.and.right")
                                        Text("Sending")
                                    }
                                }
                                .foregroundColor(model.themeColor)
                                .padding(.horizontal, 8)
                                .frame(height: 20)
                                .layoutPriority(1)
                            }
                        }
                        Spacer()
                        Image(systemName: "eye")
                        Text("\(model.viewCount)")
                    }
                }.layoutPriority(1)
            }
            .font(.caption)
            .foregroundColor(model.size == .large ? Color.white : nil)//Color("castRowDefault"))
            .padding(.trailing, 10)
            .contentShape(Rectangle())
        }
    }
}

struct CastableRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CastableRow(model: CastableRowViewModel(demoDTO: DemoJSON().twitchStreams[0], index: 0, selected: true))
            CastableRow(model: CastableRowViewModel(demoDTO: DemoJSON().twitchStreams[0], index: 1))
            CastableRow(model: CastableRowViewModel(demoDTO: DemoJSON().twitchStreams[0], index: 10))
        }.previewLayout(.fixed(width: 400, height: 120))
    }
}
