//
//  CreateTeamView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI

struct CreateProjectView: View {
    @State var name:String=""
    @State var description:String=""
    let teamID:Int?
    let teamName:String
    @State var due_at:String?
    @State private var selectedDate: Date = Date()
    @State var isCreateProjectActive: Bool = false
    
    private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX") // 안정적인 형식을 위해 권장
            return formatter
        }()
    
    var body: some View {
        NavigationView{
            VStack {
                
                HStack {
                    Text("프로젝트 이름: ")
                    TextField("프로젝트 이름 입력", text: $name)
                }
                
                HStack {
                    Text("프로젝트 내용: ")
                    TextField("프로젝트 내용 입력", text: $description)
                }
                .padding(.vertical, 30)
                
                HStack {
                    Text("마감 날짜: ")
                        .frame(width: 100, alignment: .leading)
                                
                    DatePicker(
                        "", // 레이블 생략
                        selection: $selectedDate,
                        displayedComponents: [.date, .hourAndMinute] 
                    )
                        .datePickerStyle(.compact)
                }.onChange(of: selectedDate) { newDate in
                        due_at = dateFormatter.string(from: newDate)}
                
                
                Button {
                    guard let url=URL(string: "http://localhost/ip1/createproject.php")
                        else{
                            print("url error")
                            return
                        }
                    
                    let userid = UserDefaults.standard.integer(forKey: "LoggedInUser")
                    
                    let teamIDValue = self.teamID ?? 0
                    let dueDateValue = self.due_at ?? ""
                    
                    let body = "name=\(name)&description=\(description)&team_id=\(teamIDValue)&due_at=\(dueDateValue)"
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
                            print("프로젝트 생성 성공")
                            isCreateProjectActive = true
                        }
                    }.resume()
                    
                }label:{
                    Text("프로젝트 생성하기")
                }.fullScreenCover(isPresented: $isCreateProjectActive){
                    TeamHomeView()
                }
                
                
            }
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    CreateProjectView(teamID: 0, teamName: "")
}



