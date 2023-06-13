//
//  NoConnectionView.swift
//  TalkAI
//
//  Created by Abdullah Kardaş on 12.06.2023.
//

import SwiftUI
import AlertToast //add https://github.com/elai950/AlertToast.git
import Network

class NetworkAvailibility: ObservableObject {
    let monitor = NWPathMonitor()
    @Published var isNetAvailable = true
   
    init(){
        monitor.pathUpdateHandler = {path in
            if path.status == .satisfied {// Connection found
                DispatchQueue.main.async {
                    self.isNetAvailable = true
                }
                
            } else {// No connection
                DispatchQueue.main.async {
                    self.isNetAvailable = false
                }
                
            }

        }
        startMonitor()
    }
    
    func startMonitor(){
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
            monitor.cancel()
        }
}
struct NoConnectionView: View {
    @StateObject var vm = NetworkAvailibility()
    

    @State var noConnection = false
    @State var foundConnection = false
    var body: some View {
        ZStack {
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
        }.frame(maxHeight: .infinity).frame(maxWidth: .infinity)
            .onAppear {
            vm.startMonitor()
            }.onDisappear {
            vm.stopMonitoring()
            }.onChange(of: vm.isNetAvailable, perform: {[showAlert = vm.isNetAvailable] newValue in
                let oldValue = showAlert
                if oldValue != newValue {
                    if newValue {//net is available
                        self.noConnection = false
                        self.foundConnection = true
                    }else{ //no connection
                        self.noConnection = true
                        self.foundConnection = false
                    }
                }
                
            })
            .toast(isPresenting: $noConnection,duration: .infinity, tapToDismiss: false) {
                AlertToast(displayMode: .hud, type: .systemImage("network", .white), title: "No internet connection",style: .style(backgroundColor:Color.red, titleColor: .white))
        }
            .toast(isPresenting: $foundConnection,duration: 3.0, tapToDismiss: false) {
                AlertToast(displayMode: .hud, type: .systemImage("network", .white), title: "Connection found",style: .style(backgroundColor:Color.green, titleColor: .white))
        }
    }
}

struct NoConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoConnectionView()
    }
}

