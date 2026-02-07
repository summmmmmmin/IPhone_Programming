//
//  SignupView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI

struct SignupView: View {
    @State var name:String="" //전역 변수
    @State var email:String=""
    @State var password:String=""
    @State var isSucceedSignup: Bool = false
    
    @State var showAlert = false
    @State var alertMessage = ""
    //X
    var body: some View {
            NavigationView {
                VStack {
                    HStack {
                        Text("Name");
                        TextField("이름 입력", text: $name)
                    }
                    
                    HStack{
                        Text("Email")
                        TextField("E-mail 입력", text: $email)
                    }
                    
                    HStack{
                        //로컬 변수
                        Text("PWD")
                        TextField("PWD 입력", text: $password )
                    }
                    

                    Button ("계정 생성하기"){
                        
                        //name
                        if name.range(of: "[!@#$%^&]", options: .regularExpression) != nil {
                            alertMessage = "이름에는 특수문자를 사용할 수 없습니다."
                            showAlert = true
                            return
                        }
                        
                        //email
                        if email.range(of: "[!#$%^&]", options: .regularExpression) != nil {
                            alertMessage = "E-mail에는 특수문자를 사용할 수 없습니다."
                            showAlert = true
                            return
                        }
                        
                        
                        //pwd
                        if password.count < 4 {
                            alertMessage = "비밀번호는 4글자 이상이어야 합니다."
                            showAlert = true
                            return
                        }
                        if password.range(of: "[!@#$%^&]", options: .regularExpression) == nil {
                            alertMessage = "비밀번호에는 특수문자(!@#$%^&) 중 하나가 포함되어야 합니다."
                            showAlert = true
                            return
                        }
                        if password.range(of: "[0-9]", options: .regularExpression) == nil {
                            alertMessage = "비밀번호에는 숫자가 1개 이상 포함되어야 합니다."
                            showAlert = true
                            return
                        }
                        
            
                        
                        guard let url=URL(string: "http://localhost/ip1/signup.php")
                            else{
                                print("url error")
                                return
                            }
                        let body = "name=\(name)&email=\(email)&password=\(password)"
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
                                print("sign in 성공")
                                isSucceedSignup=true
                            }
                            else if str == "-1"{
                                print("email 중복")
                                alertMessage = "중복된 계정입니다. 다시 시도해주세요."
                                showAlert = true
                            }
                        } .resume()
                    }.fullScreenCover(isPresented: $isSucceedSignup){
                        LoginView()
                    }.alert(isPresented: $showAlert) {
                                    Alert(title: Text("경고"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                                }
                    
                }
                .padding(.horizontal, 30.0)
                
            }
    }

}

#Preview {
    SignupView()
}

