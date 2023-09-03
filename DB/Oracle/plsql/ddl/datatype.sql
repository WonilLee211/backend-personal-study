/*
테이블의 컬럽 데이터 타입 설정 중 주의 사항

1. 숫자 데이터 타입
{
    NUMBER[(p, [s])]
    - p는 소수점 기준 모든 유효숫자 자리수를 의미한다. 만약 p보다 큰 숫자값을 입력하면 오류가 발생한다.
    - s가 양수면 소수점 기준 오른쪽, 음수이면 소수점 기준 왼쪽 유효숫자 자리수를 나타낸다.
    - s에 명시한 숫자 이상의 숫자를 입력하면 반올 처리한다.
    - s가 음수이면 소수점 기준 왼쪽 자릿수만큼 반올림한다.
    - s가 p보다 크면 p는 소수점 기준 왼쪽 유효숫자 자릿수를 의미한다.
    
    summary
    - 오라클에서는 NUMBER형만 사용해도 되며, 그 크기 설정에 있어 p와 s를 적절히 조정하면 된다.
}

 2. NUMBER VS FLOAT
{
    - NUMBER의 인자는 십진수 기준으로 표현한다.
    - FLOAT의 인자는 이진수 기준으로 표현한다.
        - FLOAT[(p)]
        
    tip
    - 2진수의 자리수를 10진수 자리수로 변환하기 위해서 간단히, 0.30103을 곱하면 된다.
    - 즉, FLOAT의 p의 default값인 128은 2^128을 의미하며, 이를 10진수 자리수로 표현하면,
        128 * 0.30103 = 38.53184로 NUMBER의 p의 default값인 38과 근사함을 볼 수 있다.
}
*/
------------------------------------------------------------------------

/*
인덱스와 성능에 관한 고찰

개발자 관점에서 성능 문제 해결 5원칙
1. 어떤 컬럼을 인덱스로 만들지, 인덱스는 몇 개나 만들 것인지 결정
    - 최대 5개가 넘어가지 않도록 한다.
2. 효율적인 SQL문을 제대로 작성한다.
3. 효율적인 SQL문을 제대로 작성한다.
4. 효율적인 SQL문을 제대로 작성한다.
5. 효율적인 SQL문을 제대로 작성한다.

*/
------------------------------------------------------------------------
------------------------------------------------------------------------

