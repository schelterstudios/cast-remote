//
//  ProviderServiceListView.swift
//  ChromeCast Remote
//
//  Created by Steve Schelter on 8/12/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI

struct ProviderServiceListState {
    var services: [ProviderServiceRowViewModel]
}

struct ProviderServiceListView: View {
    
    @Binding var isPresented: Bool
    @ObservedObject var model: AnyViewModel<ProviderServiceListState, Never>
    
    var body: some View {
        NavigationView() {
            List {
                ForEach(model.state.services) { service in
                    NavigationLink(destination: ProviderListView(isPresented: self.$isPresented, model: service.submodel)) {
                        ProviderServiceRow(model: service)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Services"))
            .navigationBarItems(leading: Button(action: {
                self.isPresented = false
            }) {
                Text("Cancel")
            })
        }
    }
}

struct ProviderServiceListView_Previews: PreviewProvider {
    
    static var previews: some View {
        ProviderServiceListView(isPresented: .constant(true),
                                model: DemoProviderServiceListViewModel().eraseToAnyViewModel())
    }
}
