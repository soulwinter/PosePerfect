//
//  WebSocketService.swift
//  Dongji-Pro
//
//  Created by Han Chubo on 2023/7/5.
//

import Foundation

class WebSocketService: ObservableObject {
    private let urlSession: URLSession
    private var webSocketTask: URLSessionWebSocketTask?
    @Published var textView: String = "Trying to send messages to the server"
    
    
    init() {
        self.urlSession = URLSession(configuration: .default)
    }
    
    func connect() {
        webSocketTask = urlSession.webSocketTask(with: URL(string: "\(Constants.webSocketDomain)/websocket/2")!)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { result in
            switch result {
            case .failure(let error):
                print("WebSocket receiving error: \(error)")
                
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string: \(text)")
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    break
                }
                
                // Keep listening.
                self.receiveMessage()
            }
        }
    }
    
    func sendMessage(_ content: String) {
       
        let message = URLSessionWebSocketTask.Message.string(content)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
                DispatchQueue.main.async {
                    self.textView = "WebSocket couldn’t send message because: \(error)"
                    
                }
                
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}


