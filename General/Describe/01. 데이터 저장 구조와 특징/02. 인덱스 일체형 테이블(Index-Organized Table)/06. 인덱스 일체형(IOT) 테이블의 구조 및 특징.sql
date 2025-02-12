/** 인덱스 일체형 테이블의 구조 및 특징
 *  인덱스 일체형 테이블(Index-Organized Table, IOT)은 일반적인 Heap Table과 다르게 
 *  데이터 자체가 인덱스 안에 포함된 형태로 저장된다.( PK로 인덱스를 생성했을 경우 )
 *  
 *  즉, 인덱스가 곧 테이블 역할을 하므로 별도의 테이블을 조회할 필요 없이 
 *  인덱스에서 바로 데이터를 읽을 수 있는 구조이다.
 * 
 * 
 * 	1. 인덱스 일체형 테이블의 구조
 *	 ㅇ 기본 개념
 *		ㅁ 일반적인 테이블(Heap Table)은 데이터가 정렬되지 않은 형태로 저장되고, 인덱스는 별도로 관리된다.(OF_SVC_TELCOCB_CONT_HST) == PK 인덱스
 *		ㅁ 하지만 IOT(일체형 테이블)는 데이터가 인덱스의 정렬 순서에 맞춰 저장됨 (IN_SVC_TELCOCB_FILE_HST) == 인덱스 키(HDL_STS, FILE_NM)
 *		ㅁ 즉, B-Tree 인덱스가 테이블을 포함하는 형태로 동작한다.
 *
 *
 *	ㅇ 데이터 저장 방식(Heap Table vs IOT(일체형 인덱스) 비교)
 *		
 *	    ㅁ 일반적인 Heap Table(분리형)
 *		- Heap Table(데이터)
 *				(Row 1) { emp_id: 3, name: 'Alice', salary: 5000 }
 *				(Row 2) { emp_id: 1, name: 'Bob', salary: 7000 }
 *				(Row 3) { emp_id: 2, name: 'Charlie' salary: 6000 }
 *
 *		  B-Tree Index ( emp_id 기준 )
 *			 	(Index Key: 1) -> Row 2 위치
 *				(Index Key: 2) -> Row 3 위치
 *				(Index Key: 3) -> Row 1 위치
 *		체크포인트: 인덱스는 데이터의 위치(RowID)만 저장
 *				 인덱스를 통해 데이터를 찾은 후, 다시 테이블을 조회해야 함(Random I/O 발생)
 *
 *		
 *		ㅁ Index-Organized Table(IOT)
 *		  B-Tree(IOT 테이블)
 *				(Index Key: 1, Data: { name: 'Bob', salary: 7000 })
 * 				(Index Key: 2, Data: { name: 'Charlie' salary: 6000 })
 * 				(Index Key: 3, Data: { name: 'Alice', salary: 5000 })
 * 		체크포인트: 인덱스가 곧 테이블을 포함하므로,
 * 					- 데이터가 정렬된 상태로 저장됨.
 * 					- 추가적인 테이블 조회 없이 인덱스 검색만으로 데이터 조회 가능
 * 				 테이블이 없고, 오직 인덱스만 존재!
 * 
 * 
 *	2. 인덱스 일체형(IOT) 테이블의 주요 특징
 *	 (1): Index Only Scan 가능( 빠른 검색 속도 )
 *		ㅇ 일반적인 Heap Table은 인덱스 조회 후, 테이블을 다시 조회해야 하는 Overload가 발생함.
 *		ㅇ 반면, IOT(인덱스 일체형)는 인덱스 자체가 테이블을 포함하므로 추가적인 테이블 조회 없이 인덱스만으로 데이터 조회 가능
 *		ㅇ 특히, SELECT 속도가 매우 빠름
 *
 *	 (2): 정렬된 상태로 저장( 범위 검색 최적화 )
 *		ㅇ B-Tree 구조로 정렬된 상태를 유지하므로 범위 검색(Range Scan) 성능이 향상됨
 *		ㅇ 예): SELECT * FROM EMPLOYEES WHERE EMP_ID BETWEEN 1 AND 3;
 *			Heap Table: 인덱스 조회 -> 테이블 조회(Random I/O)
 *			IOT: 연속된 블록을 읽으므로 Random I/O 없이 빠르게 조회 가능(Sequential I/O)
 *
 *	 (3): 저장 공간 절약
 *		ㅇ 일반적인 Heap Table + Index 구조에서는 
 *			- 테이블과 인덱스를 따로 저장해야 함 -> 공간 낭비 발생
 *		ㅇ IOT는 하나의 B-Tree 내에 데이터가 포함되므로 공간 사용이 효율적
 *
 * 	 (4): INSERT/UPDATE 속도 저하 가능
 * 		ㅇ 데이터가 정렬된 상태를 유지해야 하므로 중간 삽입 시, 페이지 분할(Page Split)발생 가능.
 * 			- 예): INSERT INTO EMPLOYEES VALUES(2, 5, 'David', 6200);
 * 				기존 데이터: 1 -> 2 -> 3
 * 				새 데이터:(2.5) 삽입 시 B-Tree 정렬 유지 -> 페이지 분할 발생 가능
 * 			- 즉, 랜덤함 키 삽입이 많으면 성능 저하가 발생할 수 있다.
 * 
 *   (5): 다중 인덱스 사용 제한
 * 		ㅇ IOT에서는 하나의 클러스터형 인덱스(Primary Key)만 사용 가능.
 * 		ㅇ 추가 인덱스를 생성하면 별도의 Secondary Index가 생성되지만, 성능이 다소 저하될 수 있음.
 * 
 * 
 *	3. 인덱스 일체형 테이블의 장점과 단점
 *     특정						장점									단점
 * 	   데이터 저장 방식				인덱스에 테이블 데이터 포함				정렬된 상태 유지 필요
 * 	   조회 성능					Index Only Scan가능(빠름)				특정 쿼리에 따라 성능 저하 가능
 * 	   범위 검색(Range Scan)		최적화 됨(Sequential I/O)				-
 * 	   INSERT / UPDATE			-									중간 삽입 시 페이지 분할(Page Split)발생 가능
 * 	   저장 공간					테이블 + 인덱스 하나로 관리 -> 공간 절약		-
 * 	   다중 인덱스					불필요한 Secondary Index 조회 감소		하나의 클러스터형 인덱스만 사용 가능
 * 
 * 
 *  4. 인덱스 일체형 테이블이 적합한 경우
 *		ㅇ IOT를 사용하면 좋은 시나리오
 *		1. 읽기(SELECT) 성능이 중요한 경우
 *			ㅁ 예): SELECT EMP_ID, NAME FROM EMPLOYEES WHERE EMP_ID = 3;
 *			ㅁ IOT -> Index Only Scan 가능 -> 빠름
 *
 *		2. 범위 검색이 자주 발생하는 경우
 *			ㅁ 예: SELECT  * FROM EMPLOYEES WHERE EMP_ID BETWEEN 1000 AND 2000;
 *			ㅁ IOT -> 정렬된 상태 유지 -> Sequential I/O 가능  -> 빠름
 *
 *		3. 데이터 저장 공간을 절약하고 싶은 경우
 *			ㅁ 테이블과 인덱스를 따로 유지하는 Heap Table 구조보다 공간 절약 가능
 *
 *		[ IOT(인덱스 일체형) 사용이 부적절한 경우 ]
 *		1. INSERT / UPDATE가 빈번한 OLTP 시스템
 *			ㅁ 데이터 정렬 유지 때문에 중간 삽입 시 성능 저하 가능.
 *			ㅁ 예: INSERT INTO EMPLOYEES VALUES(2.5, 'David', 6200);
 *				- 페이지 분할 발생 -> 성능 저하
 *
 *		2. 다중 인덱스가 필요한 경우
 *			ㅁ 하나의 클러스터형 인덱스만 사용 가능 -> 다양한 검색 조건이 필요한 경우 제한적.
 *
 *
 *	5. 결론: 언제 인덱스 일체형 테이블을 선택할까?
 *		ㅇ IOT(인덱스 일체형 테이블)를 사용해야하는 경우
 *			ㅁ 읽기(SELECT) 성능이 중요한 OLAP 시스템
 *			ㅁ 범위 검색이 자주 발생하는 경우(Sequential I/O 활용 가능)
 *			ㅁ 데이터 저장 공간을 최적화하고 싶은 경우
 *
 * 		ㅇ 일반 Heap Table이 더 적합한 경우
 * 			ㅁ INSERT / UPDATE가 많고 OLTP 환경에서 사용되는 경우
 * 			ㅁ 다중 인덱스가 필요한 경우
 * 		체크 포인트: 즉, IOT는 "읽기 성능과 범위 검색이 중요한 경우"에 최적화된 테이블 구조이다.  
 *  
 */