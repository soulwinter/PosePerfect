//
//  LoginView.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/6.
//

import SwiftUI

struct LoginView: View {
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    
    @State private var showingAlert = false
    @State private var alertContent = ""
    
    var body: some View {
        
        // Set background
        ZStack {
            Color(hex: 0x807AE4)
                .ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 30)
                
                Text("PosePerfect")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                    .bold()
                    .padding(.bottom, 1)
                
                
                Text("你的下一代舞蹈教练")
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                
                // TODO: the views should be moved up when the keyboard is active
            
                
                ZStack {
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(Color.white)
                        .padding(.horizontal, 0)
                        .padding(.bottom, 0)
                        .ignoresSafeArea()
                    VStack {
                        Text("手机号登录")
                            .font(.system(size: 25))
                            .bold()
                            .foregroundColor(Color.black)
                        
                        
                        // Phone number input
                        TextField("输入手机号码", text: $phoneNumber)
                            .font(.system(size: 20))
                            .padding(.leading)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 1)
                                    .frame(height: 2)
                                    .foregroundColor(Color(red: 128/255, green: 122/255, blue: 228/255)),
                                alignment: .bottom
                            )
                        
                        
                        // Verification code input
                        HStack {
                            TextField("输入验证码", text: $verificationCode)
                                .font(.system(size: 20))
                                .padding(.leading)
                                .frame(height: 44)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 1)
                                        .frame(height: 2)
                                        .foregroundColor(Color(red: 128/255, green: 122/255, blue: 228/255)),
                                    alignment: .bottom
                                )
                            Button(action: {
                                // Get verification code
                                NetworkManager.shared.getVerificationCode(phoneNumber: phoneNumber) { result in
                                    switch result {
                                    case .success(_):
                                        alertContent = "验证码已发送到手机 \(phoneNumber)，请查收"
                                        showingAlert.toggle()
                                    case .failure(let error):
                                        
                                        alertContent = "发送失败，\(error)"
                                        showingAlert.toggle()
                                    }
                                }
                                
                            }) {
                                Text("获取验证码")
                                    .foregroundColor(.white)
                                    .frame(minWidth: 90)
                                    .padding(.vertical, 10)
                                    .background(isValidPhoneNumber(phoneNumber) ? Color.blue : Color.gray)
                                    .cornerRadius(10)
                                    .font(.callout)
                            }
                            .alert(alertContent, isPresented: $showingAlert) {
                                Button("OK", role: .cancel) { }
                            }
                            .disabled(!isValidPhoneNumber(phoneNumber))
                            
                        }
                        Spacer()
                            .frame(height: 40)
                        // Login Button
                        Button(action: {
                            NetworkManager.shared.loginWithCode(phoneNumber: phoneNumber, code: verificationCode) { result in
                                switch result {
                                case .success(let response):
                                    alertContent = "你好，\(response.nickname)! 你的 ID 是 \(String(describing: response.id))"
                                    showingAlert.toggle()
                                case .failure(let error):
                                    alertContent = "登录失败，\(error)"
                                    showingAlert.toggle()
                                }
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10.0)
                                    .frame(height: 50)
                                
                                Text("登录")
                                    .foregroundColor(Color.white)
                                    .bold()
                            }
                            
                        }
                        .alert(alertContent, isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                        }
                        .disabled(phoneNumber == "" || verificationCode == "")
                        Spacer()
                            .frame(height: 100)
                        
                    }
                    .padding(.horizontal, 30)
                    
                }
                
                
                
                
            }
            
            
        }
    }
    
    // 判断手机号是否可用
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumberPattern = "^1[3-9]\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberPattern)
        return predicate.evaluate(with: phoneNumber)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
