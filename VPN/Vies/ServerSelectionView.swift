//
//  ServerSelectionView.swift
//  VPN
//
//  Created by Ruslan on 26.01.23.
//

import SwiftUI
import NetworkExtension

struct ServerSelectionView: View {
    @ObservedObject var serverList = ServerList()
    @State private var selectedServer = 0
    
    var body: some View {
        List {
            ForEach(0..<serverList.servers.count, id: \.self) { index in
                Button(action: {
                    self.selectedServer = index
                }) {
                    HStack {
                        Text(self.serverList.servers[index].name)
                        if self.selectedServer == index {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Server Selection")
        .navigationBarItems(trailing:
            Button(action: {
                self.connectToServer(at: self.selectedServer)
            }) {
                Text("Connect")
            }
        )
    }
    func connectToServer(at index: Int) {
        // code to connect to the selected server
        let server = self.serverList.servers[index]
        // configure the VPN configuration
        let vpnManager = NEVPNManager.shared()
        vpnManager.protocolConfiguration = server.protocolConfiguration
        vpnManager.isOnDemandEnabled = true
        vpnManager.localizedDescription = "VPN Connection"
        vpnManager.saveToPreferences { (error) in
            if let error = error {
                // handle error
                return
            }
            do {
                try vpnManager.connection.startVPNTunnel()
            } catch {
                // handle error
            }
        }
    }
}


struct ServerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelectionView()
    }
}
