//
//  ProviderGroupView.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/11/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI

struct ProviderGroupState {
    var title: String
    var providers: [ProviderRowViewModel]
    var platformListModel: AnyViewModel<PlatformListState, Never>
}
/*
enum ProviderGroupContent {
    case preinit
    case loaded([ProviderViewModel])
    case failed(Error)
}
*/

enum ProviderGroupInput {
    case reload
    case moveRows(IndexSet, Int)
    case deleteRows(IndexSet)
}

struct ProviderGroupView: View {
    
    @EnvironmentObject var model: AnyViewModel<ProviderGroupState, ProviderGroupInput>
    @State private var showProviders = false
    @State private var editMode = true
    
    var body: some View {
        NavigationView() {
            List {
                ForEach(model.state.providers) { provider in
                    ProviderRow(model: provider)
                }
                .onDelete { self.model.trigger(.deleteRows($0)) }
                .onMove{ self.model.trigger(.moveRows($0, $1)) }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text(model.state.title))
        .navigationBarItems(leading: Button(action: {
                self.showProviders = true
            }){
                Image(systemName: "plus").imageScale(.large)
            }.sheet(isPresented: self.$showProviders) {
                PlatformListView(model: self.model.state.platformListModel, isPresented: self.$showProviders)
                    .onDisappear{ self.model.trigger(.reload) }
            }, trailing: EditButton())
        }
        .onAppear{ self.model.trigger(.reload) }
    }
}

fileprivate let previewState = ProviderGroupState(title: "Watchlist",
                                                  providers: DemoJSON().twitchChannels.map{ ProviderRowViewModel(demoDTO: $0) },
                                                  platformListModel: JustViewState<PlatformListState, Never>(state: PlatformListState(platforms: [])).eraseToAnyViewModel())

struct ProviderGroupView_Previews: PreviewProvider {
    static var previews: some View {
        ProviderGroupView()
            .environmentObject(JustViewState<ProviderGroupState, ProviderGroupInput>(state: previewState)
                .eraseToAnyViewModel())
    }
}
