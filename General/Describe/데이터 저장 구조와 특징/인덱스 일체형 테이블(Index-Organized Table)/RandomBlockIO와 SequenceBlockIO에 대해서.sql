/** Random Block I/O vs Sequential Block I/O
 *  데이터베이스에서 I/O 성능은 랜덤(Random) I/O와 순차(Sequential)I/O의 차이에 크게 영향을 받는다.
 *  
 *	ㅇ Random Block I/O:
 *	-> 데이터가 여러 블록에 랜덤하게 저장되어 있어서 읽을 때, 많은 디스크 탐색(Seek)발생 -> 성능 저하
 *	
 *	ㅇ Sequential Block I/O:
 *	-> 데이터가 연속된 블록에 저장되어 있어서 빠른 읽기(Sequential Read) 가능 -> 성능 향상
 *
 * 	Index-Organized Table(IOT)에서는 어떻게 적용이될까?
 *  ㅇ IOT는 데이터를 B-Tree 인덱스 내부에 정렬된 상태로 저장하므로 Sequential I/O를 활용할 수 있는 구조이다.
 *	  하지만, 상황에 따라 Random I/O와 Sequential I/O가 어떻게 발생하는지를 이해하는 것이 중요하다.
 *
 * 	
 * 	1. Random Block I/O vs Sequential Block I/O 비교
 *  ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 * 	특징							Random Block I/O					Sequential Block I/O
 *  데이터 저장 방식				여러 블록에 분산 저장						연속된 블록에 저장
 *  데이터 조회 방식				여러 블록을 랜덤하게 읽음					연속된 블록을 순차적으로 읽음
 *  디스크 탐색(Seek Time)			많음(랜덤 접근)							적음(연속 접근)
 *  성능							느림(Random Read)						빠름(Sequential Read)
 * 
 * 
 * 	2. Heap Table vs IOT에서 I/O 차이점
 *  ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 * 	(1). 일반적인 Heap Table(일반 테이블)에서의 Random I/O
 *     ㅇ Heap Table은 데이터가 임의의 위치(랜덤 블록)에 저장되므로 Random I/O 발생!
 *		ㅁ 테이블과 인덱스가 분리되어 있어서,
 *			1. 인덱스 검색( Index I/O )
 *			2. 해당 데이티ㅓ가 저장된 블록을 찾아 다시 테이블 조회( Table I/O, Random I/O 발생 )
 *
 *		예제: SELECT NAME FROM EMPLOYEES WHERE EMP_ID = 3;
 *		
 *		Heap Table (랜덤 블록 저장)
 *		-> Block A ( Row 1 ) -> emp_id : 3
 *		-> Block C ( Row 2 ) -> emp_id : 1
 *		-> Block F ( Row 3 ) -> emp_id : 2
 *
 *		B-Tree Index(emp_id 기준)
 *		-> (Key : 1) -> Block C 위치
 *		-> (Key : 2) -> Block F 위치
 *		-> (Key : 3) -> Block A 위치
 *
 * 		Random Block I/O 발생 과정
 * 		1. 인덱스 검색: emp_id = 3 찾음 -> Block A로 이동
 * 		2. 데이터 조회: Block A에서 name 컬럼 읽음
 * 		체크 포인트: 데이터가 흩어져 있어 블록을 랜덤하게 접금해야 하므로 Random I/O 발생!
 * 
 *
 *	(2). Index-Organized Table(IOT)에서의 Sequential I/O
 *	  ㅇ IOT에서는 인덱스 자체가 테이블을 포함하므로 데이터가 정렬된 상태로 저장됨
 *		즉, 인덱스를 읽는 것만으로 데이터를 바로 가져올 수 있어 Random I/O를 줄이고 Sequential I/O 활용 가능
 *		
 *		 ㅁ 예제: SELECT NAME FROM EMPLOYEES WHERE emp_id = 3;
 *			B-Tree(IOT)
 *				- (Key : 1, { name: 'Bob', salary: 7000 })	<= Block A
 *
 *	
 *	(3). 범위 검색(Range Scan)에서의 I/O 차이
 *		ㅇ Heap Table( Random I/O 발생)
 *		 ㅁ 예제: SELECT * FROM EMPLOYEES WHERE EMP_ID BETWEEN 1 AND 3;
 *			Heap Table( 데이터 랜덤 저장 )
 *		 	- Block C -> emp_id : 1
 *		 	- Block F -> emp_id : 2
 *		 	- Block A -> emp_id : 3
 *			# 각 데이터를 찾을 때마다 Random I/O 발생!
 *			# emp_id가 1 ~ 3인 데이터를 찾기 위해 여러 블록을 랜덤하게 접근해야 함
 *			# 디스크 탐색이 많아 성능 저하
 *
 *		
 *		ㅇ IOT(Sequential I/O 발생)
 *		 ㅁ 예제: SELECT * FROM EMPLOYEES WHERE EMP_ID BETWEEN 1 AND 3;
 *			B-Tree(IOT)
 *		 	- Block A -> (Key: 1, Data)
 *		 	- Block B -> (Key: 2, Data)
 *		 	- Block C -> (Key: 3, Data) 
 *			# 데이터가 정렬된 상태로 저장되어 있어서 연속된 블록을 읽기만 하면 됨
 *			# 즉, 디스크 탐색이 거의 없이 Sequential I/O로 빠르게 조회 가능!
 *
 *
 *	(4). Index-Organized Table에서 Random I/O가 발생하는 경우
 *		ㅇ IOT가 항상 Sequential I/O를 제공하는 것은 아닙니다.
 *		
 *		ㅇ 다음과 같은 경우에는 Random I/O가 발생할 수 있음.
 *		(1). Secondary Index 사용 시, I/O 발생
 *			IOT에서는 Primary Key 기반으로 데이터가 정렬되지만,
 *			Secondary Index를 사용하면 Random I/O가 발생할 수 있음.
 *
 *		 ㅁ 예제: SELECT salary FROM employees WHERE name = 'Alice';
 *			Secondary Index (name 기준)
 *				- (Key: 'Alice') -> emp_id : 3
 *				- (Key: 'Bob')	-> emp_id : 1
 *				- (Key: 'Charlie ) -> emp_id : 2
 *
 *			B-Tree (IOT)
 *				- (Key : 1, Data)
 *				- (Key : 2, Data)
 *				- (Key : 3, Data)
 *			# 인덱스를 통해 emp_id를 찾음 -> IOT의 Primary Key 검색 -> 데이터 조회(Random I/O 발생)
 *
 *
 *	(5). 결론: Random I/O vs Sequential I/O 최적화 전략
 *		(1). Random I/O를 줄이는 방법
 *			ㅇ Heap Table 대신 Index-Organized Table 사용
 *			ㅇ 데이터가 정렬된 상태로 저장되도록 설계( 클러스터형 인덱스 사용 )
 *			ㅇ 범위 검색(Range Scan)이 많은 경우, 정렬된 구조를 활용하는 것이 유리함
 *
 *
 *		(2). Sequential I/O를 최대한 활용한 방법
 *			ㅇ Index-Organized Table을 사용하여 데이터와 인덱스를 함께 저장
 *			ㅇ 범위 검색이 많은 경우, Primary Key를 기반으로 쿼리 작성
 *			ㅇ Secondary Index 사용을 최소화하여 Random I/O 발생을 방지
 *		
 *		체크 포인트: 즉, Index-Organized Table을 활용하면 Random I/O를 줄이고,
 *				  Sequential I/O를 극대화하여 조회 성능을 향상할 수 있음. 
 */