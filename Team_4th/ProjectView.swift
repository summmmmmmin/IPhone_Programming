// TeamSelectView.swift

import SwiftUI

struct Project: Codable{
    var id:Int?
    var team_id:Int?
    var name:String?
    var description:String?
    var due_at: String?
    
}

struct ProjectItem:View {
    @State var projectData : Project
    @State var selectProjectActive: Bool = false
    @State var completeProjectActive: Bool = false
    @State var projectMessage = ""
    @State var projectCompleteMessage = ""// 메시지 변수 유지
    
   
    var body: some View {
        VStack{
            Button(action: {
                print("프로젝트 항목이 클릭되었습니다: \(projectData.name ?? "")")
                selectProjectActive = true
                
                
            }) {
                HStack{
                    Text(projectMessage)
                        .font(.headline)
                        .padding(.trailing, 10)
                    Divider()
                        .frame(height: 80)
                        .padding(.horizontal,5)
                    VStack{
                        Text(projectData.name ?? "")
                        Text(projectData.description ?? "")
                        Text(projectData.due_at ?? "")
                    }
                }
                .onAppear{
                    guard let url=URL(string: "http://localhost/ip1/ifprojectcomplete.php")
                        else{
                            print("url error")
                            return
                        }
                    
                    
                   
                    let projectIDValue = projectData.id ?? 0
                    let body = "id=\(projectIDValue)"
                    let encodeData = body.data(using: .utf8)
                        
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
                            
                        let status = String(decoding: data, as: UTF8.self)
                        print("data ? \(status)")
                        if status == "0"{
                            projectMessage = "진행 중"
                            
                        }
                        else if status == "1"{
                            projectMessage = "완료"
                        }
                        else {
                            projectMessage = "만료"
                        }
                    }.resume()
                }
            }
            
        
        }
        
        .frame(width:320, height:100)
        .border(Color.gray, width: 1)
        .padding(.vertical, 5)
        
        NavigationLink(destination: TaskView(project_ID: projectData.id,project_Name: projectData.name ?? "Unknown Project"),
                       isActive: $selectProjectActive) {
            EmptyView()
        }
        
    }
}

struct Projects: Codable{
    var projects:[Project]
}

struct ProjectView: View {
    @State var isCreateProjectActive: Bool = false
    @State var projects:Projects=Projects(projects: [Project]())
    let team_ID: Int?
    let team_Name: String
    @State var id:String=""
    @State var name:String=""
    @State var description:String=""
    @State var due_at:String=""
    
    var body: some View {
        NavigationView{
            
            VStack{
                Text(team_Name)
                        .font(.headline)
                HStack{
                    Spacer()
                    
                    Button{
                        isCreateProjectActive = true
                    } label:{
                        Text("프로젝트 생성")
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    NavigationLink(destination: CreateProjectView(teamID:team_ID, teamName:team_Name),
                                   isActive: $isCreateProjectActive) {
                        EmptyView()
                    }
                   
                    .padding(.trailing, 20)
                }
                
                    VStack{
                        List(projects.projects, id:\.id) { contents in ProjectItem(projectData: contents)}
                    }.onAppear(){
                        guard let url=URL(string: "http://localhost/ip1/getprojects.php")
                        else{
                            print("url error")
                            return
                        }
                    
                        var request = URLRequest(url: url)
                        request.httpMethod="POST"
                        
                        let teamIDValue = self.team_ID ?? 0
                        
                        let body="team_id=\(teamIDValue)";
                    
                        let encodeData=body.data(using: String.Encoding.utf8)
                        request.httpBody=encodeData
                    
                        URLSession.shared.dataTask(with: request){data,response,error in
                            if let error = error{
                                print(error)
                                return
                            }
                            guard let data = data else{
                                return
                            }
                        
                            do{
                                let str2 = String(decoding: data, as: UTF8.self)
                                print(str2)
                                let decoder = JSONDecoder()
                                if let jsonTeamData = try? decoder.decode(Projects.self, from:data){
                                    projects=jsonTeamData
                                    print("???")
                                }
                            }
                        } .resume()
                    }
                

            }
            
        }
        
        
    }
}

#Preview {
    ProjectView(team_ID: 0, team_Name: "팀명")
}




