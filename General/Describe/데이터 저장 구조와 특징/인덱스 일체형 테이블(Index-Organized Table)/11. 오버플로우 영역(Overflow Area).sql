/* 오버플로우(Overflow)란?
 * DB에서 오버플로우(Overflow)는 테이블 구조에 따라 다르게 발생하며, 성능 저하의 원인이 될수 있다.
 * Heap Table과 Index Organized Table(IOT)의 오버플로우 개념과 원인, 해결 방법을 알아보자.
 * 
 * 
 * 1. Heap Table에서 오버플로우란?
 * 	ㅇ Heap Table은 데이터가 무작위로 저장되므로, 기존 블록이 가득 찬 상태에서 새로운 데이터가 삽입되면
 *    새로운 블록에 데이터가 저장됩니다. 이 때, 기존 블록과 신규 블록이 서로 연결되며 체인 형태(Chained Row)로 저장되는데,
 *    이를 오버플로우(Overflow) 또는 Row Chaining이라고 한다.
 * 
 * 
 * 	ㅇ 오버플로우가 발생하는 원인
 * 	 1. UPDATE로 인해 기존 블록에 데이터가 더 이상 들어갈 수 없는 경우
 * 		ㅇ VARCHAR 같은 가변 길이 컬럼이 크기가 증가하면, 기존 블록이 부족해 새로운 블록으로 데이터를 이동하게됨
 * 
 * 	 2. 데이터 블록 크기(Block Size)가 작아 한 행이 한 블록에 담기지 못하는 경우
 * 		ㅇ 블록 크기가 8KB인데, 한 개의 행이 10KB를 차지하면 데이터가 여러 블록으로 분산됨
 * 
 * 	 3. 테이블에 PCTFREE 설정이 너무 낮아 여유 공간이 부족한 경우
 * 		ㅇ PCTFREE는 블록에 남겨두는 여유 공간인데, 설정이 낮으면 UPDATE 시 오버플로우 가능성이 증가.
 * 		ㅇ PCTFREE는 블록의 남은 빈 공간 20%를 차지하는 공간을 말한다.
 * 
 * 
 *  ㅇ Heap Table 오버플로우 문제 해결 방법:
 * 		1. 테이블 재구성( Rebuild )
 * 			-> ALTER TABLE ORDERS MOVE;
 * 			ㅇ 데이터를 새로운 블록으로 정리하면서 오버플로우를 방지한다.
 * 
 *  	2. PCTFREE 값을 조정하여 UPDATE를 대비한 여유 공간 확보
 * 			-> ALTER TABLE ORDERS PCTFREE 20;
 * 			ㅇ 블록 내 20% 공간을 비워둠으로써 UPDATE 시 오버플로우를 줄임
 * 
 * 		3. 테이블의 Block Size를 늘리기
 * 			ㅇ 데이터베이스 설정을 조정하여 블록 크기를 16KB 또는 32KB로 변경 가능.
 * 
 * 		4. 대형 컬럼(VARCHAR, CLOB)을 ROWID 기반 외부 테이블로 분리
 * 			-> CREATE TABLE ORDERS_DETAILS (
 * 					ORDER_ID			NUMBER			PRIMARY KEY,
 * 					DETAILS				CLOB
 * 			   )LOB(DETAILS) STORE AS SECUREFILE;
 * 			ㅇ 큰 데이터(CLOB)를 LOB 저장소로 이동하여 테이블 본체의 크기를 줄임
 * 
 * 
 * 2. Index Organized Table (IOT)의 오버플로우
 * 	 ㅇ IOT 오버플로우란?
 * 		-> IOT는 PK를 기준으로 데이터가 정렬 저장되므로, PK가 커지거나, ROW 크기가 증가하면 
 *         기존 블록에 수용할 공간이 부족해지는 경우가 발생한다. 이 때,
 *         오버플로우 블록(Overflow Segment)이 생성되어 데이터가 따로 저장된다.
 * 
 * 
 * 	 ㅇ IOT에서 오버플로우가 발생하는 원인
 *	  1. IOT 테이블에 큰 비가변 길이(VARCHAR, BLOB) 컬럼이 포함된 경우
 *		-> 기본적으로 PK를 기준으로 정렬되므로, 큰 데이터를 포함하면 블록이 쉽게 차고, 오버플로우 발생.
 *
 *	  2. PK 업데이트가 많아 데이터 정렬을 자주 변경해야 하는 경우
 *		-> IOT는 PK 정렬을 유지해야 하므로, PK가 자주 변경되면 데이터가 오버플로우 블록으로 이동됨.
 *
 * 	  3. 오버플로우 임계값(PCTTHRESHOLD)이 적절하게 설정되지 않은 경우
 * 		-> PCTTHRESHOLD는 기본 테이블 블록에 저장할 최대 크기를 결정하며, 너무 낮으면 오버플로우 증가.
 * 
 * 
 *	 ㅇ IOT의 오버플로우 문제 해결 방법
 *	  1. 오버플로우 세그먼트(Overflow Tablespace) 사용
 *		-> CREATE TABLE CUSTOMERS )
 *				CUSTOMER_ID			NUMBER			PRIMARY KEY,
 *				NAME				VARCHAR2(100),
 *				EMAIL				VARCHAR2(255),
 *				PHONE				VARCHAR2(20)
 *		   ) ORGANIZATION INDEX
 *			 OVERFLOW TABLESPACE USERS;
 *		ㅁ 큰 데이터를 오버플로우 테이블스페이스에 분리 저장하여 성능 저하를 방지.
 *
 *	  2. 오버플로우 임계값(PCTTHRESHOLD) 조정
 *		-> ALTER TABLE CUSTOMERS PCTTHRESHOLD 40;
 *		ㅁ 기본 블록 내 40%까지 저장하고, 초과하면 오버플로우 블록으로 이동. 	         
 * 		
 * 	  3. IOT 테이블을 일반 Heap Table + Index로 변환
 * 		-> CREATE TABLE CUSTOMERS_HEAP
 * 		   AS
 * 		   SELECT * FROM CUSTOMERS;
 * 		ㅁ PK 기반 조회가 많지 않다면 Heap Table로 변환하여 오버플로우 문제를 제거
 * 
 * 	  4. PK 컬럼 크기를 줄이기
 * 		-> PK 길이가 크면 정렬 시 오버플로우가 발생할 확률 증가 -> 크기를 줄이거나, 숫자형으로 변경
 * 
 * 
 * 3. Heap Table vs IOT의 오버플로우 비교 요약
 * ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *						Heap Table					  |	IOT Table
 * ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *	오버플로우 원인	  	|	Update/Insert로 인해 블록 부족	  |	PK 정렬 유지로 인해 블록 공간 부족
 *	주로 발생하는 환경	|	OLTP 환경에서 Update가 많을 때	  |	OLAP 환경에서 PK가 길어지거나 Update가 많을 때
 *	오버플로우 해결 방법 | 	PCTFREE 증가, 테이블 재구성		  |	OVERFLOW TABLESAPCE 설정, PCTTHRESHOLD 조정
 *	대형 데이터 처리	|   CLOB, VARCHAR를 LOB 저장소로 분리 |	VARCHAR 등 가변 컬럼을 OVERFLOW 세그먼트로 이동
 * ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ	
 * 
 * 결론:
 * 	Heap Table의 오버플로우 해결
 * 	 ㅇ PCTFREE 설정을 높여 블록 내 여유 공간 확보.
 *   ㅇ 테이블을 MOVE하여 오버플로우 블록을 제거
 *   ㅇ 블록 크기를 키우거나, 대형 컬럼을 LOB 저장소로 분리
 *
 *  IOT Table의 오버플로우 해결
 *   ㅇ OVERFLOW TABLESPACE를 설정하여 오버플로우 블록을 분리
 *   ㅇ PCTTHRESHOLD 값을 조정하여 일부 데이터를 본 블록에 유지
 *   ㅇ PK 크기를 줄이거나, 필요하면 Heap Table로 변환. 
 **/

