# 소셜 로그인 구현 과정

## 의존성 추가

```gradle

dependencies {

    // [JWT]
    implementation 'io.jsonwebtoken:jjwt:0.9.1'
    implementation 'org.springframework.boot:spring-boot-starter-security'
}

```


## Config 작성


### 1. PasswordEncoder

- Bean으로 등록하여 회원가입 진행 시, 비밀번호를 해시하여 저장한다.

<br>

### 2. SecurityFilterChain

Spring Security FilterChain 방식으로 인증 과정

- **cors와 csrf를 disable**
    - SOP(Same-Origin Policy) 정책에 의한 개발의 불편함을 보완하고자 리소스 요청은 출처가 다르더라도 허용하기로 했는데, 그 중 하나가 “CORS 정책을 지킨 리소스 요청이다. Access-Control-Allow-Origin 설정으로 접근 허용할 출처를 제한할 수 있다.
    - CSRF(Cross Site Request Forgery) 공격에 대응하기 위해 FORM 형식의 전송에서 CSRF 토큰을 주고받으며 일치할 때 렌더링되도록 한다. REST API에서는 HTML같은 리소스를 주고받지 않기 때문에 disable 설정하더라도 문제가 되지 않는다.

- authorizeRequests()를 통해 인증된 사용자만 접근할 수 있도록 설정한다.
- antMatchers를 통해 특정 URI  접근

```java

@Configuration
@EnableWebSecurity // security 설정 활성화
public class AppConfig {

    //사용자가 전달해준 비밀번호 해시화
    @Bean
    public PasswordEncoder passwordEncoder(){
        return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }

    private static final String[] ALLOWED_ENDPOINT = {
            "/api/v1/members/login-kakao"
    };

    /**
     * @param http : filterchain을 거치는 요청 http
     * @return http에 authorizedRequests 설정 추가 후 리런. 특정 url 접근 허용
     * @throws Exception
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.cors().and().csrf().disable()
                .authorizeRequests()
                .antMatchers(ALLOWED_ENDPOINT).permitAll()
                .anyRequest().authenticated();
        return http.build();
    }
}

```

<br>

### 프로젝트 설정 파일(application.yml) 작성

```YAML
spring:
  jwt:
    key: secret-key
    live:
      atk: 36000000 # 100시간   
```

## 3. MemberController , MemberService

<h3>accesstoken 파라미터를 받아 kakaologin 처리로 넘겨줄 컨트롤러</h3>

```java
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/members")
public class MemberController {

    private final MemberService memberService;

    @GetMapping("/kakao-login")
    public ResponseEntity<TokenResDto> kakaoLogin(@RequestParam String accessToken) throws JsonProcessingException {
        TokenResDto token = memberService.kakaoLogin(accessToken);
        return ResponseEntity.status(HttpStatus.OK).body(token);
    }

}

```

<h3>MemberServiceImpl</h3>

1. "인가 코드"로 "액세스 토큰" 요청 -> 안드로이드에서 엑세스 토큰을 전송해주기 때문에 생략
2. 토큰으로 카카오 API 호출
3. 카카오ID로 회원가입 처리
4. 강제 로그인 처리
5. response Header에 JWT 토큰 추가

```java


@Service
@RequiredArgsConstructor
public class MemberServiceImpl implements MemberService, UserDetailsService {

    private final MemberRepository memberRepository;
    private final JwtProvider jwtProvider;
    public TokenResDto kakaoLogin(String accessToken) throws JsonProcessingException {
        // 1. "인가 코드"로 "액세스 토큰" 요청 -> 안드로이드에서 엑세스 토큰을 전송해주기 때문에 생략
//        String accessToken = getAccessToken(code);
        // 2. 토큰으로 카카오 API 호출
        SocialMemberInfoDto kakaoUserInfo = getKakaoUserInfo(accessToken);
        // 3. 카카오ID로 회원가입 처리
        Map<String, Object> resMap = signupKakaoUserIfNeed(kakaoUserInfo);
        // 4. 강제 로그인 처리
        Authentication authentication = forceLogin((Member)resMap.get("member"));
        // 5. response Header에 JWT 토큰 추가
        TokenResDto token = KakaoMemberAuthenticationInput(authentication, (Boolean)resMap.get("isExist"));

        return token;
    }

    /** 1. "인가코드"로 "액세스 토큰" 요청
     * @param code : 인가 코드
     * HTTP Header, Body에 필요한 정보들을 담기
     * client_id : kakao developers에서 제공된 REST API키
     * redirect_uri : redirect할 callback uri 넣기(http://localhost:8080/user/kakao/callback, 배포시 변경 요)
     * ** 해당 callback url을 kakao developers에 등록해 놓아야 한다
     * @return http 요청을 보내서 돌아온 응답에서 access token parsing
     * @exception : JsonProcessingException, responseBody 파싱 과정에서 발생
     */
    private String getAccessToken(String code) throws JsonProcessingException {

        // HTTP Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-type", "application/x-www-form-urlencoded;charset=utf-8");

        // HTTP body 생성
        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("grant_type", "authorization_code");
        body.add("client_id", "CLIENT_ID");
        body.add("redirect_uri", "http://localhost:8087/api/v1/members/kakao-login");
        body.add("code", code);

        // HTTP 요청 보내기
        HttpEntity<MultiValueMap<String, String>> kakaoAccessTokenReq = new HttpEntity<>(body, headers);
        RestTemplate rt = new RestTemplate();
        ResponseEntity<String> response = rt.exchange(
                "https://kauth.kakao.com/oauth/token",
                HttpMethod.POST,
                kakaoAccessTokenReq,
                String.class
        );

        // Http 응답(JSON) -> 엑세스 토큰 파싱
        String responseBody = response.getBody();
        ObjectMapper objectMapper = new ObjectMapper();
        JsonNode jsonNode = objectMapper.readTree(responseBody);
        return jsonNode.get("access_token").asText();
    }

    /** 2. 토큰으로 카카오 API 호출
     * @param accessToken :  액세스 토큰으로 카카오 API를 호출
     * @return SocialMemberInfoDto : 카카오에서 받은 사용자 이메일이 담긴 DTO
     */
    private SocialMemberInfoDto getKakaoUserInfo(String accessToken) throws JsonProcessingException {
        // HTTP Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + accessToken);
        headers.add("Content-type", "application/x-www-form-urlencoded;charset=utf-8");

        // HTTP 요청
        HttpEntity<MultiValueMap<String, String>> kakaoUserInfoRequest = new HttpEntity<>(headers);
        RestTemplate rt = new RestTemplate();
        ResponseEntity<String> response = rt.exchange(
                "https://kapi.kakao.com/v2/user/me",
                HttpMethod.POST,
                kakaoUserInfoRequest,
                String.class
        );

        // responseBody에 있는 정보를 꺼냄
        String responseBody = response.getBody();
        ObjectMapper objectMapper = new ObjectMapper();
        JsonNode jsonNode = objectMapper.readTree(responseBody);

        String email = jsonNode.get("kakao_account").get("email").asText();

        return new SocialMemberInfoDto(email);
    }

    /** 3. 카카오 email로 회원가입 처리
     * @param kakaoMemberInfo : 카카오로부터 받은 user info
     * @return Map<String, Object> : member 정보와 기존에 존재하던 사용자인지 아닌지 여부 정보
     */
    private Map<String, Object> signupKakaoUserIfNeed(SocialMemberInfoDto kakaoMemberInfo){

        Map<String, Object> resMap = new HashMap<>();
        Boolean isExist = true;
        Member member = memberRepository.findMemberByEmail(kakaoMemberInfo.getEmail())
                .orElse(null);

        // DB에 중복된 email 있는지 확인
        if (Objects.equals(member, null)){
            isExist = false;
            member = Member.builder().email(kakaoMemberInfo.getEmail()).build();
            memberRepository.save(member);
        }

        resMap.put("member", member);
        resMap.put("isExist", isExist);
        return resMap;
    }

    /** 4. 강제 로그인 처리
     * @param kakaoUser : 회원가입처리가 된 사용자 정보
     * @return authentication : 로그인 인증서
     */
    private Authentication forceLogin(Member kakaoUser) {
        UserDetails userDetails = new UserDetailsImpl(kakaoUser);
        Authentication authentication = new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(authentication);
        return authentication;
    }

    /** 5. response Header에 JWT 토큰 추가
     * @param authentication : 발급된 인증서
     * @param isExist : 기존 사용자 or 신규 사용자 구분 여부
     * @return TokenResDto :
     */
    private TokenResDto KakaoMemberAuthenticationInput(Authentication authentication, Boolean isExist) throws JsonProcessingException {
        // response header token 추가
        UserDetailsImpl userDetailsImpl = ((UserDetailsImpl) authentication.getPrincipal());
        String email = userDetailsImpl.getEmail();
        return jwtProvider.createTokenByLogin(memberRepository.findMemberByEmail(email).get(), isExist);
    }

```
## 4. UserDetails 커스텀

- 토큰에 담기는 User 정보 커스텀 

```java

public class UserDetailsImpl implements UserDetails {

    String nickname;
    String email;
    String profilePath;

    public UserDetailsImpl(Member member) {
        this.nickname = member.getNickname();
        this.email = member.getEmail();
        this.profilePath = member.getProfilePath();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        ArrayList<GrantedAuthority> auth = new ArrayList<>();
        auth.add(new SimpleGrantedAuthority("USER"));
        return auth;
    }
    public String getEmail(){
        return email;
    }
    ...
}

```
## 5. JwtProvider

- redis에 refresh 토큰 저장
- token 생성 후 발급

```java

@Component
@RequiredArgsConstructor
public class JwtProvider {
    private final ObjectMapper objectMapper;
    private final RedisDao redisDao;

    @Value("${spring.jwt.key}")
    private String key;
    @Value("${spring.jwt.live.atk}")
    private Long atkLive;
    @Value("${spring.jwt.live.rtk}")
    private Long rtkLive;

    @PostConstruct // 스프링 빈이 생성된 후 자동으로 초기화 메서드 실행
    protected void init() {
        // 키값을 암호화하여 저장
        key = Base64.getEncoder().encodeToString(key.getBytes());
    }

    public TokenResDto createTokenByLogin(Member member,boolean isExist) throws JsonProcessingException {
        // access token 생성
        String atk = createToken(Subject.atk(member), atkLive);
        String rtk = createToken(Subject.rtk(member), rtkLive);
        // Redis에 refresh token 관리
        redisDao.setValues(member.getEmail(), rtk, Duration.ofMillis(rtkLive));
        return TokenResDto.builder()
                .accessToken(atk)
                .refreshToken(rtk)
                .isExist(isExist)
                .build();
    }
    // 토큰은 발행 유저 정보, 발행 시간, 유효 시간, 그리고 해싱 알고리즘과 키를 설정
    private String createToken(Subject subject, Long tokenLive) throws JsonProcessingException {
        String subjectString = objectMapper.writeValueAsString(subject);
        Claims claims = Jwts.claims()
                .setSubject(subjectString);
        Date date = new Date();
        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(date)
                .setExpiration(new Date(date.getTime() + tokenLive))
                .signWith(SignatureAlgorithm.HS256, key.getBytes())
                .compact();
    }

    public Subject extractSubjectFromAtk(String atk) throws JsonProcessingException {
        // Jwt 파서에 key 설정 후 토큰 파싱 후 Claim 객체 가져옴
        String subjectStr = Jwts.parser()
                .setSigningKey(key.getBytes())
                .parseClaimsJws(atk).getBody()
                .getSubject();
        return objectMapper.readValue(subjectStr, Subject.class);
    }

}


```

## JwtAuthenticationFilter

블랙리스트 관리 로직
1. 리프레시 토큰은 클라이언트에서 항상 reissue API로 요청하기 떄문에 잘돗된 경로 필터링
2. 로그아웃 시 redis에 로그아웃한 access token을 access token 유효시간 만큼 저장
3. 로그아웃 후 access token을 삭제하지 않고 재사용 시 블랙리스트 필터링 처리

```java

@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    private final JwtProvider jwtProvider;
    private final MemberService memberService;
    private final RedisDao redisDao;
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String authorization = request.getHeader("Authorization"); // 헤더에서 Authentication 추출
        if (!Objects.isNull(authorization)) { // 헤더가 존재하는 경우 JWT 토큰 추출
            String atk = authorization.substring(7);
            /** 블랙리스트 관리 로직
             *  1. 리프레시 토큰은 클라이언트에서 항상 reissue API로 요청하기 떄문에 잘돗된 경로 필터링
             *  2. 로그아웃 시 redis에 로그아웃한 access token을 access token 유효시간 만큼 저장
             *  3. 로그아웃 후 access token을 삭제하지 않고 재사용 시 블랙리스트 필터링 처리
             */
            try {
                Subject subject = jwtProvider.extractSubjectFromAtk(atk); // JWT 토큰에서 Subject 객체를 추출
                String requestURI = request.getRequestURI();
                // refresh token을 담아서 요청보냈을 때 재발급 url로 접근하지 않는 경우 예외 처리
                if (subject.getType().equals("RTK") && !requestURI.equals("/api/v1/members/reissue")) {
                    throw new JwtException("refresh 토큰으로 접근할 수 없는 URI입니다.");
                }
                String isLogout = redisDao.getValues(atk);
                // redis에 토큰이 없는 경우 정상 처리
                if (ObjectUtils.isEmpty(isLogout)) {
                    UserDetails userDetails = memberService.loadUserByUsername(subject.getEmail());
                    Authentication token = new UsernamePasswordAuthenticationToken(userDetails, "", userDetails.getAuthorities());
                    SecurityContextHolder.getContext().setAuthentication(token);
                }
                // redis에 토큰이 있는 경우 블랙리스트 예외 처리
                else throw new JwtException("유효하지 않은 access 토큰입니다.");

            } catch (JwtException e) {
                request.setAttribute("exception", e.getMessage());
            }
        }
        filterChain.doFilter(request, response);
    }
}

```

## CustomAuthenticationEntryPoint

- 스프링 시큐리티에서 인증되지 않은 사용자가 보호된 자원에 액세스하려고 할 때 호출되는 클래스
- 로그인 페이지로 리디렉션하거나 인증 오류 메시지를 반환하는 역할


```java
@Component
@Slf4j
public class CustomAuthenticationEntryPoint implements AuthenticationEntryPoint {
    private final ObjectMapper objectMapper;

    public CustomAuthenticationEntryPoint(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }
    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException) throws IOException {
        String exceptionMessage = (String) request.getAttribute("exception");
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        JwtErrorMessageDto message = new JwtErrorMessageDto(exceptionMessage, HttpStatus.UNAUTHORIZED);
        String res = this.convertObjectToJson(message);
        response.getWriter().print(res);
    }

    private String convertObjectToJson(Object object) throws JsonProcessingException {
        return object == null ? null : objectMapper.writeValueAsString(object);
    }
}
```

