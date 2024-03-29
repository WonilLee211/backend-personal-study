# 캐싱의 개념과 적용

## 고품질의 AP를 추구한다면

1. 처리속도 / 성능
2. 안정성
3. 보안
4. 편리 + 환상적인 DX

## 응답 지연 시간 오름차순

1. 메모리에서 1MB 순차적으로 읽기 
2. 디스크에서 1MB 순차적으로 읽기
3. 한 패킷의 CA로부터 네덜란드까지의 왕복 지연

## 이미지 캐싱

### 1. 객체가 init될만 로딩해서 캐싱하기

```
바이트 array;

객체 init() 될 떄 {
    이미지 파일 = 파일(파일경로);
    바이트 array = 바이트 array로 변경(이미지 파일);
}
갤러리 이미지 전송(){
    네트워크 전송(바이트 array);
}

```

### 웹 서버 - 이미지 리소스

- 빈번한 요청과 더불어 변경이 거의 없을 경우는 서버에 저장해서 메모리에 올린 후 캐시를 사용하도록 한다.

<br>

2. 파일 변경 허용

```
바이트 array;

이미지 파일 이벤트 핸들러(){
    이미지 파일 변경 감지 시 (){
        갤러리 이미지 정보 수정();
    }
}

객체 init() 될 떄 {
    이미지 파일 = 파일(파일경로);
    바이트 array = 바이트 array로 변경(이미지 파일);
}
갤러리 이미지 전송(){
    네트워크 전송(바이트 array);
}

```

- 원본 파일 변경을 감지해 전송 대상 데이터를 갱신하는 로직 추가


# 실시간 지하철 현황 서비스

## 요구사항

1. 특정 지하철역의 실시간 열차 현황 정보를 제공
2. 정보 출처는 서울 열린 데이터 광장 open api
3. 출퇴근 시간 기준 역마다 대략 100건/초의 요청을 가정


## 구현

1. 역 기준 대략적인 지하철 도착 현황 정보만으로도 고객의 니즈를 충족
    - 10초 간격으로 WAS 내에 지하철 정보를 임시 저장하도록 구현

    ```
        지하철_도착현황(지하철역Id, 호선){
            if(지하철_현황정보 유효시간이 지났다면){
                지하철_현황정보 = http_openAPI 호출(지하철역ID);
            }
            return 지하철_현황정보;
        }
    ```


## cache에 적용에 고려할 점

- TTL을 잘 설정해서 데이터 싱클르 잘 맞춰야 한다.
- read가 빈번하고 write가 거의 없는 경우
- 메모리는 매우 중요한 자원이기에 신중하게 선별적 캐싱 정책이 중요하다.
- out of memory 나지 않도록 조심해야 한다.

## 직접 cache 구현

1. 메모리에 특정 객체를 생성한 후 캐싱하고자 하는 데이터를 저장
2. 단 해당 프로세스에서 유일한 저장 장소가 되도록 잘 선언해서 사용(싱글톤 패턴)

```java
    public class MenuRepos {
        manuList
        갱신시간

        getMenuList(){
            if( (현재 시간 - 갱신시간) > TTL ){
                menuList = getMenuListFromDB()
                갱신 시간 = 현재 시간
            }
            return menuList
        }
    }

```
3. 클러스터를 고려해야 함.
    - 다른 서버에서 사용할 캐시도 업데이트하는 걸 고민해야 함

<br>

### 로컬 캐시 - Ehcache

- 로컬 캐시 라이브러리
- WAS n대 클러스터링되어 있다면 동기화 이슈 발생
- WAS간 내부 통신을 통해 동기화 작업 선행
- Ehcache가 지원하는 RMI 활용한 클러스터링 설정 가능

```java
    @Cacheable(value="subwayInfoCache", key="#지하철역ID")
    public 지하철_현황정보 findByNameCache(String 지하철역ID){
        지하철_현황정보 = HTTP_openAPI호출(지하철역ID);
        return 지하철_현황정보;
    }
    <cache name="subwayInfoCache">
        maxEntriesLocalHeap="10000"
        maxEntriesLocalDisk="1000"
        eternal="false"
        diskSpoolBufferSizeMB="20"
        timeToLiveSeconds="10"
        memoryStoreEvictionPolicy="LFU"
        transactionalMode="off">
    </cache>
```

<br>

### 로컬 캐시 단점

- 타겟 AP이 여러 대의 머신으로 실행 중이라면 데이터 동기화 이슈가 발생한다.
- 캐시를 활용하려는 프로세스와 동일 머신의 리소스를 사용한다는 점은 매우 큰 단점

<br>

### redis 사용

- NoSQL & Cache 솔루션, 메모리 기반으로 구성
- in-memory DB
- 데이터베이스로 사용될 수 있으며 cache로도 사용할 수 있는 기술
- 약간의 데이터 통신에 대한 낭비를 손해보고 다른 이점을 얻는다.

# 캐싱 실전 적용

1. Cache의 기본적인 개념 파악 및 캐싱에 적합한 데이터 선색
2. 웹 AP 작성 코드에 상대적으로 느린 I/O(DB 연동) 데이터를 직접 특정 객체에 저장
3. 로컬 캐시 제품 적용해보기
4. in memory db 솔루션 redis 경험 해보기

