//
//  ContentView.swift
//  VPN
//
//  Created by Ruslan on 23.01.23.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var vpnStatus = VPNStatus()
    var body: some View {
        NavigationView {
            VStack {
                Text("VPN Status: \(vpnStatus.isConnected ? "Connected" : "Disconnected")")
                    .font(.headline)
                Image(vpnStatus.isConnected ? "connected" : "disconnected")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Button(action: {
                    self.vpnStatus.isConnected.toggle()
                }) {
                    Text(vpnStatus.isConnected ? "Disconnect" : "Connect")
                }.buttonStyle(CustomButtonStyle())
            }
        }
        
    }
}

class VPNStatus: ObservableObject {
    @Published var isConnected = false
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
