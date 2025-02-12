/** 분리형 테이블의 넓은 범위 액세스 처리 대처방안
 *  분리형 테이블(Heap Orgnized Table)은 데이터가 삽입 순서대로 저장되며,
 *  특정한 정렬 기준 없이 블록에 배치되기 때문에 범위 검색(range scan)시, 성능 저하가 발생할 수 있습니다.
 *  체크 포인트: 특히, 넓은 범위의 데이터를 조회할 때 랜덤 I/O가 증가하여 성능 저하가 발생할 수 있음.
 * 
 *  ㅇ 넓은 범위 액세스 시 성능 저하 원인
 *     1. 데이터가 연속적으로 저장되지 않음 -> 많은 블록을 랜덤하게 읽어야 함( 랜덤 I/O 증가 )
 *     2. 분리형 테이블은 클러스터형 인덱스가 없어 -> 범위 검색이 비효울적
 *     3. 다량의 데이터가 필요한 경우, Full Scan Table 발생 가능성 높음
 *     체크 포인트: 따라서, 적절한 인덱스 구성 및 데이터 저장 방식 최적화가 필요합니다!
 * 
 * 
 * [ 넓은 범위 액세스 성능 최적화 방법 ]
 * 1. 클러스터형 인덱스(Clusterd Index) 사용
 *		ㅇ MySQL InnoDB처럼 클러스터형 인덱스를 사용하면,
 *		  테이블이 Primary Key 순서대로 정렬되어 저장되므로,
 *		  범위 검색 시 연속적인 블록 읽기(Sequetial Read)가 가능하여 속도가 빠릅니다.
 *	    ㅇ 분리형 테이블(Heap Table)에서는 지원되지 않음
 * 
 *		 ㅁ MySQL에서 클러스터형 인덱스 설정 예제
 *		    CREATE TABLE USERS (
 *				ID		INT		PRIMARY KEY,	-- 클러스터형 인덱스 자동 적용( MySQL InnoDB )
 *				NAME	VARCHAR(100),
 *				AGE		INT
 *			);
 *			체크 포인트: 클러스터형 인덱스를 사용하면 범위 검색이 더 효율적!
 * 
 * 
 * 2. CLUSTER 명령어를 사용하여 데이터 정렬 유지
 *		ㅇ PostgreSQL 및 Oracle에서는 특정 인덱스 기준으로 테이블을 재정렬할 수 있음.
 *		ㅇ 범위 검색이 많은 경우, 주기적으로 CLUSTER 실행 추천
 *   
 *   	 ㅁ PostergreSQL에서 CLUSTER 적용
 *		    -> CLUSTER USERS USING IDX_AGE;  
 * 
 *		 ㅁ Oracle에서 테이블 정렬 후, 인덱스 재구성
 *          -> ALTER TABLE USERS MOVE;
 *          -> ALTER INDEX IDX_AGE REBUILD;
 *		 체크 포인트: 주기적으로 테이블을 정렬하여 범위 검색 성능을 향상!
 * 
 * 
 * 3. 파티셔닝(Partitioning) 사용
 *    ㅇ 넓은 범위 데이터를 조회할 때 모든 데이터 블록을 읽는 대신, 필요한 데이터만 읽도록 개선
 *    ㅇ 파티션 키(Partition Key)를 잘 선정하면 특정 범위 조회 시 불필요한 데이터 접근을 최소화
 * 
 *		ㅁ 예제: PostgreSQL에서 기존 파티셔닝 적용
 *			CREATE TABLE USERS(
 *				ID		INT		PRIMARY KEY,
 *				NAME	VARCHAR(100),
 *				AGE		INT
 *			) PARTITION BY RANGE(AGE);
 * 
 *			-> CREATE TABLE USERS_YOUNG PARTITION OF USERS FOR VALUES FROM (0) TO (30);
 *			-> CREATE TABLE USERS_ADULT PARTITION OF USERS FOR VALUES FROM (30) TO (60);
 *			-> CREATE TABLE USERS_SENIOR PARTITION OF USERS FOR VALUES FROM (60) TO (100);
 * 
 *   	ㅁ 예제: Oracle에서 CREATE_AT 기준 파티션 적용
 *			CREATE TABLE USERS(
 *				ID			INT		PRIMARY KEY,
 *				NAME		VARCHAR(100),
 *				CREATE_AT	DATE
 *			) PARTITION BY RANGE(CREATE_AT) (
 *			  PARTITION P1 VALUES LESS THAN (DATE '2023-01-01'),
 * 			  PARTITION P2 VALUES LESS THAN (DATE	'2024-01-01'),
 * 			  PARTITION P3 VALUES LESS THAN (DATA '2025-01-01')
 *			);
 * 
 *  
 *  4. 커버링 인덱스(Covering Index) 활용
 * 	   ㅇ 인덱스만으로 원하는 데이터를 조회할 수 있도록 구성하면 실제 테이블 액세스를 최소화
 *     ㅇ SELECT 절에 필요한 컬럼들을 포함한 인덱스 생성 추천
 * 
 *		ㅁ 예제: MySQL에서 필요한 컬럼들을 포함한 인덱스 생성 추천
 *			CREATE INDEX IDX_USERS_COVERING ON USERS(AGE, NAME);
 * 
 *			사용 예시
 *			SELECT NANE FROM USERS WHERE AGE BETWEEN 20 AND 30;
 *			 -> 인덱스에 필요한 데이터가 모두 포함되어 있어 테이블 액세스 줄여 성능 향상!
 * 
 * 
 * 5. 인덱스 재구성(Rebuild)
 *		ㅇ 데이터 변경(INSERT, UPDATE, DELETE)이 많으면 인덱스 조각화 발생 -> 성능 저하
 *		ㅇ 주기적으로 인덱스를 재구성하면 범위 검색 속도 개선 가능
 *
 *		ㅁ 예제: Oracle에서 인덱스 재구성
 *			ALTER INDEX IDX_AGE REBUILD;
 *		ㅁ 예제: PostgreSQL에서 인덱스 재구성
 *			REINDEX INDEX IDX_AGE;
 *
 *
 *  6. 병렬 쿼리(Parallel Query) 활용
 *		ㅇ 넓은 범위 데이터를 조회할 때, 쿼리를 병렬로 실행하여 속도 개선 가능
 *
 *		ㅁ PostgreSQL에서 병렬 쿼리 활성화
 *			SET PARALEL_TUPLE_COST = 0;
 *			SET PARALEL_SETUP_COST = 0;
 * 
 *		ㅁ ALTER SESSION ENABLE PARALLEL QUERY;
 *			CPU 리소스를 활용하여 대량 데이터 조회 속도 향상 가능!
 * 
 * 
 *  결론: 넓은 범위 검색 최적화 핵심 요약
 *  방법						설명									적용 가능 DB
 *  클러스터형 인덱스 사용		인덱스와 데이터 정렬 유지					MySQL(InnoDB)
 *  CLUSTER 명령어 사용		특정 인덱스 기준으로 데이터 정렬			PostgreSQL, Oracle
 *  파티셔닝(Partitioning)		특정 범위 검색 시 불필요한 데이터 접근 최소화	PostgreSQL, Oracle
 *  커버링 인덱스 활용			인덱스만으로 쿼리 처리 가능하게 구성			MySQL, PostgreSQL, Oracle
 *  인덱스 재구성(Rebuild)		인덱스 조각화 방지						MySQL, PostgreSQL, Oracle
 *  병렬 쿼리(Parallel Query)	대량 데이터 조회 시 병렬 처리				PostgreSQL, Oracle
 *   ㅇ 이 방법들은 적절히 조합하면 넓은 범위 검색시 성능을 극대화할 수 있다.
 **/