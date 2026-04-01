import SwiftUI


struct CreateTaskView: View {
    
    let projectID: Int?
    let onTaskCreated: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var isCreating: Bool = false
    
    var finalDueDateString: String? {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: selectedTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second ?? 0
        
        if let combinedDate = calendar.date(from: combinedComponents) {
            return DateFormatter.taskDateFormat.string(from: combinedDate)
        }
        return nil
    }
    
    func createTask() {
        guard let dueOn = finalDueDateString,
              let pID = projectID else {
            print("필수 데이터 누락 (마감일 또는 프로젝트 ID)")
            return
        }
        
        self.isCreating = true
        
        guard let url = URL(string: "http://localhost/ip1/create_task.php") else {
            self.isCreating = false
            return
        }
        
        let titleEncoded = taskTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let descriptionEncoded = taskDescription.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let body = "project_id=\(pID)&title=\(titleEncoded)&description=\(descriptionEncoded)&due_on=\(dueOn)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isCreating = false
                
                guard let data = data else { return }
                
                do {
                    let result = try JSONDecoder().decode(TaskResponse.self, from: data)
                    
                    if result.success {
                        self.onTaskCreated()
                        self.dismiss()
                    } else {
                        print("새 할 일 생성 실패: \(result.message ?? "Unknown server error")")
                    }
                } catch {
                    print("서버 응답 디코딩 실패: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                
                Text("To-Do 등록")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                Group {
                    Text("제목")
                        .font(.headline)
                    TextField("제목 입력", text: $taskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Group {
                    Text("내용")
                        .font(.headline)
                    TextEditor(text: $taskDescription)
                        .frame(height: 100)
                        .border(Color.gray.opacity(0.5), width: 1)
                }
                .padding(.horizontal)
                
                Group {
                    Text("마감 날짜")
                        .font(.headline)
                    
                    DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                    
                    Text("마감 시간")
                        .font(.headline)
                    DatePicker("시간 선택", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("새 Task 등록")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isCreating ? "등록 중..." : "등록") { createTask() }
                    .disabled(taskTitle.isEmpty || isCreating)
            }
        }
    }
}

