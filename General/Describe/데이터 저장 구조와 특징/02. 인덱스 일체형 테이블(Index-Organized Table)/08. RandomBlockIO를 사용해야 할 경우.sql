/** Random Block I/O를 사용해야 하는 경우
 *  IOT(Index-Organized Table)가 Sequential I/O를 활용하여 빠른 조회 성능을
 *  제공하는 것은 맞지만, 모든 경우에 IOT가 최적의 선택은 아니다.
 *  실제 운영 환경에서는 Random Block I/O가 필요한 경우도 있다.
 *  
 * 
 *  1. IOT(Sequential Block I/O)의 단점( Random Block I/O 보다 항상 좋은가?)
 * 	IOT는 Primary Key 기반의 범위 검색이나 단건 조건 조회에 유리하지만,
 *  다음과 같은 경우에는 Random Block I/O가 필요한 구조(Heap Table)가 더 적합하다.
 *  
 *  구분						Heap Table(Random I/O)				IOT(Sequential I/O)
 *  데이터의 삽입 속도			빠름(그냥 빈 공간에 넣으면 된다.)			느림( B-Tree 정렬 유지 필요 )
 * 	UPDATE 성능				일반적으로 빠름							데이터 이동 발생 가능(성능 저하)
 *  DELETE 성능				빠름									페이지 스플릿/조각화 발생 가능
 * 	Secondary Index 성능		인덱스가 테이블과 분리되어 있어 부담이 적음	Secondary Index조회 시 Random I/O발생
 *  LOB(Large Object) 저장	가능									저장 불가능(LOB는 Heap Table이 필요)
 *  
 *  
 * 2. Random Block I/O가 필요한 경우( Heap Table[일반 테이블]이 필요한 이유 )
 * (1). INSERT 성능이 중요한 경우( 대량 데이터 적재 시 )
 * 	    -> Heap Table은 데이터를 특정한 순서 없이 빈 블록에 저장하기 때문에 INSERT 속도가 빠름
 * 		
 * 	ㅇ Heap Table( Random I/O 발생 )
 * 		ㅁ INSERT 시 그냥 빈 블록을 찾아 데이터를 넣으면 됨 -> 랜덤하게 저장됨
 * 		ㅁ 페이지 정렬이 필요 없어지므로 빠르게 저장 가능
 * 		ㅁ 대량 데이터 삽입(Bulk Insert) 시 Random I/O를 감수하고 Heap Table을 선택하는 것이 유리
 * 		
 * 	ㅇ IOT(Sequential I/O 발생)
 * 		ㅁ 데이터를 Primary Key 순서대로 저장해야 하므로 B-Tree 정렬 유지 필요
 * 		ㅁ 특정 위치에 데이터를 삽입해야 하므로 페이지 분할(Page Split)발생 가능
 * 		ㅁ INSERT 성능이 느려질 수 있음
 *  
 * 	ㅇ 실제 운영 예시
 * 		ㅁ Heap Table이 적합한 경우:
 * 			- 로그성 데이터 저장( 매일 대량으로 INSERT되는 테이블 )
 * 			- 대량 데이터 적재( ETL, Batch Processing )
 * 
 * 
 * 	(2). UPDATE가 빈번한 경우( 데이터 변경이 많음 )
 * 	ㅇ	IOT는 데이터를 Primary Key 기준으로 정렬하여 저장하므로,
 * 		만약 UPDATE로 데이터 크기가 변하면 페이지 분할이 발새ㅣㅇ하여 성능 저하가 발생할수 있음
 *		ㅁ Heap Table( Random I/O 발생 )
 *		ㅁ 데이터가 임의의 블록에 저장되어 있으므로 UPDATE 시, 기존 블록에서 크기만 변경하면 됨
 *		ㅁ UPDATE 시 데이터 이동이 거의 없음
 *
 * 	ㅇ IOT(Sequential I/O 발생)
 * 		ㅁ 기존 레코드 크기가 변경될 경우, 페이지 분할이 발생할 수 있음
 * 		ㅁ 데이터 이동이 발생하면 INSERT보다 더 큰 성능 저하 발생
 * 		
 *	ㅇ 실제 운영 예시
 *		ㅁ Heap Table이 적합한 경우
 *		ㅁ 자주 업데이트 되는 테이블(예: 주문 상태 변경, 실시간 재고 수정)
 *
 * 
 * 	(3). Secondary Index(보조 인덱스)가 많은 경우( 보조 인덱스 사용이 많음 )
 * 	ㅇ IOT에서는 Primary Key 기준으로 데이터가 정렬되어 저장되지만,
 *	   Secondary Index를 사용할 경우 Random I/O 발생할 가능성이 있음.
 *
 *		ㅁ 예제: SELECT NAME EMPLOYEES WHERE department_id = 10;
 *		[ Heap Table ]
 *		Secondary Index( department_id 기준 )
 *		 - (Key : 10) -> Block A (emp_id : 3)
 *		 - (Key : 10) -> Block C (emp_id : 7)
 *		 - (Key : 10) -> Block D (emp_id : 12)
 *
 *		Heap Table( 데이터 위치 랜덤 )
 *		 - Block A -> emp_id : 3
 *		 - Block C -> emp_id : 7
 *		 - Block D -> emp_id : 12
 *		체크 포인트: Heap Table에서는 Secondary Index를 타고 가면 바로 데이터 블록을 찾을 수 있음
 *
 *	
 *		[ IOT( Index Origanized Table ) ]
 *		Secondary Index( department_id 기준 )
 *		 - (Key: 10) -> emp_id : 3
 *		 - (Key: 10) -> emp_id : 7
 *		 - (Key: 10) -> emp_id : 12
 *		체크 포인트: IOT에서는 Secondary Index를 통해 emp_id를 찾고 다시 Primary Key 기반으로
 *				  검색해야 하므로 Random I/O 발생!
 *
 *		실제 운영 예시
 *			ㅁ Heap Table이 적합한 경우:
 *				ㅇ 보조 인덱스를 많이 사용하는 테이블
 *				ㅇ Secondary Index를 통한 검색이 중요한 경우
 *
 *
 *	(4). LOB( Large Object )저장이 필요한 경우
 *		ㅇ IOT는 B-Tree 내부에 모든 데이터를 저장하는 구조이기 때문에
 *		   LOB(Large Object) 데이터를 저장할 수 있음
 *			ㅁ 대량의 텍스트, 이미지, 파일 등을 저장해야 한다면 Heap Table이 필수
 *		체크 포인트: Heap Table이 적합한 경우:
 *			ㅇ 이미지, 동영상, PDF 등 대용량 데이터를 저장해야 하는 경우
 *			ㅇ CLOB(TEXT), BLOB(BINARY) 컬럼이 있는 경우
 *
 *
 * 3. 결론: 언제 Random Block I/O를 선택해야 하는가?
 * 		ㅇ Heap Table( Random Block I/O )이 적합한 경우
 * 			ㅁ 대량 INSERT가 필요한 경우
 * 			ㅁ UPDATE가 자주 발생하는 경우
 * 			ㅁ Secondary Index를 많이 사용하는 경우( 인덱스가 1개 이상 )
 * 			ㅁ LOB 데이터( 이미지, 동영상 등)를 저장해야 하는 경우
 * 
 * 		ㅇ IOT( Sequendary Block I/O )가 적합한 경우
 * 			ㅁ Primary Key 기반의 빠른 범위 검색이 필요한 경우
 * 			ㅁ 읽기(Read) 위주의 워크로드(예: 단순 검색 시스템)
 * 			ㅁ 자주 변경되지 않는 데이터(읽기 위주)
 *
 *	   결론: (DBA 수준 조언)
 *		ㅇ Random I/O는 무조건 나쁜 것이 아니다!
 *		   운영 테이블을 설계할 때는 "I/O 패턴"을 고려해야 한다.
 *
 * 		 ㅁ 데이터가 자주 변경된다면 Heap Table( Random I/O ) 사용
 * 		 ㅁ 읽기 성능이 중요하고 정렬된 상태로 저장할 필요가 있다면( IOT : Sequential I/O ) 사용
 * 		 ㅁ 인덱스가 많거나 Secondary Index(보조인덱스) 조회가 많다면( Heap Table : Random Block I/O)더 유리
 * 		 ㅁ 조회 위주 시스템(검색, 보고서 등)이라면 IOT가 적합
 * 		-> 운영 환경과 I/O패턴에 맞춰 최적의 테이블 구조를 설계하는 것이 DBA의 핵심 역할이다.  
 *   
 */