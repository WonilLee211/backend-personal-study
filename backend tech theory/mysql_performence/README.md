# 데이터베이스 성능

## 목차

- [인덱스](#1-인덱스)
- [query plan](#2-query-plan)


# 1. 인덱스

- database 분야에서 table에 대한 동작 속도를 높여주는 자료구조

## 1.1 종류

1. clustered index
2. nonClustered index

## 1.1.1 clustered index

- 군집화된 index
- 별도의 장소에서 관리되는 index

```sql
select * from tbl_code;

-- 인덱스 생성
alter table tbl_code add primary key (code);

```
- primary key가 생기자마자 clustered index가 생성됨
- code 기준 정렬 상태로 관리하면서 조회 성능이 향상된다.
- 인덱스는 B-tree 자료 구조로 형성된다.

<br>

### 단점

- 재정렬해야 하기 떄문에 `삽입 삭제할 때 비용이 많이 든다`.


## 1.1.2 nonClustered Index

```sql
-- 인덱스 생성(multi)
create index col_index on tbl_code(code, name);

```
- 인덱스 키의 값과 해당 레코드의 물리적인 위치(행 식별자)를 매핑한다
- 이러한 매핑 정보를 사용하여 데이터베이스에서 빠른 데이터 접근과 검색을 가능함
- 데이터베이스 테이블에 여러 개 생성할 수 있으며, 각 인덱스는 다른 인덱스 키로 구성된다

<br>

### 특징

- `데이터 정렬 순서`
    - 데이터 행의 물리적인 저장 순서와는 관련이 없다. 
    - 테이블의 데이터는 행이 삽입된 순서대로 저장된다.
    - 인덱스는 해당 행을 검색하기 위한 구조를 제공한다.

- `추가적인 저장 공간` 
    - 별도의 구조로 데이터를 저장하므로 추가적인 저장 공간이 필요하다. 
    - 인덱스는 인덱스 키와 매핑된 행 식별자로 구성되며, 이 정보는 인덱스 테이블이나 파일에 저장된다.

- `검색 및 정렬 성능`
    - 데이터 검색 속도를 향상된다. 

<br>

### 단점
- 데이터가 변경되거나 인덱스를 업데이트할 때는 추가적인 작업이 필요하므로 성능에 영향을 줄 수 있다.

# 2. Query Plan

- 데이터베이스가 쿼리를 실행하기 위해 어떤 방법을 선택하는지에 대한 정보를 제공하는 것이다.
- 쿼리 옵티마이저(Query Optimizer)에 의해 생성되며, 데이터베이스 엔진이 쿼리를 가장 효율적으로 실행하는 방법을 결정하는 데 도움이 된다.


```sql
-- 전체 table row count 확인

select 
    table_name as '테이블 명',
    table_rows as '데이터 건수'
from information_schema.tables
where table_schema = 'PARK'
    and table_name REGEXP '2|3'
;

-- index test
-- index 덕분에 1억개의 데이터가 존재하지만 빠르게 조회됨
explain
select count(*) from tbl_board2
where 1=1 and user_seq = '113'
;

-- no index test
-- 인덱스가 존재하지 않아서 굉장히 오래 걸린다.(30분 넘게 소요됨)
select count(*) from tbl_board3
where 1=1 and user_seq = '113'

```

