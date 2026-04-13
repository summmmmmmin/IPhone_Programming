<div align="center">

<br>

# iOS 팀 협업 프로젝트 관리 애플리케이션


<br>

[![iOS](https://img.shields.io/badge/Platform-iOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-0D96F6?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![PHP](https://img.shields.io/badge/Backend-PHP_·_MySQL-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://www.php.net)

<br>

> **팀장 · 부팀장 · 팀원 3단계 역할 체계로 팀 내 권한을 분리하고, URLSession + PHP REST API 48개 엔드포인트로 팀 전체 데이터를 실시간 동기화합니다.**
>
> 팀 생성 · 가입 신청 · 승인 / 프로젝트 & 태스크 추적 / 미팅 & 공지 / 역할별 UI 완전 분리

<br>

**팀 프로젝트 4인**

<br>

</div>

---

## 목차

1. [왜 만들었나](#-왜-만들었나)
2. [주요 기능](#-주요-기능)
3. [기술 스택](#️-기술-스택)
4. [화면 구성 & 네비게이션 흐름](#-화면-구성--네비게이션-흐름)
5. [핵심 구현](#-핵심-구현)
   - [로그인 → 팀 자동 진입 로직](#1-로그인--팀-자동-진입-로직)
   - [팀 가입 신청 3-state 흐름](#2-팀-가입-신청-3-state-흐름)
   - [역할별 UI 완전 분리](#3-역할별-ui-완전-분리)
   - [URLSession 네트워킹 패턴](#4-urlsession-네트워킹-패턴)
6. [API 엔드포인트 48개](#-api-엔드포인트-48개)
7. [트러블슈팅](#-트러블슈팅)
8. [팀 구성 & 역할](#-팀-구성--역할)

---

## 왜 만들었나

팀 프로젝트를 진행하면서 팀장·부팀장·팀원 간 역할이 다른데도 같은 화면을 쓰는 불편함이 있었다. 팀원에게 보여선 안 되는 멤버 관리 메뉴, 팀장에게만 필요한 가입 승인 흐름이 뒤섞이면 UX와 보안 모두 나빠진다.

TeamSync는 **로그인 직후 역할을 판별**해 팀장·부팀장·팀원 각각 전혀 다른 UI를 제공한다. PHP REST API 48개 엔드포인트 위에서 URLSession과 `Codable`로 통신하며, `UserDefaults`로 세션과 현재 팀 ID를 유지한다.

---

## 주요 기능

<table>
<tr>
<td width="50%" valign="top">

### 팀 생성 · 전환 · 가입

- 팀 생성 · 전체 팀 검색 · 가입 신청
- 즐겨찾기 기반 **로그인 직후 팀 자동 진입**
- 다중 팀 소속 지원 — 탭에서 즉시 팀 전환
- 가입 신청 상태 **3단계** 표시 (미신청 · 신청중 · 가입완료)

</td>
<td width="50%" valign="top">

### 3단계 역할 기반 UI

- **팀장(0)**: 멤버 관리 · 가입 승인/거절 · 팀원 추방 · 부팀장 지정 · 팀장 권한 위임
- **부팀장(1)**: 멤버 조회 · 일부 관리 기능
- **팀원(2)**: 기본 프로젝트 · 태스크 · 미팅 · 공지 접근
- 역할별 프로필 뷰 완전 분리

</td>
</tr>
<tr>
<td width="50%" valign="top">

### 프로필 관리

- 개인 프로필 조회 · 수정
- 프로필 사진 업로드 (`uploadimage.php`)
- 팀 내 다른 멤버 개인 프로필 확인
- 역할별 프로필 뷰 완전 분리 (팀장·부팀장·팀원)

</td>
<td width="50%" valign="top">

### 프로젝트 & 태스크

- 팀별 프로젝트 생성 · 수정 · 완료 처리
- 프로젝트 상태 추적 (진행중 · 완료 · 기한초과)
- 태스크 생성 / 수정 / 삭제 · 마감일 설정
- 태스크 상태 관리 (TODO · 완료 · 만료)

</td>
<td width="50%" valign="top">

### 미팅 · 공지 · 댓글

- 미팅 일정 기록 · 조회 · 상세 정보
- 공지사항 작성 · 핀 고정
- 댓글 CRUD (작성자 본인만 수정/삭제)
- 홈 대시보드에서 최신 프로젝트 · 미팅 요약

</td>
</tr>
</table>

---

## 기술 스택

| 분류 | 기술 | 비고 |
|---|---|---|
| **플랫폼** | iOS | |
| **언어** | Swift | |
| **UI 프레임워크** | SwiftUI | `@State` · `@Binding` · `NavigationView` · `TabView` |
| **네트워킹** | URLSession | POST · URL-encoded form data · `Codable` JSON 디코딩 |
| **백엔드** | PHP | REST API 48개 엔드포인트 |
| **데이터베이스** | MySQL | 팀 · 멤버십 · 프로젝트 · 태스크 · 미팅 · 공지 |
| **세션** | UserDefaults | `LoggedInUser`(userId) · `SelectedTeam`(teamId) 유지 |
| **이미지** | AsyncImage | 프로필 사진 비동기 로드 |

---

## 화면 구성 & 네비게이션 흐름

<table>
<tr><th>진입점</th><th>설명</th></tr>
<tr>
  <td><b>LoginView</b></td>
  <td>로그인 성공 → <code>getfavoriteteam.php</code> 호출<br>즐겨찾기 팀 있으면 <b>TeamHomeView</b> 바로 진입, 없으면 <b>TeamSelectView</b>로 이동</td>
</tr>
<tr>
  <td><b>SignupView</b></td>
  <td>회원가입 (특수문자·숫자 포함 유효성 검사)</td>
</tr>
</table>

<br>

**로그인 후 메인 탭 구성**

| 탭 | 화면 | 주요 기능 |
|---|---|---|
| 홈 | TeamHomeView | 최신 프로젝트·미팅 요약, 팀 전환, 역할별 프로필 진입 |
| 태스크 | TaskView | 태스크 생성·상세·수정, 상태 관리 |
| 미팅 | MeetingsView | 미팅 생성·목록·상세·수정 |
| 공지 | NoticeView | 공지 작성, 댓글 CRUD |
| 프로필 | ProfileView | 프로필 조회·수정·사진 업로드, 역할별 뷰 분리 |
| 관리 | ManagementView | 가입 신청 승인/거절, 멤버 역할 변경, 추방 (팀장 전용) |

---

## 핵심 구현

### 1. 로그인 → 팀 자동 진입 로직

로그인 성공 시 `UserDefaults`에 `userId`를 저장한 뒤 즉시 `getfavoriteteam.php`를 호출합니다. 즐겨찾기 teamId가 양수이면 `SelectedTeam`에 저장하고 TeamHomeView로 바로 이동하고, 0이면 팀 선택 화면으로 분기합니다.

> 즐겨찾기 팀은 `team_memberships` 테이블에서 `favorite = 1` AND `status = 0`(가입 완료) 조건으로 가장 최근 팀을 반환합니다.

| 반환값 | 처리 |
|---|---|
| teamId > 0 | `SelectedTeam` 저장 → TeamHomeView 바로 진입 |
| teamId = 0 | TeamSelectView로 이동 (팀 직접 선택) |

---

### 2. 팀 가입 신청 3-state 흐름

팀 목록에서 팀을 선택하면 `alreadyapplied.php`를 호출해 현재 신청 상태를 확인하고, 반환값에 따라 UI를 세 가지로 분기합니다.

| 반환값 | 상태 | UI |
|:---:|---|---|
| 0 | 미신청 | "가입 신청" 버튼 활성화 |
| 1 | 신청 중 | "신청 취소" 버튼 표시 |
| 3 | 가입 완료 | 팀 홈으로 즉시 이동 |

팀장 측에서는 `processapplication.php`에 `action: "approve"` 또는 `"reject"`를 전달해 신청을 승인/거절하며, 처리 후 신청자 목록을 자동으로 새로고침합니다.

---

### 3. 역할별 UI 완전 분리

프로필 탭 진입 시 `ifleader.php`를 호출해 역할 코드를 받고, 이에 따라 완전히 다른 뷰로 이동합니다. `NavigationLink`를 역할별로 분리해 팀원은 멤버 관리 탭 자체를 볼 수 없습니다.

| 역할 코드 | 이동 뷰 | 접근 가능 기능 |
|:---:|---|---|
| 0 (팀장) | LeaderProfileView | 가입 승인/거절, 추방, 부팀장 지정, 팀장 위임 포함 전체 |
| 1 (부팀장) | ViceLeaderProfileView | 멤버 조회, 일부 관리 |
| 2 (팀원) | MemberProfileView | 기본 기능만 |
| 7 | — | 미소속 상태 |

**역할별 기능 접근 요약**

| 기능 | 팀장(0) | 부팀장(1) | 팀원(2) |
|---|:---:|:---:|:---:|
| 멤버 관리 탭 | ✅ | ✅ (일부) | ❌ |
| 가입 신청 승인/거절 | ✅ | ❌ | ❌ |
| 팀원 추방 | ✅ | ❌ | ❌ |
| 부팀장 지정/해제 | ✅ | ❌ | ❌ |
| 팀장 권한 위임 | ✅ | ❌ | ❌ |
| 프로젝트 · 태스크 | ✅ | ✅ | ✅ |
| 공지 · 미팅 | ✅ | ✅ | ✅ |

---

### 4. URLSession 네트워킹 패턴

모든 API 요청은 **POST + URL-encoded form data** 방식으로 통일합니다. 응답은 `Codable`로 디코딩하고, UI 업데이트는 반드시 `DispatchQueue.main.async` 블록 안에서 처리합니다.

세션 유지는 `UserDefaults`로 처리하며 두 개의 키를 사용합니다.

| 키 | 값 | 시점 |
|---|---|---|
| `LoggedInUser` | userId (Int) | 로그인 성공 시 저장 |
| `SelectedTeam` | teamId (Int) | 팀 진입/전환 시 저장 |
| (삭제) | — | 로그아웃 시 두 키 모두 제거 |

---

## API 엔드포인트 48개

<details>
<summary>전체 목록 펼쳐보기</summary>

| 카테고리 | 엔드포인트 | 메서드 | 반환값 |
|---|---|---|---|
| **인증** | `login.php` | POST | userId (정수) |
| | `signup.php` | POST | 1=성공, -1=이메일 중복 |
| | `accountexist.php` | POST | 계정 존재 여부 |
| **팀** | `createteam.php` | POST | 생성된 teamId |
| | `getteams.php` | POST | 전체 팀 목록 JSON |
| | `getmyteams.php` | POST | 내 팀 목록 JSON |
| | `getlatestteam.php` | POST | 최근 팀 JSON |
| | `getfavoriteteam.php` | POST | 즐겨찾기 teamId |
| | `setfavoriteteam.php` | POST | 성공 여부 |
| | `switchteam.php` | POST | 전환된 팀 JSON |
| | `applyTeam.php` | POST | 신청 결과 |
| | `alreadyapplied.php` | POST | 0=미신청, 1=신청중, 3=가입 |
| **프로젝트** | `createproject.php` | POST | 생성 결과 |
| | `getprojects.php` | POST | 프로젝트 목록 JSON |
| | `getlatestproject.php` | POST | 최신 프로젝트 JSON |
| | `projectcomplete.php` | POST | 완료 처리 결과 |
| | `ifprojectcomplete.php` | POST | 0=진행, 1=완료, 2=만료 |
| | `modifyproject.php` | POST | 수정 결과 |
| **태스크** | `create_task.php` | POST | 생성 결과 |
| | `gettasks.php` | POST | 태스크 목록 JSON |
| | `update_task_status.php` | POST | 상태 업데이트 결과 |
| | `delete_task.php` | POST | 삭제 결과 |
| **미팅** | `createmeeting.php` | POST | 생성 결과 |
| | `getmeetings.php` | POST | 미팅 목록 JSON |
| | `getlatestmeeting.php` | POST | 최신 미팅 JSON |
| | `meetinginfo.php` | POST | 미팅 상세 JSON |
| | `modifymeeting.php` | POST | 수정 결과 |
| **공지** | `createNotice.php` | POST | 생성 결과 |
| | `getNotices.php` | POST | 공지 목록 JSON |
| | `updateNotice.php` | POST | 수정 결과 |
| | `deleteNotice.php` | POST | 삭제 결과 |
| **댓글** | `createComment.php` | POST | 생성 결과 |
| | `getComments.php` | POST | 댓글 목록 JSON |
| | `updateComment.php` | POST | 수정 결과 |
| | `deleteComment.php` | POST | 삭제 결과 |
| **프로필** | `profile.php` | POST | 프로필 JSON |
| | `modifyprofile.php` | POST | 수정 결과 |
| | `uploadimage.php` | POST | 이미지 업로드 결과 |
| | `personalprofile.php` | POST | 개인 프로필 JSON |
| **멤버 관리** | `getteammembers.php` | POST | 멤버 목록 JSON (팀장용) |
| | `getteammembers_viceleader.php` | POST | 멤버 목록 (부팀장용) |
| | `processapplication.php` | POST | 승인/거절 결과 |
| | `removemember.php` | POST | 추방 결과 |
| | `ifleader.php` | POST | 0=팀장, 1=부팀장, 2=팀원 |
| | `setviceleader.php` | POST | 부팀장 지정 |
| | `unsetviceleader.php` | POST | 부팀장 해제 |
| | `transferleader.php` | POST | 팀장 권한 위임 |

</details>

---

## 트러블슈팅

### ① 로그인 후 홈 화면 기본 팀 선택 기준 부재

**문제**
사용자가 여러 팀에 동시 소속될 수 있는 구조에서, 로그인 시 어느 팀을 기본으로 표시할지 기준이 없었다. 첫 번째 가입 팀을 고정하면 실제 활동 팀과 무관하고, 매번 직접 선택하면 UX가 저하된다.

**해결**
로그인 성공 직후 `getfavoriteteam.php`로 즐겨찾기 팀을 조회해 2경로로 분기 처리했다. 즐겨찾기 teamId가 양수이면 바로 TeamHomeView로 이동하고, 0이면 TeamSelectView로 보낸다.

**결과**
재접속 시 마지막 즐겨찾기 팀으로 즉시 진입. 로그인 → 홈 진입 API 호출 최대 2회로 최소화.

---

### ② `onAppear` 재실행으로 팀 전환 후 이전 팀 데이터 덮어씌우기

**문제**
팀 전환 후 `TeamHomeView`가 다시 `onAppear`를 실행하면서, 전환 전 팀 ID로 다시 데이터를 조회해 방금 전환한 팀 정보가 이전 팀 데이터로 덮어씌워지는 문제가 발생했다.

**해결**
`TeamSwitchActive` Boolean 플래그를 도입했다. 팀 전환 직후 이 플래그가 `true`이면 `onAppear` 진입 시 데이터 재조회를 건너뛰고 플래그를 `false`로 초기화한다. 다음 번 `onAppear`부터는 정상적으로 조회가 실행된다.

**결과**
팀 전환 후 전환된 팀 데이터가 올바르게 유지됨.

---

### ③ 댓글 · 공지 수정/삭제 권한 — 서버 검증 없이 UI만 제어

**문제**
댓글 수정/삭제 버튼을 작성자 본인에게만 표시했지만, API 요청 자체는 누구나 보낼 수 있어 클라이언트 UI 제어만으로는 권한이 보장되지 않는 구조였다.

**해결**
PHP 엔드포인트(`deleteComment.php` 등)에서 요청과 함께 전달된 `user_id`를 DB의 작성자 ID와 대조 검증한다. 불일치 시 `"unauthorized"`를 반환하고 처리를 중단한다.

**결과**
클라이언트 UI 제어 + 서버 측 권한 검증 이중 적용으로 무단 수정/삭제 차단.

---

## 팀 구성 & 역할

| 팀원 | 담당 기능 |
|---|---|
| 👤 **본인** | **팀 생성 · 전환 · 가입 신청 흐름 구현**, 즐겨찾기 기반 로그인 자동 팀 진입 로직, `alreadyapplied.php` 3-state 처리, `TeamSwitchActive` 플래그 설계 |

---

<div align="center">

**iOS 팀 프로젝트 4인 | SwiftUI + PHP REST API 48개 엔드포인트**


</div>
