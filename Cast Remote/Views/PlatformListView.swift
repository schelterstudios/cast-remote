//
//  PlatformListView.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI

struct PlatformListState {
    var platforms: [PlatformRowViewModel]
}

struct PlatformListView: View {
    
    @ObservedObject var model: AnyViewModel<PlatformListState, Never>
    @State var accentColor: Color = Color.blue
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView() {
            List {
                ForEach(model.state.platforms) { platform in
                    NavigationLink(destination: ProviderListView(isPresented: self.$isPresented,
                                                                 accentColor: self.$accentColor,
                                                                 model: platform.submodel)) {
                        PlatformRow(model: platform)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .onAppear{ self.accentColor = Color.blue }
            .navigationBarTitle(Text("Services"))
            .navigationBarItems(leading: Button(action: {
                self.isPresented = false
            }) {
                Text("Cancel")
            })
        }.accentColor(accentColor)
    }
}

fileprivate let previewState = PlatformListState(platforms: [PlatformRowViewModel(type: .twitch)])

struct ProviderServiceListView_Previews: PreviewProvider {
    
    static var previews: some View {
        PlatformListView(model: JustViewState(state: previewState).eraseToAnyViewModel(),
                         isPresented: .constant(true))
    }
}
