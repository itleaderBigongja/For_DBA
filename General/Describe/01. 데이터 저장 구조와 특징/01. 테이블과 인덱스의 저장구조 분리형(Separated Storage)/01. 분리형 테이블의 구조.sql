/** 테이블과 인덱스의 저장구조 - 분리형(Separated Storage)
 *  개념 : 테이블과 인덱스의 분리형(Separated Storage)이란 
 *        데이터 테이블과 인덱스를 서로 다른 물리적 공간(파일 또는 저장 블록)에 저장하는 방식을 의미
 *        이를 통해 데이터 저장과 검색 성능을 최적화할수 있다.
 * 
 * 
 *  테이블과 인덱스 분리형의 구조
 *  일반적으로 데이터베이스에서 테이블과 인덱스를 저장하는 방식은 크게 분리형과 일체형으로 나뉜다.
 *  
 *  <분리형 (Separated Storage)>
 *   ㅇ 테이블의 데이터와 인덱스가 물리적으로 별도의 공간에 저장됨.
 *   ㅇ 데이터 파일(Table File)과 인덱스 파일(Index File)이 분리됨.
 *   ㅇ 대부분의 관계형 데이터베이스(RDBMS)에서 기본적으로 사용되는 방식이다.
 *      예: MySQL(InnoDB), PostgreSQL, Oracle 등
 * 
 *  <일체형 (Integrated Storage)>
 *   ㅇ 테이블의 데이터와 인덱스를 동일한 공간에 함께 저장.
 *   ㅇ 클러스터링 인덱스를 사용하여 데이티와 인덱스를 한 곳에 저장하는 방식
 *   ㅇ 예: MySQL(MyISAM), 일부 NoSQL DB 등
 **/ 
 
/** 테이블과 인덱스 분리형의 특징
 *  1. 물리적인 저장 구조
 *  ㅇ 데이터 저장 영역: 테이블의 레코드(행)를 저장하는 공간.
 *  ㅇ 인덱스 저장 영역: 인덱스(B-Tree, Hash 등)를 저장하는 공간.
 *  ㅇ 데이터가 순차적(Heap)으로 저장되는 경우가 많음.
 * 
 *  2. 성능 최적화
 *  ㅇ 읽기 성능 향상: 인덱스를 이용한 검색 시 데이터와 인덱스가 별도의 저장 공간에 접근해야 하므로,
 *                 쓰기(INSERT, UPDATE, DELETE)속도가 상대적으로 느릴 수 있음.
 * 
 *    읽기(SELECT, JOIN 등) 
 *    예시: SELECT COULUMN_1, COULUM_2
 *           FROM TEST_TABLE
 *          WHERE COLUMN_1 = 'TEST_DATA';
 *
 *   쓰기(INSERT, UPDATE, DELETE) HINT:APPEND(UNDOSPACE가 발생하지 않도록 추가가 좋음) 
 *    예시: INSERT INTO TEST_TABLE
 *         ( COLUMN_1, COLUMN_2 )
 *         SELECT COLUMN_1, COLUMN_2
 *           FROM TEST_TABLE
 *          WHERE COLUMN_1||'' = 'TEST_DATA'; 
 * 
 *    ( 높은 선택률 (High Selectivity): 특정 값을 가진 데이터의 비율이 
 *      테이블 전체 데이터의 일정 비율 ( 예: 10% )을 넘어서는 경우, 인덱스를 사용하는 것보다 
 *      전체 테이블 스캔(Full Table Scan)이 더 빠를 수 있습니다.
 *      이유: 사용자(프로그램)가 DB에 조회 요청을 할 때,
 *           -> 사용자 데이터 요청 -> DB -> OS -> HDD 순서로 요청 순서가 되고
 * 				사용자 <- 데이터 응답 <- DB <- OS <- HDD 순서로 응답 순서가 된다.
 * 				프로그램에서 데이터 조회를 요청하면 DB에서 OS에게 이러한 데이터가 필요하다고 요청을 한다.
 * 				OS에서 리눅스의 경우 커널을 통해 HDD에 접근을하여 데이터를 가져오고,
 * 				가져온 데이터를 커널은 메모리(Oracle의 경우 SGA영역)영역에 올려둔다.(1개의 블록 사이즈 8KB)
 * 				그런 다음에 DB에서 메모리에 올라온 데이터를 가져와 프로그램에게 전달해준다.
 * 				( 장점 : 조회의 성능 속도를 증가 시킬 수 있다.
 * 				  단점 : 메모리에 Full Scan 데이터를 다 올려두기 때문에 메모리에 자원이 부족하다면
 * 					 	다른 사용중인 데이터를 내리고 Full Scan 데이터를 올리기 때문에 다른 작업을 망칠수도 있다. )
 *  
 *    ( 테이블 크기: 테이블의 크기가 매우 작은 경우, 
 *                인덱스를 사용하는 것보다 전체 테이블 스캔이 더 빠를 수 있습니다.)
 *
 *  ㅇ 랜덤 액세스 최적화: 데이터와 인덱스를 따로 저장하여 디스크 I/O를 최적화할 수 있음
 * 
 *  3. 인덱스 크기 관리
 *  ㅇ 테이블 데이터 크기 증가 -> 인덱스 크기 증가 영향 없음
 *    -> 인덱스가 별도 파일에 저장되므로, 데이터가 증가해도 테이블 크기에 직접적인 영향을 받지 않음.
 *    -> 효율적인 인덱스 관리 기능.
 *       - 필요한 경우 인덱스만 따로 리빌드(Rebuild)하거나 삭제 후, 재 생성 가능
 *  
 *  대표적인 분리형 저장구조 예시( Oracle )
 *  ㅇ 데이터는 TABLESPACE에 저장되며, 인덱스는 별도의 인덱스 테이블스페이스에 저장 가능.
 *  ㅇ 대규모 데이터베이스에서 테이블스페이스를 분리하여 성능을 최적화할 수 있음.
 *  CREATE TABLE EMPLOYEES (
		EMP_ID 		NUMBER PRIMARY KEY,
		EMP_NAME 	VARCHAR2(100),
		DEPARTMENT 	VARCHAR2(50)
	) TABLESPACE USERS;


	CREATE INDEX IDX_DEPARTMENT ON EMPLOYEES(DEPARTMENT)
	TABLESPACE INDEX_SPACE;

        
    [ 저장 구조 ]
    ㅇ 테이블 EMPLOYEES는 USER 테이블스페이스에 저장됨
    ㅇ 인덱스 IDX_DEPARTMENT는 INDEX_SPACE 테이블스페이스에 저장됨(분리형 구조)
    
    
    [ 분리형 저장 방식의 장점과 단점
    ㅇ 검색 성능 향상
       장점: 인덱스를 사용하여 빠르게 데이터를 조회 가능
       단점: 삽입/수정 시 인덱스 유지 비용 발생
       
    ㅇ 디스크 I/O 최적화
       장점: 데이터와 인덱스가 분리되어 효율적인 캐싱 가능
       단점: 디스크 공간을 추가로 사용해야 함
       
    ㅇ 인덱스 관리 용이
      장점: 인덱스만 재구성 가능(REINDEX, ANALYZE)
      단점: 너무 많은 인덱스가 존재하면 성능 저하 가능
      
    ㅇ 대량 데이터 처리에 유리
      장점: 테이블과 인덱스 각기 다른 디스크에 저장 가능
      단점: 데이터가 조각화(Fragmentation)될 위험
 */