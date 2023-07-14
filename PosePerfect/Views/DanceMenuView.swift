//
//  DanceMenuView.swift
//  PosePerfect
//
//  Created by Han Chubo on 2023/7/14.
//

import SwiftUI

struct CustomRow: View {
    var title: String
    var subTitle: String
    

    var body: some View {
        
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(color: .gray, radius: 5, x: 0, y: 2)
            .frame(height: 100)
            .overlay(
                HStack {
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        Text(subTitle)
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    
                    Spacer()
                }
                
            )
            .padding(.bottom, 5)
    }
}

struct DanceMenuView: View {
    @State var userName: String?
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: 0x807AE4)
                    .edgesIgnoringSafeArea(.all)
               
                VStack {
                    HStack {
                        Text("\(userName ?? "Hi"), 选择舞蹈开始吧")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                    .padding()
                    ScrollView {
                        NavigationLink(destination: DetectionView()) {
                            CustomRow(title: "七彩阳光", subTitle: "5分钟 难度小")
                        }
                        .padding(.horizontal)

                        NavigationLink(destination: Text("太极舞")) {
                            CustomRow(title: "太极舞", subTitle: "3分钟 难度适中")
                        }
                        .padding(.horizontal)
                    }
                   
                        
                    
                        
                    
                
                       
                    
                    Spacer()
                    
                    NavigationLink(destination: DanceMapping()) {
                        Text("录入")
                            .font(.title3)
                            .padding()
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    }
                    .padding()
                }
            }
        }
        
        
    }
}

struct DanceMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DanceMenuView()
    }
}
