//
//  ContentView.swift
//  VPN
//
//  Created by Ruslan on 23.01.23.
//

import SwiftUI

struct ContentView: View {
    @State private var buttonTapped = false
    
    var body: some View {
        VStack {
            Button("Connect VPN") {
                buttonTapped.toggle()
            }
            if buttonTapped {
                Text("VPN proccesing")
                    .font(.largeTitle)
            }
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
