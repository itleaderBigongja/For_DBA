/** 일체형 테이블(Integrated[통합적인] Table) 생성
 *  일체형 테이블 설계는 OLTP(Online Transaction Processing) 및 OLAP(Online Analytical[분석적인] Processing)
 *  환경에서 성능을 최적화하기 위해 적용된다.
 * 
 * 1. 일체형 테이블(Integrated Table) 개념과 필요성
 *  ㅇ 일체형 테이블이란?
 *		ㅁ 일체형 테이블(Integrated Table)은 자주 조인(Join)되는 데이터를 하나의 테이블로 합쳐서 관리 하는 방식이다.( 반정규화 )
 *      ㅁ 데이터 정규화를 적용하면 테이블이 많아지면서 조인 비용(Join Cost)이 증가하는데
 *		  비정규화(De-Normalization)를 적용하여 읽기 성능(OLAP)과 조회 속도(OLTP)를 높이는 전략이다.
 *
 *
 *  ㅇ 일체형 테이블이 필요한 이유
 *   1. JOIN 최소화 -> 응답 속도 개선
 * 		ㅁ 여러 테이블을 조인할 때 Nested Loop Join, Hash Join, Sort Merge Join 등의 비용이 발생함.
 *      ㅁ 이를 줄이기 위해 자주 조인되는 데이터를 하나의 테이블로 병합.
 * 
 *   2. 인덱스 활용 극대화
 *		ㅁ 테이블이 분리되면 인덱스가 여러 개 필요하지만, 일체형 테이블은 한 개의 인덱스만으로 충분.
 *
 *   3. OLAP 분석 성능 향상
 * 		ㅁ 정규화된 구조는 트랜잭션 처리(OLTP)에는 적합하지만, 대규모 조회(OLAP)에서는 오히려 성능 저하
 * 
 * 
 * 2. 일체형 테이블 설계 원칙("읽기 성능과 쓰기 성능"의 균형을 맞추는 것이 핵심
 *  ㅇ 읽기(SELECT) 성능이 중요한 경우 -> 일체형 테이블 + 파티셔닝 + 인덱스 최적화
 *  ㅇ 쓰기(INSERT, UPDATE) 성능이 중요한 경우 -> 정규화 + 파티션 테이블 + 병렬 처리
 * 
 *  1) 일체형 테이블의 주요 설계 기준
 * 	-> HOT 데이터		: 자주 읽히고 수정되는 중요한 데이터(실시간 트랜잭션 데이터, 최근 주문 정보)		 = 저장공간(SSD,메모리(In-Memory DB)
 *  -> HOT/HOT데이터	: 극단적으로 자주 쓰이는 초핵심 데이터(실시간 주식 거래, 금용 계좌 잔액, 게임 랭킹) = 저장공간(DRAM, 캐시, Redis)
 *  -> 차가운 데이터	: 거의 사용되지 않는 데이터(3년 이상 된 로그, 오래된 백업 데이터) 				 = 저장공간(HDD, 클라우드(S3, Azure Blob Storage)
 *  ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *  설계 요소				| 설명
 *  ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *  정규화 vs 비정규화      | JOIN이 많으면 비정규화, 데이터 무결성이 중요하면 정규화 적용
 *  PK, FK 전략			| PK는 단순하게, FK를 최소화하여 조인 비용 감소
 *  인덱스				| Clustered Index(IOT)와 Bitmap Index(OLAP)를 적절히 활용
 *  파티셔닝				| 날짜, 지역, 고객 ID 기준으로 Range, List, Partitioning 적용
 *  스토리지 최적화			| HOT/HOT 데이터를 SSD에 배치, 차가운 데이터는 Archival(기록) Storage 활용
 *  압축 기술				| Advanced Row Compression, SecureFile LOB 사용하여 저장 공간 최적화
 *  ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 * 
 *
 * 3. 일체형 테이블 설계 실습
 *  예제: "주문(Order)"및 "고객(Customer)" 데이터를 하나의 테이블로 합치는 과정
 *
 *  1). 기존 정규화된 테이블 구조
 *  -> CREATE TABLE customers(
 * 	 		customer_id			NUMBER			PRIMARY KEY,
 * 	 		name				VARCHAR2(100),
 * 	 		email				VARCHAR2(100),
 * 			phone				VARCHAR2(20)
 *     );
 * 
 *     CREATE TABLE orders(
 * 			order_id			NUMBER			PRIMARY KEY,
 * 			customer_id			NUMBER,
 * 			order_date			DATE,
 * 			amount				NUMBER,
 * 			status				VARCHAR2(20),
 * 		
 * 			CONSTRAINT FK_ORDERS_CUSTOMER FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
 *     );
 * 
 * 	   기존 정규화된 테이블 구조의 문제점:
 * 		 ㅇ orders 테이블과 customers 테이블을 조인해야 고객 정보를 조회할 수 있음
 *       ㅇ 대량의 조인이 발생하면 성능 저하( 특히 OLAP 쿼리에서 불리함 )
 * 
 * 
 *  2). 일체형 테이블(Integrated Table)로 변경
 *  -> CREATE TABLE integrated_orders(
 * 			order_id			NUMBER			PRIMARY KEY,
 * 			customer_id			NUMBER,
 * 			customer_name		VARCHAR2(100),
 * 			email				VARCHAR2(100),
 * 			phone				VARCHAR2(20),
 * 			order_date			DATE,
 * 			amount				NUMBER,
 * 			status				VARCHAR2(20)
 *     );
 * 
 *	  일체형 테이블로 변경점:
 *      ㅇ customers 테이블과 orders 테이블을 하나로 합쳐서 조인 없이 조회 가능
 *      ㅇ customer_id, customer_name, email, phone을 포함하여 조회 성능 향상
 * 		ㅇ order_date 기준으로 Range Partitioning 적용 가능
 * 
 * 
 * 4. 성능 최적화를 위한 추가 설계
 *  1). 인덱스 최적화
 * 		ㅇ 주문일(order_date) 기준 인덱스 추가
 * 		-> CREATE INDEX IDX_ORDER_DATE ON integrated_orders (order_date);
 *			ㅁ 효과: 특정 기간의 주문 데이터를 빠르게 조회할 수 있음.
 *				   OLAP 쿼리 최적화에 도움을 줌
 *
 *  	ㅇ 상태(status) 기반 Bitmap Index 추가(OLAP 분석용)
 * 		-> CREATE BITMAP INDEX IDX_STATUS ON integrated_orders (status);
 * 			ㅁ 효과: status 값이 중복될 가능성이 높기 때문에 Bitmap Index가 효율적.
 * 			       WHERE status = 'Completed' 같은 필터링 속도 향상.
 * 
 *  
 * 2). 파티셔닝 적용
 * 		ㅇ "order_date"를 기준으로 RANGE 파티셔닝
 * 		-> CREATE TABLE integrated orders(
 * 				order_id			NUMBER			PRIMARY KEY,
 * 				customer_id			NUMBER,
 * 				customer_name		VARCHAR2(100),
 * 				email				VARCHAR2(100),
 * 				phone				VARCHAR2(20),
 * 				order_date			DATE,
 * 				amount				NUMBER,
 * 				status				VARCHAR2(20)	
 * 	   	   )
 * 		   PARTITION BY RANGE( order_date ) (
 * 				PARTITION p_2023 VALUES LESS THEN (TO_DATE('2024-01-01', 'YYYY-MM-DD')),
 * 				PARTITION p_2024 VALUES LESS THEN (TO_DATE('2025-01-01', 'YYYY-MM-DD')),
 * 				PARTITION p_future VALUES LESS THEN(MAXVALUE)
 * 		   );
 * 			ㅁ 효과: 최신 데이터와 과거 데이터를 분리하여 조회 성능 향상
 * 				   특정 연도의 데이터를 빠르게 삭제(ALTER TABLE DROP PARTITION)
 * 
 * 
 *  3). 압축 적용(Advanced Compression)
 *  	-> ALTER TABLE integrated_orders
 *         COMPRESS FOR OLTP;
 *  	
 * 		효과: 스토리지 사용량 절감( 최대 50% )
 * 			 읽기 성능 향상( 디스크 I/O )
 * 
 * 5. 일체형 테이블 설계의 장단점
 *		ㅇ 장점: 
 *			ㅁ 조회 속도 향상 			-> 조인 비용 제거
 *			ㅁ 인덱스 효율성 증가 		-> 단일 인덱스로 커버 가능
 *			ㅁ 파티셔닝 가능 			-> 대량 데이터 관리 용이
 *			ㅁ 압축 가능				-> 저장 공간 절약
 *
 *		ㅇ 단점:
 *			ㅁ 데이터 중복 증가			-> 고객 정보가 반복 저장됨
 *			ㅁ 쓰기 성능 저하 가능 		-> 고객 정보가 변경되면 전체 레코드 수정 필요
 *			ㅁ 트랜잭션 무결성 관리 필요	-> 고객 정보가 여러 곳에서 변경될 가능성
 *
 *
 * 6. 결론:
 *  	ㅇ OLAP 환경( BI분석, 로그 데이터 분석 )
 * 		ㅇ JOIN 비용이 높은 경우( 정규화된 데이터가 조인 부담을 주는 경우 )
 * 		ㅇ 자주 조회되는 대량 데이터( 캐싱 없이 빠르게 접근해야 하는 경우 )
 *		체크 포인트: 트랜잭션(OLTP)이 많다면 정규화, OLAP이라면 일체형 테이블이 유리
 **/