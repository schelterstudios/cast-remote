//
//  ProviderListView.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/9/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI

struct ProviderListState {
    var title: String
    var content: ProviderListContent
}

enum ProviderListContent {
    case preinit
    case loaded([ProviderRowViewModel])
    case failed(Error)
}

enum ProviderListInput {
    case reload(Bool)
    case apply
}

struct ProviderListView: View {

    @Binding var isPresented: Bool
    @ObservedObject var model: AnyViewModel<ProviderListState, ProviderListInput>
    
    // NOTE: - breaking out content due too ViewBuilder limitations
    private var providers: [ProviderRowViewModel]? {
        if case let ProviderListContent.loaded(providers) = model.state.content {
            return providers
        }
        return nil
    }
    private var error: Error? {
        if case let ProviderListContent.failed(error) = model.state.content {
            return error
        }
        return nil
    }
    //
    
    var body: some View {
        VStack {
            
            // failed
            if error != nil {
                Text(error!.localizedDescription)
            
            // loaded
            } else if providers != nil {
                List {
                    ForEach(providers!) { provider in
                        ProviderRow(model: provider)                        
                    }
                }
                .listStyle(GroupedListStyle())
                
            // preinit
            } else {
                Text("Loading...")
            }
        }
        .navigationBarTitle(Text(model.state.title))
        .navigationBarItems(trailing: Button(action: {
            self.model.trigger(.apply)
            self.isPresented = false
        }) {
            Text("Done")
        })
        .onAppear{ self.model.trigger(.reload(true)) }
    }
}

struct ProviderListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProviderListView(isPresented: .constant(true),
                             model: DemoProviderListViewModel(demoDTOs: DemoJSON().twitchChannels).eraseToAnyViewModel())
        }
    }
}
