/** 클러스터링 팩터(Clustering Factor) 향상 전략
 * 1. 클러스터링 팩터란?
 *  클러스터링 팩터(Clustering Factor, CF)는 인덱스가 실제 데이터의 물리적 저장 순서와 얼마나 일치하는지를 나타내는 값이다.
 *    ㅇ CF가 낮다.(좋음) -> 인덱스의 순서와 순서와 테이블의 데이터 저장 순서가 일치 -> 범위 검색이 빠름
 *    ㅇ CF가 높다.(나쁨) -> 인덱스 순서와 테이블 데이터 저장 순서가 다름 -> 랜덤 I/O 증가 -> 성능 저하
 *     체크 포인트: 즉, 클러스터링 팩터가 낮을수록 범위 검색이 더 빠르게 수행됨!
 *   
 *	ㅁ Oracle에서 클러스터링 팩터 조회 예제
 *		SELECT INDEX_NAME, CLUSTERING_FACTOR
 *		  FROM USER_INDEXES
 *		 WHERE TABLE_NAME = 'EMPLOYESS';
 *	
 *
 * 2. 클러스터링 팩터 향상의 중요성
 *    클러스터링 팩터가 높으면 인덱스를 통한 범위 검색(Range Scan) 성능이 급격히 저하됩니다.
 *    특히 분리형 테이블(Heap Table)의 경우 데이터 정렬되지 않으므로 CT가 높아질 가능성이 큼.
 *
 *	ㅁ 클러스터링 팩터가 높은 경우 발생하는 문제
 *     ㅇ 인덱스 스캔 후 테이블 조회 시 I/O증가 -> 속도 저하
 *     ㅇ 같은 인덱스 범위를 읽어도 더 많은 블록을 접근해야 함.
 *     ㅇ Full Scan Table이 더 유리한 상황 발생 가능!
 *     체크 포인트: 따라서, 클러스터링 팩터를 낮추는 전략이 필요함!   
 *	
 * 3. CLUSTER 또는 MOVE 명령어를 사용하여 테이블 정렬 유지
 *     ㅇ Heap Table은 데이터가 삽입 순서대로 저장되므로 인덱스 순서와 맞지 않음
 *     ㅇ 특정 인덱스를 기준으로 테이블을 정렬하여 CF를 낮출 수 있음
 *   
 *		ㅁ PostgreSQL에서 CLUSTER 명령어 사용( 특정 인덱스 기준 정렬 )
 *           -> CLUSTER EMPLOYEES USING IDX_EMP_SALARY;
 * 
 *		ㅁ Oracle에서 테이블을 이동 후, 인덱스 정렬 재구성
 *			ALTER TABLE EMPLOYEES MOVE;
 *			ALTER INDEX IDX_EMP_SALARY REBUILD;
 *  	체크 포인트: 데이터를 인덱스 순서대로 정렬하여 클러스터링 팩터를 낮춤!
 * 
 * 4 클러스터형 인덱스(Clustered Index) 사용
 *     ㅇ MySQL InnoDB처럼 클러스터형 인덱스를 사용하면 데이터가 자동으로 정렬되어 저장됨
 *     ㅇ Heap Table 대신 클러스터형 인덱스를 적용하면 범위 검색 성능이 향상됨
 *		
 *		ㅁ MySQL에서 클러스터형 인덱스 적용(InnoDB 엔진)
 *          CREATE TABLE EMPLOYEES(
 * 				EMP_ID		INT		PRIMARY KEY,	-- 클러스터형 인덱스 적용됨(InnoDB 기본)
 * 				NAME		VARCHAR(100),
 * 				SALARY		INT
 *      	);
 * 		체크 포인트: 클러스터형 인덱스를 사용하면 테이블이 정렬된 상태로 저장되어 CF가 낮아짐!
 * 
 * 
 * 5. 인덱스 포함 컬럼(Index Include)활용 -> 커버링 인덱스 적용
 *		ㅇ 인덱스 스캔 후, 테이블 액세스를 줄이는 방법
 *		ㅇ 커버링 인덱스(Covering Index)를 사용하면 테이블을 조회하지 않아도 됨
 *
 * 		 ㅁ MySQL에서 커버링 인덱스 적용 예제
 * 		    CREATE INDEX IDX_EMP_COVERING ON EMPLOYEES(SALARY, NAME);
 * 
 * 		 ㅁ 사용 예시:
 * 			SELECT NAME FROM EMPLOYEES WHERE SALARY BETWEEN 50000 AND 100000;
 * 		 체크 포인트: 커버링 인덱스를 사용하면 클러스터링 팩터 영향을 최소화할 수 있음!
 * 
 * 
 * 6. 파티셔닝(Partitioning) 적용 -> 특정 범위 검색 최적화
 *      ㅇ 데이터를 특정 기준(날짜, 범위 등)으로 나누어 저장하면 불필요한 데이터 접근을 줄일 수 있음
 *      ㅇ 파티셔닝을 활용하면 범위 검색 시 전체 테이블을 읽지 않으므로 CF를 낮출 수 있음
 *      
 *       ㅁ PostgreSQL에서 SALARY 기준 RANGE 파티셔닝 적용
 * 			CREATE TABLE EMPLOYEES(
 * 				EMP_ID		INT				PRIMARY KEY,
 * 				NAME		VARCHAR(100),
 * 				SALARY		INT
 * 			) PARTITION BY RANGE(SALARY);
 * 
 *			CREATE TABLE EMPLOYEES_LOW_SALARY PARTITION OF EMPLOYEES FOR VALUES FROM (0) TO (50000);
 *			CREATE TABLE EMPLOYEES_MID_SALARY PARTITION OF EMPLOYEES FOR VALUES FROM (50000) TO (100000);
 *			CREATE TABLE EMPLOYEES_HIGH_SALARY PARTITION OF EMPLOYEES FRO VALUES FROM (100000) TO (200000);
 *		 체크 포인트: 범위 검색 시 특정 파티션만 읽으므로 클러스터링 팩터가 낮아짐!
 *
 *
 * 7. 인덱스 리빌드(Rebuild) 및 재구성
 *		ㅇ 데이터가 자주 변경(INSERT, UPDATE, DELETE)되면 인덱스 조각화(Fragmentation)발생
 *		ㅇ 인덱스를 주기적으로 재구성하면 CF를 낮추고 성능을 유지 가능
 *		 ㅁ Oracle에서 인덱스 리빌드
 *		 	ALTER INDEX IDX_EMP_SALARY REBUILD;
 *
 *		 ㅁ PostgreSQL에서 인덱스 재구성
 *			REINDEX INDEX IDX_EMP_SALARY;
 *		 체크 포인트: 인덱스를 최적화하여 클러스터링 팩터를 낮출 수 있음!
 *
 * 
 * 8. 데이터 삽입 순서 최적화 -> 정렬된 상태로 데이터 입력
 *		ㅇ 데이터를 삽입할 때 특정 정렬 기준을 유지하면 CF가 낮아짐
 *		ㅇ 초기 데이터 적재(Initial Load) 시 미리 정렬된 데이터 입력 추천
 *		 ㅁ 정렬된 상태로 데이터를 입력하는 예제
 *			// APPEND 힌트 써주면 좋음
 *			INSERT INTO EMPLOYEES
 *			SELECT * fROM TEMP_EMPLOYEES ORDER BY SALARY;
 *			체크 포인트: 초기 적재 시 데이터 정렬을 유지하면 CF를 낮출 수 있음!
 *
 *
 *	결론: 클러스터링 팩터 향상 전략 요약
 *	전략						설명										적용 가능 DB
 *	CLUSTER 명령어 사용		특정 인덱스 기준으로 테이블 정렬	 			PostgreSQL, Oracle
 *	클러스터형 인덱스 사용		인덱스 순서대로 데이터 정렬 저장				MySQL(InnoDB)
 *	커버링 인덱스 활용			인덱스만으로 필요한 데이터 조회					MySQL(InnoDB), PostgreSQL, Oracle
 *	파티셔닝 적용				범위 검색 시 전체 테이블이 아닌 특정 파티션만 조회	PostgreSQL, Oracle
 *  인덱스 리빌드				조각화 방지 및 최적화(DML 시, 인덱스 조각화 됨)	MySQL, PostgreSQL, Oracle
 *  정렬된 상태로 데이터 삽입		데이터 적재 시 미리 정렬하여 입력				MySQL, PostgresQL, Oracle
 *  체크 포인트: 이 방법들을 조합하면 클러스터링 팩터를 효과적으로 낮출 수 있다.
 * */
