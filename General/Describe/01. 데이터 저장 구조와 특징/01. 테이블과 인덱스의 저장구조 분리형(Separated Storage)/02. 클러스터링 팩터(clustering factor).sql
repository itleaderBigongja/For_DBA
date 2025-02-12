/** 클러스터링 팩터(Clustering Factor)란?
 *  클러스터링 팩터(Clustering Factor)는 인덱스가 테이블의 물리적 정렬 상태를 얼마나
 *  잘 반영하고 있는지 측정하는 값이다.
 * 
 *  쉽게 말해서
 *  ㅇ 값이 작을수록(낮을수록) -> 인덱스의 순서와 실제 데이터 저장 순서가 비슷 -> 성능이 좋음
 *  ㅇ 값이 클수록(높을수록) -> 인덱스 순서와 데이터 저장 순서가 일치하지 않음 -> 성능이 나쁨
 * 
 *  클러스터링 팩터가 낮으면, 인덱스 범위 검색( BETWEEN, LIKE 'abc%')이 빠르고
 *  클러스터링 팩터가 높으면, 인덱스를 통해 데이터를 조회할 때 랜덤 I/O가 많아져서 성능이 저하된다.
 * 
 *  클러스터링 팩터의 개념 이해
 *  예제 테이블 생성
 *  CREATE TABLE USER(
 *  	ID 		INT PRIMARY KEY,
 *  	NAME 	VARCHAR(100),
 * 		AGE		INT
 *  );
 *  // 인덱스 생성
 *  CREATE INDEX IDX_AGE ON USERS(AGE);
 * 
 *  
 *  [ 좋은 클러스터링 팩터(낮음) ]
 *  rowId			age
 *  101				21
 *  102				22
 *  103				23
 *  104				24
 *  설명: ㅇ age 인덱스의 순서와 실제 데이터 저장 순서(rowId)가 동일
 *       ㅇ 인덱스 범위 검색 시 순차적인 블록 읽기(Sequential Read : 순차적 읽기)가능
 *       ㅇ 디스크 I/O 최소화 -> 빠른 검색
 * 
 *  [ 나쁜 클러스링 팩터(높음) ]
 *  rowId			age
 *  203				21
 *  101				22
 *  305				23
 *  502				24
 *  설명: ㅇ age 인덱스의 순서와 실제 데이터 저장 순서(rowId)가 다름
 *       ㅇ 범위 검색 시, 랜덤(Random Access)가 많아짐
 *       ㅇ 디스크 I/O 증가 -> 검색 성능 저하
 *  
 * [ 클러스터링 팩터 공식 ]
 *  -> 데이터베이스 마다 조금씩 다르지만, 기본적인 공식은 다음과 같다.
 *
 *          					테이블 데이터 블록의 변경 횟수
 *        Clustering Factor = ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 * 								인덱스 엔트리 개수
 *     ㅇ 클러스터링 팩터 값의 범위
 * 		  - 최소값: 테이블의 데이터 블록수 (완전한 정렬)
 * 		  - 최대값: 테이블의 레코드 수 (완전한 정렬)
 *     
 *     ㅇ 즉, 클러스터링 팩터가 테이블의 블록 개수에 가까울수록 좋고,
 *       테이블의 레코드 개수에 가까울수록 나쁨!
 * 
 * 
 * [ 클러스터링 팩터 확인 방법 ]
 *  -> 각 데이터베이스에서 클러스터링 팩터를 확인하는 방법은 다음과 같다.
 *  Oracle 예시: Oracle에서는 DBA_INDEXES 뷰를 사용하여 클러스터링 팩터를 확인할 수 있다.
 *  -> 클러스터링 팩터 확인 쿼리
 *	   SELECT INDEX_NAME, TABLE_NAME, CLUSTERING_FACTOR
 *       FROM DBA_INDEXES
 *      WHERE TABLE_NAME = 'USERS';
 *     
 *     ㅇ CLUSTERING_FACTOR 값이 작을수록 성능이 좋음
 *     ㅇ CLUSTERING_FACTOR 값이 테이블의 BLOCKS 수에 가까울수록 효율적.
 * 
 * 
 * [ 클러스터링 팩터를 개선하는 방법 ]
 * ㅇ 클러스터링 팩터가 높아지면 검색 성능이 저하될 수 있으므로, 이를 최적화하는 몇 가지 방법이 있다.
 *   1. 클러스터형 인덱스(Clustered Index) 사용
 *      - 클러스터형 인덱스는 데이터 정렬을 유지하므로, 클러스터링 팩터가 낮아짐
 *      - MySQL InnoDB에서는 PRIMARY KEY가 자동으로 클러스터형 인덱스로 동작.
 *      
 * 		예: ALTER TABLE USERS ADD PRIMARY KEY(ID);
 *      -> 기본 키(Primary Key)를 사용하여 데이터를 정렬하여 저장하면 범위 검색 성능이 향상됨
 * 
 *   2.CLUSTER 명령어 사용( PostgreSQL, Oracle )
 *      - PostgreSQL
 * 		  CLUSTER USERS USING IDX_AGE;
 * 
 * 		- Oracle
 * 		  ALTER TABLE USERS MOVE;
 * 		  ALTER INDEX IDX_AGE REBUILD;
 *      설명: 데이터 정렬을 다시 맞춰서 클러스터링 팩터를 낮춤.
 * 
 *   3. 주기적인 인덱스 재구성
 *      ㅇ 인덱스가 조각화되면 클러스터링 팩터가 높아질 수 있음.
 *      ㅇ 인덱스를 주기적으로 리빌드(Rebuild)하면 정렬 상태가 개선됨.
 * 
 *      - MySQL
 *        ALTER TABLE USERS ENGINE=InnoDB;
 * 
 *      - PostgreSQL
 *        REINDEX TABLE USERS;
 * 
 *      - Oracle
 *        ALTER INDEX IDX_AGE REBUILD;
 *      ㅇ 인덱스를 다시 정렬하여 검색 속도를 최적화할수 있음.
 * 
 *   결론:
 *   ㅇ 클러스터링 팩터(Clustering Factor)는 인덱스 순서와 실제 데이터 순서의 일치 정도를 나타내는 지표.
 *   ㅇ 값이 낮을수록 연속적인 데이터 블록 읽기(Sequential Read)가 가능하여 검색 성능이 향상 된다.
 *   ㅇ 클러스터링 팩터가 높아지면 랜덤 I/O(Random Access)가 증가하여 검색 속도가 느려질 수 있음.
 *   ㅇ 클러스터형 인덱스 활용. CLUSTER 명령어 사용, 인덱스 재구성 등의
 *      방법으로 클러스터링 팩터를 개선할 수 있음.
 *   즉, 클러스터링 팩터를 관리하면 인덱스 성능 최적화에 큰 도움이된다.
 **/