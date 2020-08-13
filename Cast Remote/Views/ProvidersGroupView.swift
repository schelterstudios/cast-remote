//
//  ProvidersGroupView.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/11/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI
/*
struct ProvidersGroupState {
    var content: PinnedProvidersContent
    var providersModel: AnyViewModel<ProviderListState, ProviderListInput>
}

enum ProvidersGroupContent {
    case preinit
    case loaded([ProviderViewModel])
    case failed(Error)
}
*/
struct ProvidersGroupView: View {
    
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
                //ProviderListView(model: self.model.state.providersModel)
                ProviderServiceListView(isPresented: self.$showProviders,
                                        model: ProviderServiceListViewModel(group: App.current.pinned!)
                                            .eraseToAnyViewModel())
            })
        }
    }
}

struct ProvidersGroupView_Previews: PreviewProvider {
    static var previews: some View {
        ProvidersGroupView()
    }
}
