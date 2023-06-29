# no offset pagination

## 요약 : 정렬되고 중복이 존재하지않는 인덱스 필드를 가지는 무한 스크롤 방식에 유용

## 1. no-offset 페이지네이션이란

no offset 페이지네이션이란, 말 그대로 offset을 사용하지 않고 페이지네이션을 진행한다는 말입니다.

이 offset, 즉 몆번째 부터 시작할 것인지를 offset을 사용하지 않고 판단하는 것에 목적을 둠

약 1000만 건이 넘는 Row를 가진 Table을 검색하며 Paging 검색 쿼리의 최적화가 필요하다

<br>

```
- 일반적인 페이지네이션
  - limit과 offset 명령어를 이용하면, offset(어디부터) limit(몆개의) 데이터를 불러올지 결정하고 
  - 이를 이용해, offset을 페이지 넘버로 활용을 합니다.
  - (offset = page size * page number)
  - 
```


## 2. No offset 페이지네이션 과 offset 페이지네이션의 성능 차이

- 문제 1. 가장 기본적인 off-set 기반 페이지네이션이 full Scan 방식을 띈다
  - 페이수가 늘어날수록 성능이 저하
  - spring이 제공하는 jpa pagination 또한, query가 full scan offset paginantion으로 조회가 된다.

<h4>700만개 아이템 조회로 테스트 해보기</h4>

## 3. no-offset 페이지네이션 사용하기

- sql에서는 우리가 흔하게 사용하는 where index = ? 라는 조건문을 통해 쉽게 특정 위치를 지정할 수 있습니다.

- 아주 간단하게 이렇게 사용할 수 있는것이죠

  - ex)  select * from table_name where idx > 0 limit 20;

<br>

<h4>구현 조건</h4>

1. 정렬된, 인덱스 값이 있어야한다.
2. 인덱스 key 값에 중복이 있으면 안된다. (데이터가 누락될 수 있음)
3. 페이징 버튼(1,2,3)을 사용하는 경우, 사용이 어렵다


## 4. 페이징 성능 개선 - 커버링 인덱스 사용을 통한 late row lookup 최대화

<h4>Pagination 최적화는 다음의 방법이 있었습니다.</h4>

- 검색 조건에 대한 Index 생성
- sql 최적화 (LIMIT -> JOIN 변경)

커버링 인덱스 : 쿼리를 충족시키는 데 필요한 모든 데이터를 갖고 있는 인덱스

ex > select, where, order by, limit, group by 등에서 사용되는 모든 컬럼이 Index 컬럼안에 다 포함된 경우


예를 들어 아래와 같은 페이징 쿼리를

```sql
SELECT *
FROM items
WHERE 조건문
ORDER BY id DESC
OFFSET 페이지번호
LIMIT 페이지사이즈

```

아래처럼 처리한 코드를 이야기합니다

```sql
SELECT  *
FROM  items as i
JOIN (SELECT id
    FROM items
    WHERE 조건문
    ORDER BY id DESC
    OFFSET 페이지번호
    LIMIT 페이지사이즈) as temp 
on temp.id = i.id
```

위 쿼리에서 커버링 인덱스가 사용된 부분이 JOIN에 있는 쿼리입니다.

select절을 비롯해 order by, where 등 쿼리 내 모든 항목이 인덱스 컬럼으로만 이루어지게 하여 인덱스 내부에서 쿼리가 완성될 수 있도록 하는 방식

커버링 인덱스로 빠르게 걸러낸 row의 id를 통해 실제 select 절의 항목들을 빠르게 조회해오는 방법

<h4>커버링 인덱스는 왜 빠른가?</h4>

일반적으로 인덱스를 이용해 조회되는 쿼리에서 가장 큰 성능 저하를 일으키는 부분은

`인덱스를 검색하고 대상이 되는 row의 나머지 컬럼값을 데이터 블록에서 읽을 때` 입니다.

<h4>커버링 인덱스 사용 시 주의 점</h4>

1. ORDER BY에는 desc index가 적용되지 않는다 (MySQL 8.0 전까지)
   - 단지 scan 방식만 선택가능하다 
   - 만들어진 index 블록을 앞에서 읽을지 / 뒤에서부터 읽을지
2. ORDER BY 역시 GROUP BY와 마찬가지로 인덱스 순서대로 컬럼을 지정하면 인덱스를 사용할 수 있다
3. GROUP BY와 함께 쓸때는 둘다 인덱스를 적용할 수 있는 조건이어야 한다
   - 그렇지 않을 경우 인덱스를 활용하지 못한다.

## 5. 구현

### 현재 프로젝트 상황

경매 목록 조회가 굉장히 많을 것이라는 가정하에 조회 성능을 개선하고자 한다

이전 프로젝트에서 페이지네이션 조차 없이 목록 조회를 구현했다.

그래서 이번에 페이지네이션을 적용하고자 했다.

페이지네이션은 넘버링이 아닌 무한스크롤에 적합하도록  slice 방식을 적용하고자 한다.

jpa에서 제공하는 Paging 기능이 있다.

하지만 페이지네이션의 문제인 1000000번 글부터 100개의 경우 쿼리가 

`select * from table limit 1000000, 100;` 과 같은 형태로 생성된다.

이는 db 조회할 때 1000000 개의 아이템을 조회한 후 1000001~1000100번까지의 아이템을 반환한다.

이로 인해 offset이 커질 수록 성능 저하가 발생함.

<br>

### 해결 방법

이를 개선하기 위해 여러 기법이 적용될 수 있다.

1. no offset pagination
    
    페이지 기반 페이지네이션이 아닌 슬라이스 기반 페이지네이션을 구현할 때 적용할 수 있다.
    
    클러스터링 인덱스를 이용하고 조회 위치를 찾은 후 원하는 갯수의 아이템을 조회함으로써 불필요한 offset 조회 연산을 생략함으로써 late row lookup을 통해 성능 개선했다.
    
    `select * from coredb.auction a1 where a1.id < 2000000 and a1.is_close = false order by id desc limit 100;`
    
    (아래는 커버링 인덱스를 통해 페이지 기반 페이지네이션을 슬라이스에 맞게 수정한 query입니다.)
    
    `SELECT * FROM (select id from coredb.auction where id < 2000000 and is_close = false order by id desc limit 100 ) a1 Join coredb.auction a2 on a1.id = a2.id;`
    
    설명한 바와 같이 `offset` 또는, `limit {offset}, {limitNum}` 을 사용한 쿼리는 100만 건 이상 offset 발생할 시 시간이 매우 오래걸리는 것으로 볼 수 있었다.


    ![query tunning result](./image/%EC%BF%BC%EB%A6%AC%20%ED%8A%9C%EB%8B%9D%20%EA%B2%B0%EA%B3%BC.PNG)

그림과 같이 200만건 이후 100개를 조회할 시 16.266초가 걸리는 것으로 확인됐다.

당시 컴퓨터 리소스 사용률 등을 고려해야하겠지만, no offset pagination과  covering index를 이용하여 조회 성능이 0.000초 이하로 낮아진 것을 확인할 수 있다.

이를 Query DSL로 옮기고자 한다.

하지만 UI 제한으로 페이지 기반 페이지네이션을 해야할 경우, no offset pagination을 사용할 수 없다.

page 기반 pagination에서는 어떻게 성능 개선을 할 수 있을까?

1. 커버링 인덱스를 이용한 페이지네이션 구현

**Querydsl-JPA**

먼저 querydsl-jpa에서 커버링 인덱스를 사용해야 한다면 **2개의 쿼리로 분리**해서 진행할 수 밖에 없습니다.이유는 Querydsl-jpa에서는 **from절의 서브쿼리를 지원하지 않기 때문**

> JPQL자체에서 지원하지 않습니다.
> 

그래서 이를 우회하여  **Querydsl-jpa**로 구현하는 방법

- 커버링 인덱스를 활용해 조회 대상의 PK를 조회
- 해당 PK로 필요한 컬럼항목들 조회

```java
public List<BookPaginationDto> paginationCoveringIndex(String name, int pageNo, int pageSize) {
        // 1) 커버링 인덱스로 대상 조회
        List<Long> ids = queryFactory
                .select(book.id)
                .from(book)
                .where(book.name.like(name + "%"))
                .orderBy(book.id.desc())
                .limit(pageSize)
                .offset(pageNo * pageSize)
                .fetch();

        // 1-1) 대상이 없을 경우 추가 쿼리 수행 할 필요 없이 바로 반환
        if (CollectionUtils.isEmpty(ids)) {
            return new ArrayList<>();
        }

        // 2)
        return queryFactory
                .select(Projections.fields(BookPaginationDto.class,
                        book.id.as("bookId"),
                        book.name,
                        book.bookNo,
                        book.bookType))
                .from(book)
                .where(book.id.in(ids))
                .orderBy(book.id.desc())
                .fetch(); // where in id만 있어 결과 정렬이 보장되지 않는다.
}
```

****JdbcTemplate****

- 문자열 쿼리를 직접 사용하는 방식

- 커버링 인덱스를 `from`절에 그대로 사용

```java
public List<BookPaginationDto> paginationCoveringIndexSql(String name, int pageNo, int pageSize) {
String query =
        "SELECT i.id, book_no, book_type, name " +
        "FROM book as i " +
        "JOIN (SELECT id " +
        "       FROM book " +
        "       WHERE name LIKE '?%' " +
        "       ORDER BY id DESC " +
        "       LIMIT ? " +
        "       OFFSET ?) as temp on temp.id = i.id";

return jdbcTemplate
        .query(query, new BeanPropertyRowMapper<>(BookPaginationDto.class),
                name,
                pageSize,
                pageNo * pageSize);
}
```

최종적으로 나는 Query DSL과 covering index를 이용하여 late row lookup을 적용함으로써 조회 쿼리 성능을 개선할 수 있었다.

Query DSL을 선택함으로서 추후에 조회 조건 유무에 따른 동적 쿼리를 적용할 수 있었고, 관계테이블과의 join으로 조회 결과에 특정 컬럼을 추가할 수 있었다.

유지보수와 확장성이 훨씬 좋음을 느낄 수 있었다.

추후에 다른 도메인에서 목록 조회 시 같은 양식을 적용함으로써 빠르게 확장시킬 수 있었다.


### query DSL로 구현해보기

```java
@Override
public List<Auction> findAll(int lastId, int numOfRows) {
    QAuction a1 = new QAuction("a1");

    return queryFactory.select(auction)
            .from((EntityPath<?>) JPAExpressions.select(auction.id)
                    .from(auction)
                    .orderBy(auction.id.desc())
                    .offset(lastId)
                    .limit(numOfRows), a1)
            .join(auction)
            .on(auction.id.eq(a1.id))
            .fetch();
}
```

- 개선 : offset 말고 where절로 no offset 적용

    ```java
        List<Integer> ids = jpaQueryFactory
                .select(auction.id)
                .from(auction)
                .where(ltAuctionId(c.getLastId()))
                .orderBy(auction.id.desc())
                .limit(c.getLimit())
                .fetch();

        if(CollectionUtils.isEmpty(ids)){
            throw new NoContentException(ErrorMessageEnum.NO_MORE_AUCTION.getMessage());
        }
        QLikeAuction memberLikeAuction = new QLikeAuction("memberLikeAuction");

        return jpaQueryFactory
                .select(auction)
                .from(auction)
                .where(auction.id.in(ids))
                .orderBy(auction.id.desc())
                .groupBy(auction.id)
                .fetch();

    ```

### 요구사항

1. 경매 아이템별 유저가 좋아요하고 있는지 여부를 필드에 추가해주세요.

이전 프로젝트에서는 경매아이템 전체 조회 후 for-loof문을 돌면서 연관관계 정보를 조회 후 DTO를 작성하는 방식으로 했었다.

이를 개선하기 위해 페이지네이션을 커버링 인덱스를 적용하여 대량의 데이터에 대비하여 조회 성능을 개선했다. 이후 for-loof문을 돌지 않고 left join을 통해 연관 테이블을 조인 한 후 select절에 필요한 정보 컬럼을 추가했다.

```java
private final JPAQueryFactory jpaQueryFactory;
private final QAuction auction = QAuction.auction;
private final QLikeAuction likeAuction = QLikeAuction.likeAuction;

public List<AuctionConditionResDto> findAuctionsByCondition(AuctionConditionReqDto c, int memberId) throws NoContentException {
        // 1단계 커버링 인덱싱 서브 쿼리를 통해 원하는 Id 목록을 조회한다.
        // 동적 쿼리 조건을 통해 
        List<Integer> ids = jpaQueryFactory
                .select(auction.id)
                .from(auction)
                .where(
                        ltAuctionId(c.getLastId()),
                        onlySelling(c.isOnlySelling())
                )
                .orderBy(auction.id.desc())
                .limit(c.getLimit())
                .fetch();
        // 예외 처리
        if(CollectionUtils.isEmpty(ids)){
            throw new NoContentException(ErrorMessageEnum.NO_MORE_AUCTION.getMessage());
        }
        // 해당 컬럼의 좋아요 수를 계산하기 위해 첫번째 left join을 한다..
        // 유저가 해당 아이템을 좋아요 한지 안한지 여부 정보를 조회하기 위해 두번째 left 조인을 한다.
        QLikeAuction memberLikeAuction = new QLikeAuction("memberLikeAuction");
        // select 절에 필요한 컬럼을 추가하고 left 조인을 통해 
        return jpaQueryFactory
                .select(Projections.constructor(
                        AuctionConditionResDto.class,
                        auction,
                        likeAuction.id.count().as("cntLikeAuctions"),
                        memberLikeAuction.id.isNotNull().as("isLike"))
                )
                .from(auction)
                .where(auction.id.in(ids))
                .leftJoin(likeAuction).on(auction.id.eq(likeAuction.auction.id))
                .leftJoin(memberLikeAuction).on(
                        auction.id.eq(memberLikeAuction.auction.id).and(memberLikeAuction.liker.id.eq(memberId))
                )
                .orderBy(auction.id.desc())
                .groupBy(auction.id)
                .fetch();
    }

    private BooleanExpression ltAuctionId(int auctionId){
        if (auctionId == -1)
            return null;
        return auction.id.lt(auctionId);
    }
    private BooleanExpression onlySelling(boolean onlySelling){
        if (onlySelling)
            return auction.isClose.eq(false);
        return null;
    }
```

경매 아이템 500만개의 목데이터를 삽입한 후 테스트를 진행했다.

기존에 jpa가 제공하는 페이지네이션을 테스트해보지 않았지만, 연관관계가 없는 경우에도 길게는 수십, 짧게는 수초가 소요된다.

위와 같이 쿼리를 튜닝하여 실행시켰을 때 수 밀리언세컨드가 소요됨을 볼 수 있었다.