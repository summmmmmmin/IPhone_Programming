//
//  MembersDetailView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI


struct MembersDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let teamID: Int
    let memberID: Int
    let memberMembershipID: Int
    let teamName: String
    let memberName: String
    let memberEmail: String
    let memberRole: Int
    let profileImageUrl: String
    
    let onLeadershipTransferred: () -> Void
    let onMembershipUpdated: () -> Void
    
    @State private var showingTransferAlert = false
    @State private var showingRemoveAlert = false
    @State private var showingSetViceLeaderAlert = false
    @State private var showingUnsetViceLeaderAlert = false
    @State private var showingResultAlert = false
    @State private var resultMessage = ""
    
    private func profileImageView() -> some View {
        Group {
            if let url = URL(string: profileImageUrl), !profileImageUrl.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .foregroundColor(.gray.opacity(0.3))
                }
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.purple)
                    .background(Color.purple.opacity(0.1))
            }
        }
        .frame(width: 140, height: 140)
        .clipShape(Circle())
    }
    
    
    var headerView: some View {
        VStack(spacing: 24) {
            
            //1 팀명
            Text(teamName)
                .font(.system(size: 40))
                .bold()
                .padding(.vertical, 10)
            
            //2 프로필 카드
            VStack(spacing: 15) {
                
                profileImageView()
                
                Text(memberName)
                
                Divider()
                
                Text(memberEmail)
                    .padding(.bottom ,30)
                
            }
            .padding()
            .background(
                Color.white
            )
            .border(Color.black, width: 1)
            .padding(.horizontal)
        }
    }
    
    var actionButtons: some View {
        VStack(spacing: 20) {
            Button(action: {
                showingTransferAlert = true
                print("팀장 양도 버튼 클릭됨")
            }) {
                Text("팀장 양도")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10).padding(.horizontal)
            
            Button(action: {
                showingRemoveAlert = true
                print("내보내기 버튼 클릭됨")
            }) {
                Text("내보내기")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10).padding(.horizontal)
            
            if memberRole == 1 {
                Button(action: {
                    showingUnsetViceLeaderAlert = true
                    print("부팀장 해제하기 버튼 클릭됨")
                }) {
                    Text("부팀장 해제하기")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10).padding(.horizontal)
            } else if memberRole == 2 {
                Button(action: {
                    showingSetViceLeaderAlert = true
                    print("부팀장 지정하기 버튼 클릭됨")
                }) {
                    Text("부팀장 지정하기")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10).padding(.horizontal)
                
            }
            
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            headerView
            actionButtons
            
            Spacer()
        }
        .navigationTitle("팀원 상세")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(AlertModifiers(parent: self))
    }
    
    struct AlertModifiers: ViewModifier {
        let parent: MembersDetailView
        
        func body(content: Content) -> some View {
            content
                .alert("알림", isPresented: parent.$showingTransferAlert) {
                    Button("양도", role: .destructive) {
                        parent.transferLeadership()
                    }
                    Button("취소", role: .cancel) {}
                } message: {
                    Text("\(parent.memberName)님에게 팀장을 양도하시겠습니까?")
                }
                
                .alert("경고", isPresented: parent.$showingRemoveAlert) {
                    Button("내보내기", role: .destructive) {
                        parent.removeMember()
                    }
                    Button("취소", role: .cancel) {}
                } message: {
                    Text("\(parent.memberName)님을 팀에서 내보내시겠습니까?")
                }
                
                .alert("알림", isPresented: parent.$showingSetViceLeaderAlert) {
                    Button("지정") {
                        parent.setViceLeader()
                    }
                    Button("취소", role: .cancel) {}
                } message: {
                    Text("\(parent.memberName)님을 부팀장으로 지정하시겠습니까?")
                }
            
                .alert("알림", isPresented: parent.$showingUnsetViceLeaderAlert) {
                        Button("해제", role: .destructive) {
                            parent.unsetViceLeader()
                        }
                        Button("취소", role: .cancel) {}
                    } message: {
                        Text("\(parent.memberName)님의 부팀장 권한을 해제하시겠습니까?")
                    }
            
                .alert("알림", isPresented: parent.$showingResultAlert) {
                    Button("확인") {}
                } message: {
                    Text(parent.resultMessage)
                }
        }
    }
    
    func transferLeadership() {
        guard let url = URL(string: "http://localhost/ip1/transferleader.php") else {
            print("URL Error")
            return
        }
        let body = "new_leader_id=\(memberMembershipID)&teams_id=\(teamID)"
        let encodeData = body.data(using: .utf8)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                DispatchQueue.main.async { self.resultMessage = "팀장 양도 중 오류가 발생했습니다."; self.showingResultAlert = true }
                return
            }
            guard let data = data, let resultString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            print("Server Response: \(resultString)")
            
            DispatchQueue.main.async {
                if resultString == "Success" {
                    self.resultMessage = "\(memberName)님에게 팀장 양도가 완료되었습니다."
                    self.dismiss()
                    self.onLeadershipTransferred()
                } else {
                    self.resultMessage = "팀장 양도에 실패했습니다. (\(resultString))"
                    self.showingResultAlert = true
                }
            }
        }.resume()
    }
    
    func removeMember() {
        guard let url = URL(string: "http://localhost/ip1/removemember.php") else {
            print("URL Error: removemember.php")
            DispatchQueue.main.async { self.resultMessage = "URL 구성에 오류가 발생했습니다."; self.showingResultAlert = true }
            return
        }
        let removeStatus = 3
        let body = "teams_id=\(teamID)&user_id=\(memberID)&status=\(removeStatus)"
        let encodeData = body.data(using: .utf8)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                DispatchQueue.main.async { self.resultMessage = "팀원 내보내기 중 오류가 발생했습니다."; self.showingResultAlert = true }
                return
            }
            guard let data = data, let resultString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            print("Server Response: \(resultString)")
            
            DispatchQueue.main.async {
                if resultString == "Success" {
                    self.resultMessage = "\(memberName)님을 팀에서 내보냈습니다."
                    self.dismiss()
                    self.onMembershipUpdated()
                } else {
                    self.resultMessage = "팀원 내보내기에 실패했습니다. (\(resultString))"
                    self.showingResultAlert = true
                }
            }
        }.resume()
    }
    
    func setViceLeader() {
        guard let url = URL(string: "http://localhost/ip1/setviceleader.php") else {
            print("URL Error: setviceleader.php")
            DispatchQueue.main.async { self.resultMessage = "URL 구성에 오류가 발생했습니다."; self.showingResultAlert = true }
            return
        }
        
        let body = "teams_id=\(teamID)&user_id=\(memberID)"
        let encodeData = body.data(using: .utf8)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                DispatchQueue.main.async { self.resultMessage = "부팀장 지정 중 오류가 발생했습니다."; self.showingResultAlert = true }
                return
            }
            
            guard let data = data, let resultString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            print("Server Response: \(resultString)")
            
            DispatchQueue.main.async {
                if resultString == "Success" {
                    self.resultMessage = "\(memberName)님을 부팀장으로 지정했습니다."
                    self.showingResultAlert = true
                    self.onMembershipUpdated()
                    self.dismiss()
                } else {
                    self.resultMessage = "부팀장 지정에 실패했습니다. (\(resultString))"
                    self.showingResultAlert = true
                }
            }
        }.resume()
    }
    
    func unsetViceLeader() {
        guard let url = URL(string: "http://localhost/ip1/unsetviceleader.php") else {
            print("URL Error: unsetviceleader.php")
            DispatchQueue.main.async { self.resultMessage = "URL 구성에 오류가 발생했습니다."; self.showingResultAlert = true }
            return
        }
        
        let body = "teams_id=\(teamID)&user_id=\(memberID)"
        let encodeData = body.data(using: .utf8)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                DispatchQueue.main.async { self.resultMessage = "부팀장 해제 중 오류가 발생했습니다."; self.showingResultAlert = true }
                return
            }
            
            guard let data = data, let resultString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            print("Server Response: \(resultString)")
            
            DispatchQueue.main.async {
                if resultString == "Success" {
                    self.resultMessage = "\(memberName)님의 부팀장 권한을 해제했습니다."
                    self.showingResultAlert = true
                    self.onMembershipUpdated()
                    self.dismiss()
                } else {
                    self.resultMessage = "부팀장 해제에 실패했습니다. (\(resultString))"
                    self.showingResultAlert = true
                }
                
            }
            
        }.resume()
        
    }
    
    
}


#Preview {
    Group {
        MembersDetailView(
            teamID: 99,
            memberID: 2,
            memberMembershipID: 999,
            teamName: "팀명",
            memberName: "팀원",
            memberEmail: "aaaa@aaaa",
            memberRole: 2,
            profileImageUrl: "http://localhost/ip1/uploads/test_profile.jpg",
            onLeadershipTransferred: {},
            onMembershipUpdated: {}
        ).previewDisplayName("팀원")
        
        MembersDetailView(
            teamID: 99,
            memberID: 1,
            memberMembershipID: 998,
            teamName: "팀명",
            memberName: "부팀장",
            memberEmail: "bbbb@bbbb",
            memberRole: 1,
            profileImageUrl: "http://localhost/ip1/uploads/test_profile.jpg",
            onLeadershipTransferred: {},
            onMembershipUpdated: {}
        ).previewDisplayName("부팀장")
    }
}


