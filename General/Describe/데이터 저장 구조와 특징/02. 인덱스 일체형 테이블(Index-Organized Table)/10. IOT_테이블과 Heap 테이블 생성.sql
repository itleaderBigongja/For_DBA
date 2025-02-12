/** IOT 테이블과 Heap 테이블 생성 방법
 *  
 *  Heap Table 생성( Oracle, PostgreSQL )
 * 	예제: 주문 테이블(Heap Table)
 * 		
 * 		CREATE TABLE ORDERS(
 * 			ORDER_ID		NUMBER		PRIMARY KEY,
 * 			CUSTOMER_ID		NUMBER		NOT NULL,
 * 			ORDER_DATE		DATE		DEFAULT SYSDATE,
 * 			TOTAL_PRICE		NUMBER
 *		)ORGANIZATION HEAP; # Heap Table은 -> ORGANIZATION HEAP 생략이 가능하다.
 *		
 *
 *		Heap Table이 적합한 이유
 *		 ㅇ ORDER_ID는 Primary Key이지만, 테이블 내 데이터가 특정 순서 없이 저장됨.
 *		 ㅇ 삽입 / 수정이 빈번한 OLTP 시스템에서 랜덤 액세스 속도가 빠름.
 *		 ㅇ 인덱스를 직접 CREATE INDEX로 추가 가능. 
 *
 *		Heap Table에 보조인덱스 추가 예시
 *		 ㅇ 예제 :
 *			CREATE INDEX IDX_ORDER_CUSTOMER ON ORDERS(CUSTOMER_ID);  
 *
 * ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *
 *	Index Organized Table(IOT) 생성 및 활용
 *	IOT Table 생성(Oracle)
 *	예제: 고객 테이블( IOT TABLE )
 *
 *		CREATE TABLE CUSTOMERS(
 *			CUSTOMER_ID			NUMBER			PRIMARY KEY,
 *			NAME				VARCHAR2(100),
 *			EMAIL				VARCHAR2(255),
 *			PHONE				VARCHAR2(20)
 *		) ORGANIZATION INDEX;
 *
 *		IOT Table이 적합한 이유
 *		 ㅇ CUSTOMER_ID를 기준으로 데이터가 정렬 저장됨.
 *		 ㅇ PK 기반 검색이 매우 빠름 -> 고객 정보를 자주 조회하는 환경에 적합
 *		 ㅇ ROWID가 필요 없으므로 공간 절약 효과
 *
 * 
 * Heap Table vs IOT Table 비교 예제
 * 	1) Heap Table에서 데이터를 조회할 때
 * 		SELECT * FROM ORDERS WHERE ORDER_ID = 1001;
 * 		ㅇ ORDER_ID가 ROWID를 기반으로 검색됨.
 * 		ㅇ PK는 보조 인덱스이며, 테이블과 별도로 관리됨.
 * 
 **/