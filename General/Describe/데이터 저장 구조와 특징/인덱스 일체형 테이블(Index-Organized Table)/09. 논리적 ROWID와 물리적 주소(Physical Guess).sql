/** 논리적 ROWID와 물리적 주소(Physical Guess)에 대해서
 * 
 * 1. ROWID 개념정리
 * 	  데이터베이스에서 특정 레코드(Row)를 식별할 때, ROWID를 사용합니다.
 * 	  ROWID는 레코드의 위치를 나타내며, 데이터가 저장된 물리적 주소(페이지, 블록, 슬롯)를 기반으로 한다.
 * 
 * 	  IOT의 경우 물리적 ROWID를 가지지 않는다.
 *	  IOT는 데이터가 B-Tree(인덱스 구조) 내에 정렬되어 저장되기 때문에 물리적 ROWID를 가지지 않는다.
 *	  보조인덱스를 생성했을 경우, 데이터 행을 식별하기 위해 논리적인 ROWID를 사용한다.
 *    논리적 ROWID는 기본 키 값을 기반으로 생성되고 보조인덱스는 인덱싱된 열의 값과 해당 행의 논리적인 ROWID를 함께 저장한다.
 *    그렇기 때문에 IOT에 보조인덱스를 생성했더라도 Heap Table로 변경이 되지 않는다. 	  
 *	  
 * 
 *		ㅇ ROWID의 유형
 *		 1. 물리적 ROWID(Physical ROWID) == 일반 테이블
 *			ㅁ ROWID는 데이터가 저장된 정확한 물리적 위치를 식별자이다.
 *			ㅁ ROWID는 ( 데이터파일 번호 + 블록 번호 + 슬롯 번호 )로 구성된다.
 *			ㅁ ROWID는 데이터가 이동(INSERT, UPDATE, DELETE)되면 변경될수 있다.
 *			ㅁ 대부분의 RDBMS(Oracle, PostgreSQL, SQL Server 등)에서 제공된다.
 *
 * 		 2. 논리적 ROWID(Logical ROWID) == IOT
 * 			ㅁ 클러스터형 인덱스(IOT)나 고유식별자(Unique ID)를 기반으로 한다.
 * 			ㅁ 물리적 위치가 아니라 논리적 식별값으로 데이터를 참조하므로, 데이터가 이동해도 불변할 수 있음.
 * 			ㅁ 논리적 ROWID는 예:(UUID, SERIAL, IDENTITY, GUID), 또는 주요 인덱스 키
 * 			ㅁ ROWID 변경 없이 데이터를 이동할 수 있음 -> 대용량 데이터베이스에서는 논리적 ROWID가 효율적이다.
 *		
 *
 * 2. 물리적 ROWID와 논리적 ROWID의 차이
 * 		구분				물리적 ROWID(Physical ROWID)					논리적 ROWID(Logical ROWID)
 *		ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 * 		기반 구조		|	데이터 블록의 물리적 주소					|		기본 키 또는 인덱스 키
 *		변경 여부		|	데이터가 이동(DML 쿼리)하면 변경됨			|		데이터가 이동(DML 쿼리)해도 유지가능
 *		조회 성능		|	빠름									|		느림
 *		재구성 시 영향	|	테이블 리빌드 시 변경됨					|		논리적으로 유지 가능
 *		사용 사례		|	OLAP, 페타바이트급 DW					|		대규모 트랜잭션 시스템, OTLP
 *		성능 비교		|   물리적 ROWID > 논리적 ROWID(단일행 접근) 	| 		기본 키 기반 범위 검색 > 물리적 ROWID (인덱스 스캔 후 ROWID 접근)
 *		ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *
 *
 * 3. 물리적 ROWID(Physical ROWID)의 동작 방식
 * 	ㅇ 예제: ORACLE 기준
 * 	   -> ROWID = OOOOOOFFFBBBBSSS
 * 		ㅁ OOOOOO -> 데이터파일 번호 (Data File Number)
 * 		ㅁ FFF    -> 테이블스페이스 내 상대 파일 ID
 * 		ㅁ BBBB   -> 블록 번호(Block Number)
 * 		ㅁ SSS    -> 슬롯 번호(Row Slot Number in Block) 	
 * 
 *	
 *	ㅇ 물리적 ROWID 사용의 장점과 단점
 *	 ㅁ 장점: 1. 빠른 데이터 조회(Direct Block Access)
 *	        2. 클러스터형 인덱스(Clustered Index)에서 성능 최적화 가능
 *
 * 	 ㅁ 단점: 1. 데이터 이동(DML) 시 ROWID 변경됨 -> FK 등 참조 무결성 유지 어려움
 * 			2. 인덱스 리빌드 시 비효율적 -> 기존 ROWID와 달라질 수 있음
 * 			3. 삭제된 ROWID는 재사용될 수 있음 -> 정합성 문제 발생 가능
 * 
 * 
 * 4. 논리적 ROWID(Logical ROWID)의 동작 방식
 * 	ㅇ 논리적 ROWID의 구현 방식
 * 	 ㅁ 논리적 ROWID는 주요 인덱스 키를 기반으로 한다.
 * 	 ㅁ 예제: PostgreSQL, MySQL, SQL Server 등에서 논리적 ROWID로 활용할 수 있는 것
 * 		- UUID( uuid_generate_4() )
 * 		- IDENTITY / SERIAL( 자동증가 )
 * 		- 기본 키 인덱스( Primary Key )
 * 		- 글로벌 유니크 키(GUID)
 * 		# 여기서 USER_ID가 논리적 ROWID 역할을 수행
 * 
 * 	 ㅁ 예제 PostgreSQL에서 논리적 ROWID를 사용
 * 		CREATE TABLE USERS(
 * 			USER_ID			SERIAL				PRIMARY KEY,
 * 			USERNAME		VARCHAR(255)		NOT NULL,
 * 			EMAIL			VARCHAR(255)		UNIQUE NOT NULL
 * 		);
 * 
 * 	 ㅁ 예제: Oracle에서 논리적 ROWID 사용
 * 		CREATE TABLE ORDERS (
 * 			ORDER_ID		NUMBER				PRIMARY KEY,
 * 			ORDER_DATE		DATE,
 * 			CUSTOMER_ID		NUMBER REFERENCES CUSTOMERS(CUSTOMER_ID)	# CUSTOMERS 테이블의 CUSTOMER_ID 참조(외래키)
 * 		) ROWDEPENDENCIES;
 * 		# ORDER_ID는 논리적 ROWID처럼 동작하지만, 내부적으로 물리적 ROWID를 활용할 수도 있음.
 * 
 * 
 * 5. 물리적 주소(Physical  Guess)
 *    대형 데이터베이스 시스템(예: SQL Server)에서는 Physical Guess라는 개념이 존재한다.
 *    이것은 비클러스터형 인덱스(Non-clustered Index)가 행의 실제 물리적 위치를 "추측"하는 값을 가질 때 사용된다.
 *
 *	ㅁ Physical Guess(추측)의 동작 방식
 *		- 비클러스터형 인덱스(Non-clustered Index)가 특정 행을 찾기 위해 
 *		  클러스터형 인덱스(Clustered Index)또는 RID Lookup을 사용해야 하는 경우
 * 		- SQL Server에서는 Physical Guess를 통해 데이터 페이지를 빠르게 찾도록 설계됨.		
 * 		- 그러나 데이터가 이동하면 Physical Guess 값이 잘못될 수 있음 -> 추가적인 인덱스 리빌딩이 필요.
 * 
 * 		 ㅁ 예제: SQL Server 비클러스터형 인덱스가 Physical Guess를 활용하는 방식
 * 			CREATE TABLE PRODUCTS (
 * 				PRODUCT_ID			INT				PRIMARY KEY,
 * 				PRODUCT_NAME		VARCHAR(100),
 * 				PRICE				DECIMAL(10, 2)
 * 			);
 * 
 * 			CREATE NONCLUSTERED INDEX IDX_PRODUCT_NAME	ON	PRODUCT(PRODUCT_NAME);
 * 
 * 		  ㅇ IDX_PRODUCT_NAME 인덱스는 PRODUCT_NAME -> PRODUCT_ID 매핑을 저장하지만,
 * 			 PRODUCT_ID가 물리적으로 변경되면 Physical Guess가 깨질수 있음
 * 			 하지만, PRODUCT_ID의 물리적 위치(Physical Guess)가 변경될 경우 -> 추가적인 인덱스 리빌드가 필요함
 * 
 * 
 * 6. IOT의 B-Tree의 경우 하나의 블록 사이즈의 80%까지만 채우고 나머지 20%는 남겨둔다.
 * 	  그 이유는 새로운 INSERT 작업이나 UPDATE를 했을 경우를 대비하기 때문이다.
 *    
 *    만약 IOT 테이블에서 DELETE로 인해, B-Tree의 각각의 블록 사이즈가 비어 있어서 클러스터링 팩터가 높아질 경우
 * 	  REBUILD작업을 통해서 테이블의 성능을 높일 수 있지만, 오히려 REBUILD작업으로 인해 INSERT || UPDATE를 할 때 
 *    더 오랜 작업 시간이 걸릴수도 있다. 그렇기 때문에 테이블을 설계할 때, 이 테이블의 조회 빈도수, 데이터 이동(DML)의 빈도수를
 *    생각해서 테이블을 설계를해야 한다. 
 *   
 *   [참고]
 *    IOT의 경우, 테이블의 최대로 사용한다 코드성 테이블로 생성하는게 좋다.
 * 	  코드성 테이블은 카테고리 테이블을 말하며 카테고리별 코드값과 데이터의 상태성 코드를 모아두는 작은 테이블이다.
 *    이러한 테이블은 데이터 이동(DML)의 빈도수가 낮고, 조회 빈도수가 높기 때문에 
 *    IOT 테이블을 생성해야 한다면 카테코리 코드성 테이블을 생성하는게 제일 좋다.
 * 
 * 
 * 7. 오라클의 경우 VARCHAR	 Type의 속성의 length 길이를 4000Byte까지 지정할수있다.
 *    이를 넘을 경우를 대비해서 CLOB Type의 속성이 있는건데, CLOB는 데이터 저장 블록이 별도 있기 때문에
 *    조회를 할 때, 빠르다. 하지만 CLOB Type을 쓰는 경우(INSERT, UPDATE, DELETE)를 할 경우는
 *    Block을 두 번 읽어야 하므로 성능 저하가 발생할 수 있다.
 * 
 * 	  
 * 8. PostgreSQL에서는 오라클의 이러한 점을 보완하고자 VARCHAR TYPE 속성의 length 길이를 무제한으로 지정할 수 있다.
 * 	  그렇기 때문에 조회를 할 경우는 오라클 RDBMS가 좋을수도 있지만, DML 즉, 데이터 이동을할 때는 PostgreSQL이 더 좋다.
 *    이처럼 프로젝트를 설계할 때, 각각의 DB의 특성을 파악하고 자신에게 더 필요한 DB를 사용하면 된다.  
 */