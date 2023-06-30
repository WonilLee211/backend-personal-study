
# TAC, tibero active cluster

![Untitled](./img/Untitled%2010.png)

## TAC 구성
- CWS(Cluster Wait-lock Service)
    - 기존 Wait-lock(이하 Wlock)이 클러스터 내에서 동작할 수 있도록 구현된 모듈이다. Distributed Lock Manager(이하 DLM)이 내장되어 있다.
    - Wlock은 GWA를 통해 CWS에 접근할 수 있으며 이와 관련된 배경 스레드로는 WATH, WLGC, WRCF 이 존재한다.
- GWA(Global Wait-lock Adapter)
    - Wlock은 CWS를 사용하기 위한 인터페이스 역할을 수행하는 모듈이다.
    - CWS에 접근하기 위한 핸들인 CWS Lock Status Block(이하 LKSB)과 파라미터를 설정하고 관리한다.
    - Wlock에서 사용하는 잠금 모드(Lock mode)와 타임아웃(timeout)을 CWS에 맞게 변환하며 CWS에서 사용할 Complete Asynchronous Trap(이하 CAST), Blocking Asynchronous Trap(이하 BAST)을 등록할 수 있다.
- CCC(Cluster Cache Control)
    - 데이터베이스의 데이터 블록에 대한 클러스터 내 접근을 통제하는 모듈이다. DLM이 내장되어 있다.
    - CR Block Server, Current Block Server, Global Dirty Image, Global Write 서비스가 포함되어 있다.
    - Cache layer에서는 GCA(Global Cache Adapter)를 통해 CCC에 접근할 수 있으며 이와 관련된 배경 스레드로 CATH, CLGC, CRCF 이 존재한다.
- GCA(Global Cache Adapter)
    - Cache layer에서 CCC 서비스를 사용하기 위한 인터페이스 역할을 수행하는 모듈이다.
    - CCC에 접근하기 위한 핸들인 CCC LKSB와 파라미터를 설정하고 관리하며 Cache layer에서 사용하는 block lock mode를 CCC에 맞게 변환한다.
    - CCC의 lock-down event에 맞춰 데이터 블록이나 Redo 로그를 디스크에 저장하는 기능과 DBWR가 Global wirte를 요청하거나 CCC에서 DBWR에게 block write를 요구하는 인터페이스를 제공한다.
    - CCC에서는 GCA를 통해 CR block, Global dirty block, current block을 주고받는다.
- MTC(Message Transmission Control)
    - 노드 간의 통신 메시지의 손실과 out-of-order 문제를 해결하는 모듈이다.
    - 문제를 해결하기 위해 retransmission queue와 out-of-order message queue를 관리한다.
    - General Message Control(GMC)을 제공하여 CWS/CCC 이외의 모듈에서 노드 간의 통신이 안전하게 이루어지도록 보장한다. 현재 Inter-instance call(IIC), Distributed Deadlock Detection(이하 DDD), Automatic Workload Management에서 노드 간의 통신을 위해 GMC를 사용하고 있다.
- INC(Inter-Node Communication)
    - 노드 간의 네트워크 연결을 담당하는 모듈이다.
    - INC를 사용하는 사용자에게 네트워크 토폴로지(network topology)와 프로토콜을 투명하게 제공하며 TCP, UDP 등의 프로토콜을 관리한다.
- NMS(Node Membership Service)
    - TBCM으로부터 전달받은 정보(node id, ip address, port, incarnation number)와 node workload를 나타내는 가중치(weight)를 관리하는 모듈이다.
    - node 멤버십의 조회, 추가, 삭제 기능을 제공하며 이와 관련된 배경 스레드로 NMGR이 있다.

## 특징
- 확장성, 고가용성을 목적으로 제공하는 Tibero의 주요 기능
- 실행 중인 모든 인스턴스는 공유된 데이터베이스를 통해 트랜잭션을 수행
- 공유된 데이터에 대한 접근은 데이터의 일관성과 정합성 유지를 위해 상호 통제하에 이뤄짐
- 큰 업무를 작은 업무의 단위로 나누어 여러 노드 사이에 분산하여 수행할 수 있기 때문에 업무 처리 시간을 단축할 수 있다.
- 여러 시스템이 공유 디스크를 기반으로 데이터 파일을 공유
- TAC 구성에 필요한 데이터 블록은 노드 간을 연결하는 고속 사설망을 통해 주고 받음으로써 노드가 하나의 공유 캐시(shared cache)를 사용하는 것처럼 동작