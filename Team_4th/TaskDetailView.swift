import SwiftUI


struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    // TaskItem으로부터 Binding을 받아 Task 상태 변경 시 목록에 즉시 반영
    @Binding var taskData: Task
    var onUpdate: () -> Void
    
    @State private var isProcessing = false
   
    private let service = TaskServiceLegacy()
    
    var statusText: String {
        switch taskData.status {
        case 0: return "TODO"
        case 2: return "완료"
        default: return "알 수 없음"
        }
    }
    
    // 완료/미완료 토글 기능
    func toggleCompletion() {
        let newStatus = (taskData.status == TaskStatus.completed.index) ? TaskStatus.todo.index : TaskStatus.completed.index
        
        guard let tID = taskData.id else { return }
        isProcessing = true
        
        service.updateStatus(taskID: tID, newStatus: newStatus) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success:
                  
                    self.taskData.status = newStatus
                    self.onUpdate()
                case .failure(let error):
                    print("상태 변경 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Task 삭제 로직 추가
    func deleteTask() {
        guard let tID = taskData.id else { return }
        isProcessing = true
        
        service.deleteTask(taskID: tID) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success:
                    self.onUpdate() // 목록 새로고침
                    self.dismiss()  // 상세 뷰 닫기
                case .failure(let error):
                    print("Task 삭제 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text(taskData.title ?? "제목 없음")
                .font(.largeTitle)
                .bold()
            
            Divider()
            
            Group {
                HStack {
                    Text("상태:")
                        .font(.headline)
                    Text(statusText)
                        .foregroundColor(taskData.status == TaskStatus.completed.index ? .blue : .orange)
                    
                    Spacer()
                    
                 
                }
                
                HStack {
                    Text("마감일:")
                        .font(.headline)
                   
                    Text(taskData.due_on ?? "날짜 미정")
                        .foregroundColor(.gray)
                }
                
                Text("설명")
                    .font(.headline)
                
                ScrollView {
                    Text(taskData.description ?? "작성된 내용이 없습니다.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 5)
            
            Spacer()
            
            // 삭제 버튼 추가
            Button(role: .destructive) {
                deleteTask()
            } label: {
                HStack {
                    Spacer()
                    Text(isProcessing ? "삭제 중..." : "Task 삭제")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isProcessing)
        }
        .padding()
        .navigationTitle("Task 상세 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}
