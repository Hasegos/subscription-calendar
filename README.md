# 구독 달력

## 📁 프로젝트 개요

- 로그인 없이 로컬(오프라인) 에서만 동작하는 구독 관리 앱입니다.
- 구독 결제일을 달력으로 확인하고, 월 환산 지출/카테고리 분석, 해지·절감 시뮬레이션, 결제 리마인더 로컬 알림까지 제공합니다.
- 프로젝트 기간 : 2026.01.08 ~ 2025.01.22

## 🤝 팀 소개
<table border= 1px solid>
  <thead>
      <tr><td colspan=1 align="center">Solo Project</td></tr>
  </thead>
  <tr align="center">   
    <td>이이언 (최수호)</td>   
  </tr>
  <tr>
    <td>
        <a href=https://github.com/Hasegos>
            <img object-fit=fill src=https://avatars.githubusercontent.com/u/93961708?v=4 width="200" height="200" alt="깃허브 페이지 바로가기">
        </a>
    </td>    
  </tr>
</table>

# 🛠️ 기술 스택
- **Frontend**: <img src="https://img.shields.io/badge/html5-E34F26?style=for-the-badge&logo=html5&logoColor=white"> <img src="https://img.shields.io/badge/css-1572B6?style=for-the-badge&logo=css3&logoColor=white"> <img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=JavaScript&logoColor=white"> <img src="https://img.shields.io/badge/Thymeleaf-005F0F?style=for-the-badge&logo=Thymeleaf&logoColor=white">
- **Backend**: <img src="https://img.shields.io/badge/java 17-007396?style=for-the-badge&logo=java&logoColor=white"> <img src="https://img.shields.io/badge/springboot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white">
- **Database**: <img src="https://img.shields.io/badge/postgresql-4169E1?style=for-the-badge&logo=postgresql&logoColor=white"> <img src="https://img.shields.io/badge/H2 Database-09476B?style=for-the-badge&logo=H2-Database&logoColor=white">
- **Infra/DevOps**: <img src="https://img.shields.io/badge/AWS EC2-%23FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white"> <img src="https://img.shields.io/badge/AWS S3-%23FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white"> <img src="https://img.shields.io/badge/GitHub Actions-181717?style=for-the-badge&logo=github-actions&logoColor=white">
- **Tooling**: <img src="https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white"> <img src="https://img.shields.io/badge/notion-000?style=for-the-badge&logo=Notion&logoColor=white"> <img src="https://img.shields.io/badge/Intellij IDEA-000000?style=for-the-badge&logo=Intellij-IDEA&logoColor=white">

## 📁 디렉토리 구조

```
repoboard/
├── 📦 io.github.repoboard/   # 애플리케이션 Java 패키지 루트
│   ├──   common/             # 공통 도메인·유틸·예외 모듈
│   │   ├──  domain/          # BaseTime 등 공통 엔티티, 생성/수정 시간·주체(Auditor) 자동 주입
│   │   ├──  event/           # S3 객체 완전 삭제 등 도메인 이벤트 처리
│   │   ├──  exception/       # GitHub API rate limit, Content-Type 오류용 커스텀 예외
│   │   ├──  handler/         # 전역 예외 처리 핸들러 (API/MVC 공통)
│   │   ├──  util/            # README 마크다운 정제 및 README 조회 전략 유틸
│   │   ├── ✅ validation/    # 커스텀 Validator 및 검증 애노테이션
│   ├── 🧭 controller/        # 웹 요청 처리 컨트롤러
│   ├── 📨 dto/               # 레이어 간 데이터 전송 DTO
│   │   ├──  auth/            # 로그인·회원가입용 사용자 DTO
│   │   ├──  github/          # GitHub API 응답 매핑용 DTO
│   │   ├──  request/         # 비밀번호 변경, 레포 저장 등 요청 전용 DTO
│   │   ├──  strategy/        # 검색 쿼리 전략/파라미터 보관용 DTO
│   │   ├──  view/            # 화면 렌더링 전용 View DTO
│   ├── 🧩 model/             # JPA 엔티티 및 도메인 모델
│   │   ├──  enums/           # 도메인에서 사용하는 Enum 타입 모음
│   ├── 🗂️  repository/       # Spring Data JPA 리포지토리 인터페이스
│   ├── 🔐 security/          # 인증·인가 및 보안 관련 구성
│   │   ├── ⚙️ config/        # Security, PasswordEncoder, JPA, Cache, WebClient 등 설정
│   │   ├── ⚙️ core/          # 로컬 로그인 사용자 Principal(CustomUserPrincipal 등)
│   │   ├── ⚙️ oauth2/        # GitHub/Google OAuth2 로그인 사용자 처리
│   │   ├── ⚙️ userdetails/   # CustomUserDetailsService 구현체
│   ├── 🧠 service/           # 비즈니스 로직 및 트랜잭션 처리
│   └── 🚀 RepoBoardApplication.java  # Spring Boot 메인 실행 클래스

├── 📁 resources/
│   ├── 🌐 static/            # 정적 자원 (브라우저에서 직접 접근)
│   │   ├── 🎨 css/           # 전역·페이지별 스타일시트
│   │   ├── 🖼️ images/        # 정적 이미지 리소스
│   │   └── ⚙️ js/            # 화면 동작용 자바스크립트
│   ├── 📄 templates/         # Thymeleaf 템플릿
│   │   ├── 💬 admin/         # 관리자 기능 관련 뷰
│   │   ├── 🔐 auth/          # 로그인/회원가입 등 인증 관련 뷰
│   │   ├──  fragment/        # 공통 레이아웃 (header/footer 등)
│   │   ├──  profile/         # 사용자 오픈 프로필 관련 뷰
│   │   ├── 🧩 repository/    # 저장 레포 목록·상세 관련 뷰
│   │   ├──  search/          # GitHub 레포·유저 검색 관련 뷰
│   │   ├── 📝 setting/       # 계정·비밀번호 등 사용자 설정 뷰
│   │   └── 🏠 home.html      # 홈 화면 뷰 (루트 페이지)
│   └──  application.yml              # 공통 설정(프로필 공통으로 사용하는 기본 설정)
│   └──  application-dev.yml          # 개발 환경 프로필 설정
│   └──  application-example-prod.yml # 운영 환경 예시 설정(민감 정보 제거용 샘플)
│   └──  application-prod.yml         # 실제 운영 환경 설정(GitHub Secret/환경 변수와 연동)
│   └──  logback-spring.xml           # 애플리케이션·관리자 로그 설정
```

## 📊 ERD (Entity Relationship Diagram)

### 🗺️ ERD 개요

<img width="800" height="484" alt="Image" src="https://github.com/user-attachments/assets/94605594-064a-43e2-a007-2f901cd242b7" />

### 📚 프로젝트 문서 / 회고

- 기획, 요구사항 정의, ERD 상세, 화면 설계, 회고(트러블슈팅 포함)는 아래 노션에 정리했습니다.
    - Notion: [RepoBoard 프로젝트 문서](https://www.notion.so/RepoBoard-25cbe056f64980f49b2dd62d7c029bda)

## 🗏 페이지 구성

### 메인 페이지

<img width="700" height="600" alt="Image" src="https://github.com/user-attachments/assets/33d9453a-a1f1-46aa-824b-47e574aef950" />

- 언어 버튼(Java, JS, Python 등)과 정렬 옵션(인기순 / 최신순)으로 GitHub 레포를 탐색한다.
- 미리 정의한 쿼리 전략(언어·기간·별점 조건)을 순환해 다양한 레포를 노출한다.
- WebClient와 GitHub Search API, Caffeine 캐시를 이용해 레포 조회 성능과 호출 빈도를 최적화한다.
- 화면에서는 무한 스크롤을 사용해 목록을 계속해서 로딩하고, Rate Limit 발생 시 재시도 지연 및 안내 메시지를 표시한다.

---

### 로그인 / 회원가입 페이지

<img width="400" height="350" alt="Image" src="https://github.com/user-attachments/assets/802da984-66ee-4272-9995-455b56803dcc" />
<img width="400" height="350" alt="Image" src="https://github.com/user-attachments/assets/fd2cba5c-4428-468f-ba59-e28e3441fbea" />

- 폼 로그인(이메일/비밀번호)과 GitHub·Google OAuth2 로그인을 모두 지원한다.
- 회원가입 시 서버 단에서 이메일 중복, 비밀번호 규칙 등을 `@Valid`와 `BindingResult`로 검증한다.
- OAuth2 로그인 시 신규 사용자는 자동으로 `User` 엔티티가 생성되고, GitHub 프로필 정보를 기반으로 오픈 프로필이 초기화된다.
- 이미 로그인된 사용자가 로그인 페이지에 접근하면 메인 페이지로 리다이렉트한다.

---

### 오픈 프로필 설정 / 보기 페이지

<img width="400" height="350" alt="Image" src="https://github.com/user-attachments/assets/d1b3aff3-7590-4b53-a8d8-ad17af886433" />
<img width="400" height="350" alt="Image" src="https://github.com/user-attachments/assets/2adce381-dca8-46ed-8869-d4512f3c2b59" />

- 최초 접속 시 GitHub 프로필 URL 또는 username을 입력해 오픈 프로필을 생성할 수 있다.
- GitHub API를 통해 아바타, 이름, bio, followers, 공개 레포 수 등을 주기적으로 새로고침한다.
- 프로필 공개 범위(PUBLIC / PRIVATE)를 토글해 다른 사용자에게 내 저장 레포를 공개할지 여부를 제어한다.
- 프로필 이미지는 S3에 저장하며, 변경 과정에서 더 이상 사용하지 않는 객체는 도메인 이벤트를 통해 정리한다.

---

### 저장한 레포지토리 페이지

<img width="700" height="600" alt="Image" src="https://github.com/user-attachments/assets/9f1cf5f6-14d1-4047-ae34-cd4938a7dad3" />

- 내가 저장한 레포를 **핀 고정 영역**과 **일반 영역**으로 구분해 보여준다.
- 언어 필터와 정렬 옵션(인기순 / 최신순), 페이지네이션을 지원해 저장 레포를 효율적으로 탐색할 수 있다.
- 각 레포 카드에서 개인 메모 작성·수정, 핀 고정/해제, 삭제와 같은 관리 기능을 제공한다.
- 저장된 레포의 README를 GitHub에서 가져와 HTML로 렌더링하고, 콘텐츠 타입 오류나 404 등 예외 상황은 전용 예외 클래스로 처리한다.

---

### 검색 페이지

<img width="400" height="350" alt="Image" src="https://github.com/user-attachments/assets/a5562891-a27a-4827-babf-638dc02d22f8" />
<img width="400" height="350" alt="Image" src="https://github.com/user-attachments/assets/f33ea877-b77f-4f75-ab31-bf634cdb7bd6" />

- 하나의 검색 진입 화면에서 “레포지토리 검색”과 “사용자 검색” 중 원하는 검색 타입을 선택할 수 있다.
- 레포지토리 검색은 언어, 정렬 기준, 검색어를 조합해 GitHub 레포를 조회하고, 추가 결과는 스크롤을 통해 점진적으로 불러온다.
- 사용자 검색은 GitHub username을 기준으로 오픈 프로필이 공개된 사용자를 찾고, 해당 사용자가 RepoBoard에 저장한 레포 목록까지 함께 제공한다.
- 검색어는 Sanitize 유틸을 통해 XSS·스크립트·Markdown 링크 등을 제거한 뒤 처리해 보안과 안정성을 확보한다.

---

### 설정 페이지

<img width="400" height="350" alt="Image" src="https://github.com/user-attachments/assets/af16d8bb-f203-493a-b571-21caba7ef4bc" />
<img width="400" height="350" alt="Image" src="https://github.com/user-attachments/assets/4bdff4e0-cc98-4250-8ed2-c3c9aaefbfe1" />

- 로그인 타입(LOCAL / OAuth2)에 따라 서로 다른 설정 화면을 제공한다.
- LOCAL 계정 사용자는 현재 비밀번호 검증을 거쳐 새 비밀번호로 변경할 수 있다.
- 모든 사용자는 계정 삭제 기능을 통해 서비스를 탈퇴할 수 있으며, 삭제 시 `DeleteUser` 엔티티에 사용자와 프로필 정보가 백업된다.

---

### 관리자 페이지

<img width="400" height="350" alt="Image" src="https://github.com/user-attachments/assets/d879e559-aa10-47d0-860f-d135ebce1c79" />
<img width="400" height="350" alt="Image" src="https://github.com/user-attachments/assets/20771449-5844-440c-b30a-222a7db82c87" />

- 전체 사용자 목록과 삭제된 사용자 기록을 한 화면에서 관리할 수 있다.
- 관리자는 개별 사용자에 대해 계정 삭제, 삭제된 계정 복원, 상태(ACTIVE / SUSPENDED) 전환 등의 액션을 수행할 수 있다.
- 별도의 로그 화면에서 관리자 계정이 수행한 삭제·복원·상태 변경 같은 모든 관리자 액션 이력을 조회할 수 있다.
- 관리자 영역과 모니터링용 엔드포인트는 관리자 권한(ROLE_ADMIN)을 가진 계정만 접근 가능하다.

---