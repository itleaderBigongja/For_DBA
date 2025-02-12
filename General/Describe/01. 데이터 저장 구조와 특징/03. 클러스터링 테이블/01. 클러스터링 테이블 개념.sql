/** 클러스터링 테이블 개념
 *  대규모 운영 환경에서 데이터의 저장 방식은 성능 최적화의 핵심 이다.
 *  클러스터링 테이블(Clustered Table)은 물리적 저장 방식을 최적화하여 데이터 접근 속도를 극대화하는 기술 중 하나이다.
 * 
 *  1. 클러스터링 테이블이란?
 *  클러스터링 테이블(Clustered Table)이란 데이터를 특정 컬럼 값을 기준으로 물리적으로 함께 저장하는 방식을 의미
 *   ㅇ 일반적인 Heap Table은 데이터를 INSERT 순서대로 저장하며, 인덱스가 별도로 존재하여 추가적인 I/O가 필요하다.
 *	 ㅇ 반면 클러스터링 테이블은 같은 키 값을 가진 행들을 물리적으로 가까이 저장하여 I/O를 최적화하고 성능을 향상시킨다.
 *
 *  체크 포인트: 클러스터링 테이블은 데이터 접근 패턴을 고려한 테이블 구조이다.
 * 
 * 
 *  2. 클러스터링 테이블의 장단점
 * ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *  구분 | 설명
 * ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *  장점 | 동일한 키 값을 가지는 데이터에 대한 검색 및 조인이 빠름(예: 외래키 기반 JOIN이 많은 경우) 
 *		| 디스크 I/O 감소 - 관련 데이터가 같은 블록에 저장되므로 캐시 히트율이 높아짐
 *      | 범위 검색(RANGE SCAN)에 최적화됨 (예: 날짜별 데이터 분석)
 * ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *  단점 | INSERT/UPDATE/DELETE가 비효율적 - 새로운 데이터가 삽입될 때 재정렬(리오가제이션)이 필요할 수 있음
 *      | 랜덤 액세스 시 성능 저하 - 클러스터 키 외의 검색에는 성능 이점이 없음
 * ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 * 
 * 
 * 3. 클러스터링 테이블 vs 일반 테이블(Heap Table) 비교
 * ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *  구분 |				| Heap Table						| Clustered Table
 * ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *  데이터 저장 방식		| INSERT 순서로 저장됨					| 클러스터 키 값에 따라 물리적으로 정렬됨
 *  데이터 조회			| 인덱스를 통해 검색 -> 추가적인 I/O 발생   | 같은 키 값을 가지는 데이터는 물리적으로 가까움 -> 빠른 검색
 *  조인 성능				| 인덱스 기반 검색이 필요하여 I/O 발생을 깨움	| 조인 성능 최적화됨(Foreign Key 관계 최적화)
 *  INSERT / UPDATE 비용	| 빠름(무작위 삽입 가능)					| 느림( 클러스터 키에 따라 데이터가 정렬되어야 함 )
 * ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *  ㅁ 운영 환경에서 자주 발생하는 JOIN 및 범위 검색이 많다면 클러스터링 테이블이 효과적이다.
 * 
 * 
 * 4. 클러스터링 테이블을 적용해야 하는 시나리오
 *  체크 포인트: 다음과 같은 패턴이 있다면 클러스터링 테이블이 효과적
 *   ㅇ 외래 키 기반의 조인이 많음
 *     -> 예: 고객 주문 데이터(customer - order )구조에서 고객별 주문 내역을 빠르게 검색해야 하는 경우
 *     ->     클러스터링 팩터와 같이 검색범위의 빈도를 낮춰 조회 성능을 최적화
 * 
 *   ㅇ 범위 검색이 많음
 *     -> 예: 로그 데이터, 시계열 데이터(time-series data)에서 날짜별 조회가 빈번한 경우
 *   ㅇ 읽기 성능이 중요한 환경
 *     -> OLAP 시스템( Online Analytical Processing), BI(Business Intelligence) 시스템
 * 
 * 
 * 5. 클러스터링 테이블 생성 방법( Oracle, PostgreSQL 기준 )
 *   1. Oracle 클러스터링 테이블 생성
 *   Oracle에서는 Index-Organized Table(IOT)을 사용하여 클러스터링 테이블을 구현할 수 있다.
 *   
 *    ㅇ 클러스터링 테이블을 위한 CLUSTER 생성 (Cluster Key : customer_id) 
 *    	CREATE CLUSTER customer_orders_cluster( customer_id NUMBER(10) )
 *    		SIZE 1024;
 * 
 *    ㅇ 클러스터 테이블 생성( 고객 테이블 : Cluster Key : customer_id )
 *    	CREATE TABLE customers (
 *			customer_id				NUMBER(10)			PRIMARY KEY,
 *			name					VARCHAR2(100),
 * 	  	) CLUSTER customer_orders_cluster( customer_id );
 * 
 * 	  ㅇ 클러스터 테이블 생성( 주문 테이블 : Cluster Key : customer_id )
 * 	  	CREATE TABLE orders (
 * 			order_id				NUMBER(10)			PRIMARY KEY,
 * 			customer_id				NUMBER(10),
 * 			order_date				DATE,
 * 			amount					NUMBER(10, 2)
 * 	  	) CLUSTER customer_orders_cluster( customer_id );
 * 	  	체크포인트 : customer_id를 기준으로 물리적으로 인접하게 저장
 * 				  고객 ID 기반 조회 시 디스크 I/O가 최소화됨
 * 
 *    ㅇ 클러스터 조회 쿼리
 *    	SELECT * FROM DBA_CLUSTERS WHERE CLUSTER_NAME = 'customer_orders_cluster';
 * 
 *  2. PostgreSQL CLUSTERING
 * 	  ㅇ PostgreSQL에서는 CLUSTER 명령어를 사용하여 기존 테이블을 클러스터링할 수 있다.
 * 	    -- 인덱스 기반 클러스터링 테이블 적용
 *      CREATE INDEX IDX_ORDERS_CUSTOMER ON ORDERS ( customer_id );
 *      
 *      -- 클러스터 명령어를 통해 클러스터링 작업 실행
 * 	    CLUSTER ORDERS USING IDX_ORDERS_CUSTOMER;
 * 		
 * 		 ㅁ 위 방식의 특징
 *			1. 기존 테이블을 인덱스 순서대로 물리적으로 정렬
 *			2. 데이터 재정렬 후 SELECT 성능 향상
 *			3. 다만, 새로운 데이터가 추가되면 클러스터링 상태가 깨질수 있음
 * 
 * 
 * 6. 운영 환경에서 클러스터링 테이블 유지 전략
 *  1. 정기적인 REBUILD 수행( Oracle: ALTER TABLE customers MOVE [옵션], PostgreSQL: CLUSTER 명령어 )
 *  2. 클러스터링 테이블을 사용한 테이블에 INSERT가 빈번하면 IOT 대신 PARTITION 테이블 변경 고려
 *  3. 클러스터링 테이블을 사용할 경우, 추가적인 튜닝을 위해 PCTREE(빈 공간 유지 80% 비율) 설정 고려
 * 
 * 
 * 7. 결론:
 *  1. 클러스터링 테이블(Clustered Table)은 데이터 접근 속도를 극대화할 수 있는 강력한 설계 기법
 *  2. 조인이 많고, 특정 컬럼 값(예: 고객 ID, 날짜) 기준으로 범위 검색이 많다면 효과적
 *  3. 다만 UPDATE / INSERT 성능 저하 문제가 발생할 수 있으므로 튜닝이 필요
 *  4. PostgreSQL, Oracle, MySQL 등 주요 DBMS에서 지원하지만, 운영 환경에서 주기적인 유지보수 필수
 * 체크포인트: 클러스터링 테이블은 잘만 활용하면 OLTP(Online Transaction Processing) 및
 *           OLAP 환경에서 강력한 성능 향상을 가져올 수 있는 핵심 기술이다. 
 */ 