/** 인덱스 일체형 테이블: 분리형과 일체형 비교
 *  데이터베이스에서 테이블과 인덱스를 저장하는 방식은 크게 두 가지로 나뉜다.
 *  1. 분리형(Heap Table + Secondary Index)
 *  2. 일체형(Clustered Index 또는 Index-Organized Table, IOT)
 *  체크포인트: 각 방식은 데이터 저장 구조, 성능, 그리고 활용 방식이 다르며, 이를 이해하면 데이터베이스 성능을 극대화할 수 있다.
 *
 * 
 * [ Secondary Key(보조 인덱스)에 대해서 ]
 * 목적: 데이터베이스에서 보조 인덱스를 사용하는 주요 목적은 데이터 액세스 성능을 향상시키는 것이다.
 * 개념: 보조 인덱스는 테이블의 기본 키가 아닌 열에 구축되는 인덱스이다.
 *      기본 인덱스는 테이블의 기본키(PK)를 기반으로 하고 데이터에 대한 링크를 제공하지만,
 *      보조 인덱스는 다른 열에 구축되어, 해당 열을 기반으로 데이터에 더 빠르게 액세스할 수 있다.
 * 
 * 장점: ㅇ 데이터 검색 속도 향상: 보조 인덱스는 특정 열을 기반으로 데이터를 정렬하여 검색 속도를 높여준다.
 * 		ㅇ 쿼리 성능 향상: 보조 인덱스를 생성함으로써 WHERE 절이나 JOIN 조건에서 자주 사용되는
 *                     열에 대한 쿼리의 성능을 향상시킬 수 있다.
 *
 * 단점: ㅇ 저장 공간: 생성하는 각 인덱스에는 추가 저장 공간이 필요하다.
 * 		ㅇ 쓰기 공간: 
 * 				1. 행이 삽입되거나 업데이트될 때 마다 테이블의 모든 인덱스도 업데이트 되어야한다.
 * 				2. 이로 인해 특히 쓰기 작업이 많은 큰 테이블이나 테이블에서 쓰기 작업 속도가 느려질 수 있다.
 * 
 * 
 * 
 *  1. 분리형 테이블( Heap Table + Secondary Index )
 *	개념
 *	  ㅇ 테이블과 인덱스가 별도로 저장되는 방식
 *	  ㅇ 데이터는 테이블 내부의 빈 공간(Heap)에 저장되고, 특정한 정렬 없이 추가됨.
 *	  ㅇ 인덱스는 별도의 B-Tree 구조로 존재하며, 검색 시 테이블을 추가 조회해야 함.
 *
 *	데이터 저장 방식
 *	Heap Table( 테이블 데이터 )
 *	-> ( Row 1 ) { name: 'Alice', age: 25, salary: 5000 }
 *	-> ( Row 2 ) { name: 'Bob', age: 30, salary: 7000 }
 *  -> ( Row 3 ) { name: 'Charlie' age: 28, salary: 6000 }
 * 
 *  Secondary Index( B-Tree )
 *  -> (Key: 25) -> Row 1 위치
 *  -> (Key: 28) -> Row 3 위치
 *  -> (Key: 30) -> Row 2 위치
 *	  ㅇ 인덱스는 데이터의 위치(RowID 또는 Pointer)만 저장.
 *	  ㅇ 따라서, 인덱스를 조회한 후, 테이블을 추가 조회해야 하는 Overhead(Random I/O)가 발생.
 *
 *  분리형 테이블의 장점:
 *	  ㅇ INSERT, UPDATE가 빠름 -> 데이터 정렬이 필요하지 않으므로 임의 위치(Heap)에 바로 저장 가능.
 *	  ㅇ 다양한 인덱스를 생성 가능 -> 여러 개의 인덱스를 추가할 수 있음.
 *    ㅇ DML작업(INSERT, UPDATE, DELETE)처리 유연 -> 데이터 정렬 부담이 없음.
 * 
 *  분리형 테이블의 단점:
 * 	  ㅇ 인덱스 탐색 후 테이블 조회 필요 -> Random I/O 증가
 *       ㅁ 예: SELECT * FROM EMPLOYEES WHERE AGE = 30;
 * 	     	1. B-Tree 인덱스 검색 -> age = 30인 위치(RowID) 찾음.
 * 		 	2. 테이블에서 해당 위치의 데이터 읽음 -> 추가적인 디스크 I/O 발생
 *
 * 	     ㅁ 대량의 데이터를 조회할 때 성능 저하가 발생
 * 
 *	  ㅇ 클러스터링 팩터(Clustering Factor) 문제
 *		 ㅁ 인덱스 정렬과 테이블 데이터 정렬이 불일치하면 범위 검색 성능이 저하됨
 *
 * 	  ㅇ 대량 데이터 조회 시 성능 저하 가능
 * 		 ㅁ SELECT * 시 테이블 Full Scan이 발생할 가능성이 높음
 * 
 * 
 *  2. 일체형 테이블( Clustered Index / IOT: Index-Organized Table )
 *  개념:
 * 	  ㅇ 테이블이 클러스터형 인덱스 내부에 포함된 상태
 *    ㅇ 즉, 인덱스 정렬 순서대로 테이블 데이터가 함께 저장됨.
 *    ㅇ Oracle의 IOT(Index-Organized Table),
 *       MySQL의 InnoDB(Clustered Index)등이 해당됨.
 * 
 *  데이터 저장 방식
 * 	  ㅇ Clustered Table(B-Tree)
 * 		 -> (Key: 25, Data: { name: 'Alice', salary: 5000 } )
 *       -> (Key: 28, Data: { name: 'Charlie', salary: 6000 } )
 * 		 -> (Key: 30, Data: { name: 'Bob', salary: 7000 } )
 *       ㅁ 인덱스 자체가 테이블을 포함하고 있음.
 * 		 ㅁ 별도의 테이블 조회 없이 인덱스만으로 데이터 검색 가능!
 * 
 *  일체형 테이블 장점:
 * 	  ㅇ Index Only Scan 가능 -> 조회 성능 향상
 * 		 ㅁ 인덱스 자체가 데이터를 포함하므로 추가적인 테이블 조회 없이 인덱스 탐색만으로 조회 가능
 * 		 ㅁ 예: SELECT age, salary FROM EMPLOYEES WHERE age = 30;
 * 			- Heap Table -> 인덱스 검색 -> 테이블 조회( Random I/O 발생 )
 * 			- IOT( Index-Organized Table ) -> 인덱스 검색만으로 데이터 조회 가능( 빠름 )
 * 
 * 	  ㅇ 범위 검색( Range Scan ) 성능 최적화
 * 		 ㅁ 데이터가 정렬된 상태로 저장되므로 클러스터링 팩터가 낮고, 연속된 블록을 읽는 Sequential I/O가 가능.
 * 
 *    ㅇ 저장 공간 절약
 * 		 ㅁ 테이블과 인덱스가 하나로 통합되므로 공간 사용이 효율적
 * 
 * 
 * 	일체형 테이블 단점:
 * 	  ㅇ INSERT/UPDATE 성능 저하
 * 		 ㅁ 데이터를 정렬된 상태로 유지해야 하므로 중간 삽입 시 페이지 분할(Page Split) 발생 가능.
 * 		 ㅁ 예: INSERT INTO EMPLOYEES
 * 			   ( age, name, salary )
 * 			   VALUES
 * 			   ( 27, 'David', 6500 );
 *			- Heap Table -> 빈 공간에 삽입하면 끝
 *			- Clustered Table -> 정렬된 위치를 유지하기 위해 데이터 재정렬 발생( 추가적인 성능 저하 가능 ).
 *
 *    ㅇ 다중 인덱스 사용 제한
 * 		 ㅁ 테이블이 인덱스 내부에 포함되므로 하나의 클러스트형 인덱스만 사용 가능.
 * 		 ㅁ 추가 인덱스를 만들면 별도의 Secondary Index가 생성되며, 성능 저하 가능.
 * 
 * 
 *  3. 분리형 vs 일체형 테이블 비교 (총 정리)
 *		비교항목						분리형 테이블(Heap Table)		일체형 테이블(Cluster / IOT )
 *		테이블과 인덱스 저장 방식			테이블과 인덱스 분리				인덱스 내부 테이블 포함
 *		데이터 정렬 유지				정렬되지 않음					정렬된 상태로 저장
 *		인덱스 탐색 후 테이블 조회			필요(Random I/O 발생)			불필요(Index Only Scan 가능)
 *		범위 검색(Range Scan) 성능		상대적으로 느림					빠름( 클러스터링 팩터 낮음 )
 *		INSERT/UPDATE 성능			빠름							느릴 수 있음( 페이지 분할 발생 가능 )
 *		다중 인덱스 사용 여부				가능							기본적으로 하나의 클러스터형 인덱스만 사용
 *		적용 사례						대규모 트랜잭션 시스템, OLTP		읽기 최적화 시스템, OLAP
 *
 *
 *	4. 언제 어떤 방식을 선택해야 할까?
 *	  ㅇ 분리형 테이블(Heap Table) 선택 기준
 *		ㅁ 다중 인덱스가 필요한 경우
 *		ㅁ INSERT / UPDATE가 빈번한 OLTP 시스템
 *		ㅁ 데이터 변경이 많고 정렬된 상태 유지가 어렵다면 Heap Table이 유리
 *
 *	  ㅇ 일체형 테이블(Clustered / IOT ) 선택 기준
 *		ㅁ 읽기(SELECT) 성능이 중요한 OLAP 시스템
 *		ㅁ 범위 검색이 자주 발생하는 경우
 *		ㅁ 인덱스만으로 데이터를 조회해야 하는 경우
 *	  체크포인트: 즉, 트랜잭션이 많은 환경(OLTP)에서는 분리형이,
 *				   조회 성능이 중요한 환경(OLAP)에서는 일체형이 적합하다.
 * */
