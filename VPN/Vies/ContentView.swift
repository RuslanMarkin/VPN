//
//  ContentView.swift
//  VPN
//
//  Created by Ruslan on 23.01.23.
//

import SwiftUI
import NetworkExtension


struct ContentView: View {
    @ObservedObject var vpnStatus = VPNStatus()
    @State private var showSheet = false
    var body: some View {
        NavigationView {
            VStack {
                Text("VPN Status: \(vpnStatus.isConnected ? "Connected" : "Disconnected")")
                    .font(.headline)
                    .position(x:200, y: 300)
                Image(vpnStatus.isConnected ? "connected" : "disconnected")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Button(action: {
                    self.vpnStatus.isConnected.toggle()
                }) {
                    Text(vpnStatus.isConnected ? "Disconnect" : "Connect")
                }
                .buttonStyle(CustomButtonStyle())
                .position(x: 200, y: 1)
                Spacer()
                Button(action: {
                    self.showSheet.toggle()
                }) {
                    Image("Server")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                .padding()
                .background(.orange)
                .clipShape(Circle())
                
                
            }
            .sheet(isPresented: $showSheet) {
                ServerSelectionView()
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
