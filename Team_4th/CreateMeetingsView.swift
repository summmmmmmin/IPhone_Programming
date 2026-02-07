//
//  CreateTeamView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI

struct CreateMeetingsView: View {
    @State var title:String=""
    @State var notes:String=""
    let teamID:Int?
    let teamName:String
    @State private var selectedDate: Date = Date()
    @State var isCreateMeetingActive: Bool = false
    
    
    var body: some View {
        NavigationView{
            VStack {
                
                HStack {
                    Text("회의록 제목: ")
                    TextField("회의록 제목 입력", text: $title)
                }
                
                HStack {
                    Text("회의록 내용: ")
                    TextField("회의록 내용 입력", text: $notes)
                }
                .padding(.vertical, 30)
                
                
                
                
                Button {
                    guard let url=URL(string: "http://localhost/ip1/createmeeting.php")
                        else{
                            print("url error")
                            return
                        }
                    
                    let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
                    
                    let teamIDValue = self.teamID ?? 0
                    
                    let body = "title=\(title)&notes=\(notes)&team_id=\(teamIDValue)&author_id=\(userid)"
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
                            print("회의록 생성 성공")
                            isCreateMeetingActive = true
                        }
                    }.resume()
                    
                }label:{
                    Text("회의록 생성하기")
                }.fullScreenCover(isPresented: $isCreateMeetingActive){
                    TeamHomeView()
                }
                
                
            }
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    CreateMeetingsView(teamID: 0, teamName: "")
}





