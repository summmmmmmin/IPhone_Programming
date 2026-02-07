//
//  ModifyProfileView.swift
//  Team_4th
//
//  Created by mac10 on 10/27/25.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey: Any]) {
            DispatchQueue.main.async {
                if let uiImage = info[.editedImage] as? UIImage {
                    self.parent.selectedImage = uiImage
                } else if let uiImage = info[.originalImage] as? UIImage {
                    self.parent.selectedImage = uiImage
                }
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProfileResponse: Decodable {
    let name: String
    let email: String
    let password: String
    let profile_img: String?
}

struct ModifyProfileView: View {
    var onUpdateSuccess: () -> Void
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var password_ver: String = ""
    
    @State private var selectedProfileImage: UIImage? = nil
    @State private var profileImageUrl:String = ""
    @State private var showingImagePicker: Bool = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                        .font(.title2)
                }
                Text("뒤로")
                Spacer()
            }
            .padding()
            
            Text("프로필 수정하기")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 20) {
                
                HStack(spacing: 20) {
                    //프로필 사진
                    profileImageView()
                        .frame(width: 100, height: 100)
                        .id(selectedProfileImage == nil ? 0 : 1)
                    //추가 버튼
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("사진 추가")
                        }
                    }
                }
                
                //이름
                Text("Name")
                TextField("이름 입력", text: $name)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                
                //이메일
                Text("Email")
                Text(email)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(5)
                
                //비밀번호
                Text("Password")
                TextField("비밀번호", text: $password)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                //비밀번호 확인
                Text("Password Verificarion")
                TextField("비밀번호 확인", text: $password_ver)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                
                
            }
            
            Button(action: {
                updateProfile()
            }) {
            Text("수정하기")
            }
            .padding()
            
        }
        .padding()
        .onAppear() {
            CurrentProfile()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("확인"), action: {
                if self.alertMessage == "수정되었습니다." {
                    self.onUpdateSuccess()
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedProfileImage)
        }
        
    }
    
    @ViewBuilder
    private func profileImageView() -> some View {
        if let image = selectedProfileImage{
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        } else if let url = URL(string: profileImageUrl), !profileImageUrl.isEmpty{
            AsyncImage(url: url) {image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.gray.opacity(0.3))
            }
        } else {Circle()
                .foregroundColor(.purple.opacity(0.1))
                .overlay(Image(systemName: "person").font(.system(size: 40)).foregroundColor(.purple))
        }
    }
    
    func CurrentProfile() {
            let userID = UserDefaults.standard.integer(forKey: "LoggedInUser")
            guard userID > 0 else {
                self.name = "ID 오류"; self.email = "ID 오류"; return
            }
            
            guard let url = URL(string: "http://localhost/ip1/modifyprofile.php") else { return }
            
            let body = "id=\(userID)"
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = body.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    if let profile = try? JSONDecoder().decode(ProfileResponse.self, from: data) {
                    
                        self.name = profile.name
                        self.email = profile.email
                        self.password = profile.password
                        self.password_ver = profile.password
                        self.profileImageUrl = profile.profile_img ?? ""
                    }
                }
            }.resume()
        }
    
    func updateProfile() {
        //이름이 비어있는지
        if name.isEmpty {
            self.alertMessage = "이름은 비워둘 수 없습니다."
            self.showAlert = true
            return
        }
        
        if !password.isEmpty&&password != password_ver {
            self.alertMessage = "새 비밀번호와 비밀번호 확인이 일치하지 않습니다."
            self.showAlert = true
            return
        }
        
        //이미지 업로드
        if let imageToUpload = selectedProfileImage, let imageData = imageToUpload.jpegData(compressionQuality: 0.8) {
            uploadImage(imageData: imageData)
        } else {
            performProfileUpdate(imageUrl: self.profileImageUrl)
        }
    }
            
    func uploadImage(imageData: Data) {
            guard let url = URL(string: "http://localhost/ip1/uploadimage.php") else { return }
            
            let boundary = "Boundary-\(UUID().uuidString)"
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            let fileName = "profile_\(Int(Date().timeIntervalSince1970)).jpg"
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.alertMessage = "이미지 업로드 실패 (네트워크 오류)"
                        self.showAlert = true
                    }
                    return
                }
                
                let imageUrlString = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
                
                print("서버 응답: \(imageUrlString)")
                
                if imageUrlString.hasPrefix("http") {
                    self.performProfileUpdate(imageUrl: imageUrlString)
                } else {
                    DispatchQueue.main.async {
                        self.alertMessage = "이미지 업로드 실패: \(imageUrlString)"
                        self.showAlert = true
                    }
                }
            }.resume()
        }
          
    func performProfileUpdate(imageUrl: String) {
        let userID = UserDefaults.standard.integer(forKey: "LoggedInUser")
        let imgUrlToSend = imageUrl.isEmpty ?"": imageUrl
        
        var bodyString = "id=\(userID)&name=\(name)&profile_img=\(imgUrlToSend)"
        
        //비밀번호 입력이 있는지
        if !password.isEmpty {
            bodyString += "&password=\(password)"
        }
        
        guard let url = URL(string: "http://localhost/ip1/updateprofile.php"),
              let encodeData = bodyString.data(using: .utf8) else { return }
                
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodeData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {return}
            let str = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
            
            DispatchQueue.main.async {
                if str == "1"{
                    self.alertMessage = "수정되었습니다."
                    self.selectedProfileImage = nil
                    self.profileImageUrl = imageUrl
                } else {
                    self.alertMessage = "수정 실패. (서버 오류)"
                }
                self.showAlert = true
            }
        }.resume()
                
    }
    
}

#Preview {
    ModifyProfileView(onUpdateSuccess: {})
}


