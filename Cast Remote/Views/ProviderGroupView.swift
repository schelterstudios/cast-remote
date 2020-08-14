//
//  ProviderGroupView.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/11/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI
/*
struct ProviderGroupState {
    var content: PinnedProvidersContent
    var providersModel: AnyViewModel<ProviderListState, ProviderListInput>
}

enum ProviderGroupContent {
    case preinit
    case loaded([ProviderViewModel])
    case failed(Error)
}
*/
struct ProviderGroupView: View {
    
    //@EnvironmentObject var model: AnyViewModel<ProvidersGroupState, Never>
    @State private var showProviders = false
    
    var body: some View {
        NavigationView() {
            VStack {
                Text("Second View")
            }
            .navigationBarTitle(Text("Following List"))
            .navigationBarItems(trailing: Button(action: {
                self.showProviders = true
            }){
                Text("Add")
            }.sheet(isPresented: self.$showProviders) {
                PlatformListView(model: PlatformListViewModel(group: App.current.pinned!).eraseToAnyViewModel(),
                                 isPresented: self.$showProviders)
            })
        }
    }
}

struct ProviderGroupView_Previews: PreviewProvider {
    static var previews: some View {
        ProviderGroupView()
    }
}
