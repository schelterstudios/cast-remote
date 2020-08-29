//
//  FailureMessage.swift
//  Cast Remote
//
//  Created by Steve Schelter on 8/25/20.
//  Copyright © 2020 Schelterstudios. All rights reserved.
//

import SwiftUI

struct FailureMessage: View {
    
    @State var error: Error?
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.bubble")
                .imageScale(.large)
                .foregroundColor(Color.red)
            Text(error?.localizedDescription ?? "Unknown Error")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(Color.red)
        }.padding(.horizontal, 30)
    }
}

struct FailureMessage_Previews: PreviewProvider {
    static var previews: some View {
        FailureMessage()
    }
}
