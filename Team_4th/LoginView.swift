//
//  LoginView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI

struct LoginView: View {
    @State var email:String=""
    @State var password:String=""
    @State var isSucceedLogin: Bool = false
    @State var isSignupActive: Bool = false
    @State var isTeamHomeActive: Bool = false
    
    @State var showAlert = false
    @State var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                HStack {
                    Text("Email")
                    TextField("E-mail 입력", text: $email)
                }
                
                HStack {
                    Text("PWD")
                    TextField("PWD 입력", text: $password)
                }
                
                Button("로그인") {
                    
                    guard let url = URL(string: "http://localhost/ip1/login.php") else {
                        print("URL Error")
                        return
                    }
                    
                    let body = "email=\(email)&password=\(password)"
                    let encodeData = body.data(using: .utf8)
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.httpBody = encodeData
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        guard let data = data else { return }
                        
                        let str = String(decoding: data, as: UTF8.self)
                        let userPkey = Int(str)
                        print("login result: \(userPkey)")
                        
                        if userPkey ?? 0 > 0{
                            print("login success")
                        }
                        else {
                            alertMessage = "로그인에 실패했습니다."
                            showAlert = true
                        }
                        
                        DispatchQueue.main.async {
                                    if let userid = Int(str), userid > 0 {
                                        UserDefaults.standard.set(userid, forKey: "LoggedInUser")
                                        guard let url = URL(string: "http://localhost/ip1/getfavoriteteam.php") else {
                                            print("URL Error")
                                            return
                                        }
                                        
                                        let body = "id=\(userid)"
                                        let encodeData = body.data(using: .utf8)
                                        
                                        var request = URLRequest(url: url)
                                        request.httpMethod = "POST"
                                        request.httpBody = encodeData
                                        
                                        URLSession.shared.dataTask(with: request) { data, response, error in
                                            if let error = error {
                                                print(error.localizedDescription)
                                                return
                                            }
                                            
                                            guard let data = data else { return }
                                            
                                            let str = String(decoding: data, as: UTF8.self)
                                            print("favorite team result: \(str)")
                                            
                                            DispatchQueue.main.async {
                                                        if let teamid = Int(str), teamid == 0 {
                                                            UserDefaults.standard.set(teamid, forKey: "SelectedTeam")
                                                            isSucceedLogin = true
                                                        } else {
                                                            
                                                            isTeamHomeActive = true
                                                        }
                                            }
                                        }.resume()
                                    } else {
                                        alertMessage = "로그인에 실패했습니다."
                                        showAlert = true
                                    }                        }
                    }.resume()
                }.fullScreenCover(isPresented: $isSucceedLogin){
                    TeamSelectView()
                }.fullScreenCover(isPresented: $isTeamHomeActive){
                    TeamHomeView()
                }
                
                Button("회원가입") {
                    isSignupActive = true
                }

                
                NavigationLink(destination: SignupView(),
                               isActive: $isSignupActive) {
                    EmptyView()
                }
                
            }
            .padding(.horizontal, 30)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("확인"), action:{
                    if alertMessage == "로그인에 성공했습니다." {
                    }
                            }))
                        }
                    }
                }
            }
#Preview {
    LoginView()
}

