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
                
                
                Spacer()
                    .frame(height: 350)
                
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(Color.white)
                    .padding(.horizontal, 0) // No horizontal padding
                    .padding(.bottom, 0)
                    .ignoresSafeArea()
                    .overlay(
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
                                    // Code to get verification code
                                }) {
                                    Text("获取验证码")
                                        .foregroundColor(.white)
                                        .frame(minWidth: 90)
                                        .padding(.vertical, 10)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                        .font(.callout)
                                }
                                
                            }
                            Spacer()
                                .frame(height: 40)
                            // Login Button
                            Button(action: {
                                
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .frame(height: 50)
                                      
                                    Text("登录")
                                        .foregroundColor(Color.white)
                                        .bold()
                                }
                                
                        
                                
                            }
                            
                        }
                            .padding(.horizontal, 30)
                    )
                
                
                
            }
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
