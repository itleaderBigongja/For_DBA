/** TABLESPACE, BLOCK, SCHEMA 등 핵심 정리
 *  운영 DB설계를 위해 필요한 Tablespace, Block, Schema, Segment, Extent, Object 구조
 * 
 * 1. 데이터베이스의 물리적 & 논리적 구조
 *  ㅇ 물리적 구조(Physical Storage)
 * 	 ㅁ 실제 데이터를 저장하는 구조
 *    - 데이터 파일(Datafiles) 				-> 데이터가 저장됨
 *    - Redo 로그 파일( Redo Log Files )		-> 트랜잭션 로그 기록.
 *    - 제어 파일( Control Files )				-> DB의 메타데이터 관리.
 *
 * 예시: Oracle 기준 데이터 파일 구조 조회 )
 * 	SELECT FILE_NAME, TABLESPACE_NAME, BYTES/1024/1024 AS SIZE_MB
 * 	  FROM DBA_DATA_FILES;
 * 
 * 
 *  ㅇ 논리적 구조(Logical Storage)
 * 	 ㅁ 데이터를 관리하는 논리적인 계층 구조
 *   	- TABLESPACE 	-> 데이터 파일을 그룹화한 논리적 저장 공간
 *   	- Schema		-> 테이블, 인덱스, 뷰 등의 논리적 객체 집합
 *   	- Segment		-> 특정 객체가 사용하는 저장 공간
 *   	- Extent		-> Segment 내부에서 데이터가 할당되는 블록 단위
 *   	- Block			-> DB의 가장 작은 저장 단위
 * 
 * 
 *  ㅇ 논리적 계층 구조
 *   Tablespace
 * 		-> Schema( 사용자 )
 * 		|	-> Tables( 데이터 저장 )
 * 		|	-> Indexes( 검색 최적화 )
 * 		|	-> Views( 가상 테이블 )
 * 		|	-> Procedures( 스토어드 프로시저 )
 * 		|	-> Triggers( 트리거 )
 * 		|	-> Sequences( 시퀀스 )
 * 		|	-> Synonyms( 별칭 )
 * 		|	-> Partitions( 파티션 테이블 )
 * 		
 * 		-> Segment
 * 		|	-> Extent
 * 		|	-> Block
 * 
 * 
 * 2. Tablespace 구성과 관리
 *   ㅁ Tablespace란?
 * 	  데이터를 저장하는 논리적 공간으로, 여러 개의 데이터 파일(Datafile)로 구성됨
 * 	  DB의 성능과 안전성을 위해 다양한 Tablespace를 나누는 것이 중요함.
 * 
 * 	 ㅁ Tablespace의 종류( Oracle 기준 )
 * 	 ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 *   	Tablespace		| 설명
 *   ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 * 		SYSTEM			| DB 핵심 메타데이터 저장(삭제 불가)
 * 		SYSAUX			| 보조 시스템 영역
 * 		UNDO			| 트랜잭션 롤백 데이터 저장
 * 		TEMP			| 정렬 / 임시 데이터를 저장하는 공간
 * 		USERS			| 일반 사용자 데이터 저장
 * 		DATA(사용자 정의)	| 애플리케이션 데이터를 위한 공간
 * 	 ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
 * 
 *	 ㅁ 예시: 테이블스페이스 생성(16GB 크기 제한, 자동 확장)
 *		-> CREATE TABLESPACE APP_DATA
 *		   DATAFILE	'/u01/app/oracle/oradata/XE/system.dbf'
 *		   SIZE 500M
 *		   AUTOEXTEND ON
 *		   NEXT 100M
 *		   MAXSIZE 16G;
 *
 *	 ㅁ 기본 Tablespace 확인
 *		-> SELECT TABLE_NAME, FILE_NAME, BYTES/1024/1024 AS SIZE_MB
 *			 FROM DBA_DATA_FILES;
 *
 *	 ㅁ Tablespace 크기 증가
 *		-> ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/XE/system.dbf' RESIZE 10G;
 *
 *	 ㅁ Tablespace 삭제
 *		-> DROP TABLESPACE app_data INCLUDING ADD DATAFILES;
 *
 *
 * 3. 블록(Block), 익스텐트(Extent), 세그먼트(Segment) 이해
 *  ㅇ 블록(Block)
 * 	 ㅁ DB에서 데이터를 저장하는 가장 작은 단위( Oracle 기본 블록 크기: 8KB )
 * 	  -> 블록 크기가 크면 대량 데이터를 한번에 읽기에 유리함(OLAP).
 * 	  -> 블록 크기가 작으면 작은 데이터를 빠르게 읽기에 유리함(OLTP).
 * 
 * 	 ㅁ 블록 크기 확인
 *    -> SELECT TABLESPACE_NAME, BLOCK_SIZE
 * 		   FROM DBA_TABLESPACE;
 * 
 * 	 ㅁ 블록 크기 변경(테이블스페이스 별 설정 가능)
 * 	  -> CREATE TABLESPACE LARGE_DATA
 * 		 DATAFILE '/u01/oradata/large_data.dbf'
 *       SIZE 1G BLOCKSIZE 16K;
 * 
 *  
 *  ㅇ 익스텐트(Extent)
 *   ㅁ 블록을 묶어 할당하는 단위
 *    -> 작은 블록들이 모여 Extent를 형성함.
 * 	  -> 데이터가 증가하면 Extent가 자동으로 추가됨
 * 	  -> 불필요한 Extent는 Table Shink를 통해 정리 가능.
 * 
 * 
 * 	 ㅁ Extent 정보 확인
 * 	  -> SELECT SEGMENT_NAME, TABLESPACE_NAME, EXTENTS, BYTES/1024/1024 AS SIZE_MB
 *         FROM DBA_SEGMENTS
 *        WHERE SEGMENT_TYPE = 'TABLE';
 *  
 *   ㅁ 테이블 공간 최적화(Shrink)
 * 	  -> ALTER TABLE ORDERS ENABLE ROW MOVEMENT;
 * 	  -> ALTER TABLE ORDERS SHRINK SPACE;
 * 
 * 
 *  ㅇ 세그먼트(Segment)
 *   ㅁ 테이블, 인덱스 등 개별 객체의 저장 공간( Extent의 집합 )
 * 	  -> 데이터 세그먼트( Data Segment ) 		-> 테이블 데이터 저장
 *	  -> 인덱스 세그먼트( Index Segment )		-> 인덱스 데이터 저장
 *	  -> 임시 세그먼트( Temporary Segment )		-> 정렬, 임시 작업 데이터
 *	  -> Rollback 세그먼트( Undo Segment )		-> 트랜잭션 롤백 데이터
 *	   		
 *	 ㅁ 세그먼트 정보 조회
 *	  -> SELECT segment_name, segment_type, tablespace_name, bytes/1024/1024 AS size_mb
 *		   FROM DBA_SEGMENTS
 *		  WHERE OWNER = 'APP_USER';
 *
 *
 * 4. 스키마란?
 * 	ㅇ DB객체(테이블, 인덱스, 뷰 등) 논리적으로 그룹화한 사용자 단위 공간
 * 	  -> DBA는 여러 스키마를 운영하면서 보안과 성능을 관리해야 함.
 * 	  -> 각 애플리케이션, 사용자 그룹별로 별도의 Schema를 생성하여 관리
 * 
 *   ㅁ APP_USER 유저 생성( 스키마 사용자 생성 & 권한 부여 )
 * 	  -> CREATE USER APP_USER IDENTIFIED BY 'securepassword';
 * 		  GRANT CONNECT, RESOURCE TO app_user;
 * 		  
 *        ALTER USER APP_USER QUOTA UNLIMITED ON app_data;
 * 
 * 
 * 	 ㅁ APP_USER 스키마에 ORDERS 테이블을 APP_DATA라는 TABLESPACE에 생성
 *    -> CREATE TABLE APP_USER.ORDERS (
 * 			order_id 		NUMBER 		PRIMARY KEY,
 * 			customer_id		NUMBER,
 * 			order_data		DATA
 * 		 ) TABLESPACE app_data;
 * 
 * 
 *   ㅁ 스키마 내 객체 확인(TABLE, PACKAGE, INDEX, SEQUENCE, LOB, JOB, FUNCTION, VIEW, CLUSTER 등)
 *    -> SELECT OBJECT_NAME, OBJECT_TYPE
 * 		   FROM DBA_OBJECTS
 * 		  WHERE OWNER = 'APP_USER';
 * 
 * 
 * 5. 최적화된 설계 전략
 *  ㅇ DBA가 고려해야할 최적화 요소
 *   1. TABLESPACE를 기능별로 분리(예: USERS, DATA, INDEX, TEMP 등)
 * 	 2. 적절한 Block Size 설정( OLTP: 8KB, OLAP: 16KB ~ 32KB)
 *   3. 테이블 및 인덱스의 PCTFREE, PCTUSED 조정( INSERT/UPDATE 빈도 고려)
 *   4. LOB 데이터를 외부 스토리지로 관리( SECUREFILE, NFS )
 *   5. Regular Monitoring 및 Auto Collection 활용
 */
 