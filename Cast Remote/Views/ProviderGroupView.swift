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
            VStack {
                if model.state.providers.count > 0 {
                    List {
                        ForEach(model.state.providers) { provider in
                            ProviderRow(model: provider)
                        }
                        .onDelete { self.model.trigger(.deleteRows($0)) }
                        .onMove{ self.model.trigger(.moveRows($0, $1)) }
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.accentColor.opacity(0.5))
                            .saturation(0.2)
                        VStack {
                            Image(systemName: "eye.slash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 80)
                                .foregroundColor(Color.white)
                            Text("Your list is empty.")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.white)
                            Text("Tap + to add providers!")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color.white)
                        }
                    }.frame(width: 200, height: 200)
                }
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
        }, trailing: model.state.providers.count > 0 ? EditButton() : nil)
        }
        .onAppear{ self.model.trigger(.reload) }
    }
}

fileprivate let emptyState = ProviderGroupState(title: "Watchlist", providers: [],
                                                platformListModel: JustViewState<PlatformListState, Never>(state: PlatformListState(platforms: [])).eraseToAnyViewModel())

fileprivate let previewState = ProviderGroupState(title: "Watchlist",
                                                  providers: DemoJSON().twitchChannels.map{ ProviderRowViewModel(demoDTO: $0) },
                                                  platformListModel: JustViewState<PlatformListState, Never>(state: PlatformListState(platforms: [])).eraseToAnyViewModel())

struct ProviderGroupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProviderGroupView()
                .environmentObject(JustViewState<ProviderGroupState, ProviderGroupInput>(state: emptyState)
                    .eraseToAnyViewModel())
            
            ProviderGroupView()
                .environmentObject(JustViewState<ProviderGroupState, ProviderGroupInput>(state: previewState)
                    .eraseToAnyViewModel())
        }
    }
}
