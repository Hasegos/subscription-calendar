# 구독 달력

## 📁 프로젝트 개요

+ 로그인 없이 로컬(오프라인) 에서만 동작하는 구독 관리 앱입니다.

+ 구독 결제일을 달력으로 확인하고, 월 환산 지출/카테고리 분석, 해지·절감 시뮬레이션, 결제 리마인더 로컬 알림까지 제공합니다.

+ 프로젝트 기간 : 2026.01.08 ~ 2026.01.22

## 🤝 팀 소개
<table border= 1px solid>
  <thead>
      <tr><td colspan=1 align="center">Solo Project</td></tr>
  </thead>
  <tr align="center">   
    <td>Hasegos (최수호)</td>   
  </tr>
  <tr>
    <td>
        <a href=https://github.com/Hasegos>
            <img object-fit=fill src=https://avatars.githubusercontent.com/u/93961708?v=4 width="200" height="200" alt="깃허브 페이지 바로가기">
        </a>
    </td>    
  </tr>
</table>

## 🛠️ 기술 스택

+ **Frontend (Mobile)**: <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" /> <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
+ **Tooling**: <img src="https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white"> <img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=Figma&logoColor=white"> <img src="https://img.shields.io/badge/discord-5865F2?style=for-the-badge&logo=discord&logoColor=white">

## 📁 디렉토리 구조

```
📦 subscription-calendar/
├── 📁 lib/
│   ├── 📌 constants/
│      └── app_constants.dart       # 앱 색상, 텍스트 스타일 등 전역 상수
│   ├── 🧾 models/
│   │   └── subscription.dart        # 구독 정보 데이터 모델
│   ├── 📱 screens/                  
│   │   ├── analytics_screen.dart    # 지출 분석 및 차트 화면
│   │   ├── calendar_screen.dart     # 구독 결제일 확인 달력 화면
│   │   ├── home_screen.dart         # 대시보드 및 구독 리스트 메인 화면
│   │   ├── onboarding_screen.dart   # 앱 가이드 및 시작 화면
│   │   ├── savings_simulator_screen.dart # 절약 시뮬레이션 계산기 화면
│   │   └── settings_screen.dart     # 프로필 및 앱 설정 화면
│   ├── 🔌 services/
│   │   ├── notification_service.dart  # 푸시 알림 로직
│   │   └── storage_service.dart       # 데이터 저장(DB) 로직
│   ├── 🧰 utils/
│   │   ├── category_utils.dart        # 카테고리 분류 관련 유틸
│   │   ├── format_utils.dart          # 통화, 날짜 포맷 변환
│   │   ├── helpers.dart               # 범용 도구 함수
│   │   └── subscription_utils.dart    # 구독 데이터 처리 비즈니스 로직
│   ├── 🧩 widgets/
│   │   ├── add_subscription_modal.dart # 구독 추가 모달 위젯
│   │   └── subscription_card.dart     # 리스트 항목 카드 위젯
│   └── 🚀 main.dart                  # 앱 실행 진입점
├── 🤖 android/                      # Android 네이티브 설정 (패키지명, 권한 등)
└── pubspec.yaml                     # 외부 패키지(intl 등) 및 에셋 경로 설정
```

## 📊 ERD (Entity Relationship Diagram)

### 💳 Subscription (구독 정보)

| 필드명 (Field) | 타입 (Type) | 기본값 (Default) | 설명 (Description)                   |
|----|----|----|------------------------------------|
| id | String | - | 구독 항목 고유 식별자 (PK)                  |
| name |String | - | 구독 서비스 명칭 (예: Netflix)             |
| amount | double | - | 정기 결제 금액                           |
| cycle | Enum | - | "결제 주기 (monthly, yearly)"          |
| billingDay | int | - | 매달/매년 결제 예정일 (1~31)                |
| category | Enum | - | "서비스 카테고리 (video, music, cloud 등)" |
| memo | String? | null | 사용자 추가 메모 (선택 사항)                  |
| pinned | bool | false | 목록 상단 고정 여부                        |
| createdAt | String | - | 데이터 생성 일시 (ISO8601)                |
| reminderEnabled | bool | true | 결제일 전 알림 활성화 여부 |
| reminderDaysBefore | int | 3 | 결제일 몇 일 전 알림 발송 설정 |

### 📚 프로젝트 문서 / 회고

- 기획, 요구사항 정의, ERD 상세, 화면 설계, 회고는 아래 노션에 정리했습니다.
    - Notion: [구독 달력](https://www.notion.so/2e2be056f649808d9f18cb118420bf1f)

## 📱 화면 구성

### 홈 및 구독 관리

<img width=450 src="https://github.com/user-attachments/assets/11831efb-d962-4437-aa4a-5c90e53a2d0d">
<img width=450 src="https://github.com/user-attachments/assets/396c6d07-b893-499b-86d1-d5b8839ecaee">

+ 메인 대시보드: 이번 달 총 구독료와 현재 구독 중인 서비스 개수를 한눈에 확인합니다.
+ 구독 추가/편집: 서비스명, 금액, 결제 주기(매월/매년), 결제일, 카테고리, 메모를 설정하여 구독 정보를 등록합니다.
+ 퀵 서치: 상단 검색바를 통해 등록된 구독 서비스를 빠르게 찾을 수 있습니다.

---

### 달력 및 지출 분석

<img width=450 src="https://github.com/user-attachments/assets/a3d0c22b-dddc-4fa0-a195-5943a990b518">
<img width=450 src="https://github.com/user-attachments/assets/549aca8b-88da-4eb8-9d44-7a4454b1368b">

+ 결제일 달력: 달력 UI를 통해 날짜별 결제 예정 항목과 하루 총 결제 금액을 직관적으로 파악합니다.
+ 카테고리별 지출: 영상, 음악, 클라우드 등 카테고리별 지출 비중을 원형 차트(Pie Chart)로 시각화하여 보여줍니다.
+ 알림 예정 표시: 결제일 전 알림(D-Day) 설정 상태를 리스트에서 바로 확인합니다.

---

### 절약 시뮬레이션 및 설정

<img src="https://github.com/user-attachments/assets/0dc86951-46b6-407e-8da1-66458cdcfd54">
<img src="https://github.com/user-attachments/assets/4b8c8cbb-ff67-4e6b-a65e-8ef25efc3b9c">

+ 절약 시뮬레이터: 특정 구독 해지 시 줄어드는 월 지출액과 연간 총 절약 금액을 미리 계산해 볼 수 있습니다.
+ 오프라인 우선: 별도의 로그인 없이 모든 데이터는 기기 내 로컬 스토리지에 안전하게 저장됩니다.
+ 알림 설정: 결제일 3일 전(D-3) 오전 10시 등 원하는 시점에 리마인드 알림을 받을 수 있도록 설정합니다.

## ✨ 핵심 기능 (Core Features)

### 1) 온보딩 & 사용자 흐름

+ 첫 실행 가이드: 앱 설치 후 최초 실행 시 서비스의 주요 기능을 안내하는 온보딩 화면을 제공합니다.
+ 로컬 기반 시작: 별도의 로그인이나 회원가입 절차 없이, 데이터 저장소 초기화 후 즉시 메인 화면으로 진입하여 프라이버시를 보호합니다.

### 2) 💳 구독 관리 & 리마인드

+ 항목 관리: 구독 서비스의 이름, 금액, 결제 주기(월/년), 카테고리를 상세하게 등록하고 수정 및 삭제할 수 있습니다.
+ 스마트 리마인더: NotificationService를 통해 결제일 1~3일 전 사용자가 설정한 시간에 맞춰 로컬 푸시 알림을 발송합니다.

### 3) 결제 스케줄러 (달력)

+ 시각적 일정 확인: table_calendar를 활용하여 날짜별 결제 예정 항목과 하루 총 결제 금액을 직관적으로 표시합니다.
+ 결제일 보정 로직: 29~31일 결제 건이 해당 월에 없을 경우(예: 2월) 자동으로 말일로 보정하여 오차 없는 스케줄을 제공합니다.

### 4) 지출 분석 & 통계

+ 카테고리별 분포: fl_chart를 이용해 영상, 음악, 생산성 등 카테고리별 지출 비중을 원형 차트로 시각화합니다.
+ 월간 지출 요약: 이번 달 총 지출액과 구독 개수를 대시보드 형태로 제공하여 가계 경제 현황을 한눈에 파악합니다.

### 5) 절약 시뮬레이션 (Simulation)

+ 가상 해지 시나리오: 현재 구독 중인 항목을 해지했을 때 줄어드는 월 지출액과 연간 총 절약 예상 금액을 실시간으로 계산합니다.
+ 가상 추가 기능: 새로운 서비스를 구독하기 전, 해당 지출이 전체 예산에 미치는 영향을 미리 시뮬레이션해 볼 수 있습니다.

### 6) 설정 & 데이터 보안

+ 완전 오프라인 동작: 서버 통신 없이 StorageService를 통한 기기 내 로컬 저장 방식을 채택하여 개인정보 유출을 차단합니다.
+ 커스터마이징: 사용 중인 국가에 맞춘 통화 설정 및 알림 활성화 여부 등 사용자 맞춤형 환경 설정을 제공합니다.

## 📌 API 명세표

| 분류 | 기능명 | 메서드 / 경로         | 입력 데이터  | 설명                                    |
|----|----|------------------|---------|---------------------------------------|
| 데이터 | 구독 정보 로드 | `loadSubscriptions` | -       | `SharedPreferences`에서 JSON을 읽어 구독 리스트로 변환 | 
| 데이터 |구독 정보 저장 | `saveSubscriptions` | `List<Subscription>` | 구독 리스트를 JSON 문자열로 변환하여 로컬에 영구 저장      |
| 인증 | 온보딩 완료 확인 | `isOnboardingComplete` | -       | 앱 초기 가이드 종료 여부를 로컬 저장소에서 조회           |
| 인증 | 온보딩 완료 기록 | `completeOnboarding` | -       | 사용자가 가이드를 마쳤을 때 완료 플래그(`true`)를 저장      |
| 알림 |알림 서비스 초기화 | `initialize`       | -       | 타임존(`Asia/Seoul`) 및 플랫폼별 알림 플러그인 설정     |
| 알림 | 권한 요청 | `requestPermission` | -       | OS 수준의 알림 권한 팝업을 호출하고 허용 상태를 반환       |
| 알림 | 단일 알림 등록 | `scheduleSubscriptionReminder` | `Subscription` | 결제일 N일 전 오전 10시에 맞춰 로컬 푸시 알림을 예약      |
| 알림 | 전체 알림 재등록 | `scheduleAllReminders` | `List<Subscription>` |기존 예약된 모든 알림을 취소하고 리스트 기반으로 전수 예약 |
| 관리 | 특정 알림 삭제 | `cancelNotification` | `subscriptionId` | 구독 항목의 ID 해시코드를 이용해 예약된 특정 알림만 취소 |       
| 관리 | 전체 초기화 | `clearAll / cancelAll` | -       | 로컬 저장소 비우기 및 예약된 모든 알림 스케줄 삭제   |        