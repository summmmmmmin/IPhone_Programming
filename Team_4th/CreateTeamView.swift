//
//  CreateTeamView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI

struct CreateTeamView: View {
    @State var name:String=""
    @State var description:String=""
    @State var isCreateTeamActive: Bool = false
    
    var body: some View {
        NavigationView{
            VStack {
                
                HStack {
                    Text("팀 이름: ")
                    TextField("팀 이름 입력", text: $name)
                }
                
                HStack {
                    Text("소개 문구: ")
                    TextField("팀 소개 문구 입력", text: $description)
                }
                .padding(.vertical, 30)
                
                Button {
                    guard let url=URL(string: "http://localhost/ip1/createteam.php")
                        else{
                            print("url error")
                            return
                        }
                    
                    let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
                    
                            
                    let body = "name=\(name)&description=\(description)&userid=\(userid)"
                    let encodeData=body.data(using: .utf8)
                        
                    var request = URLRequest(url: url)
                    request.httpMethod="POST"
                    request.httpBody=encodeData
                    URLSession.shared.dataTask(with: request){data,response,error in
                        if let error = error{
                            print(error)
                            return
                        }
                        guard let data = data else{
                            return
                        }
                            
                        let str = String(decoding: data, as: UTF8.self)
                        print("data ? \(str)")
                        if str == "1"{
                            print("팀 생성 성공")
                            isCreateTeamActive = true
                        }
                    }.resume()
                    
                }label:{
                    Text("팀 생성하기")
                }.fullScreenCover(isPresented: $isCreateTeamActive){
                    TeamHomeView()
                }
                
                
            }
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    CreateTeamView()
}

