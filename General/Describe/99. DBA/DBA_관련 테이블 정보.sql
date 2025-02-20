
-- 1. 데이터베이스 구조 및 객체 정보:
SELECT * FROM DBA_TABLES;					/* 모든 테이블 정보( 테이블 이름, 테이블스페이스, 파티션 정보 등 ) 				*/
SELECT * FROM DBA_INDEXES;					/* 모든 인덱스 정보( 인덱스 이름, 테이블 이름, 유니크 여부 등 )					*/
SELECT * FROM DBA_VIEWS;					/* 모든 뷰 정보( 뷰 이름, 뷰 정의 쿼리 등 )									*/
SELECT * FROM DBA_SEQUENCES;				/* 모든 시퀀스 정보( 시퀀스 이름, 증가/감소 값, 최소/최대 값 등 )				*/
SELECT * FROM DBA_PROCEDURES;				/* 모든 프로시저, 함수 정보(프로시저 이름, 파라미터 정보, 소스코드 등 )				*/
SELECT * FROM DBA_TRIGGERS;					/* 모든 트리거 정보( 트리거 이름, 테이블 이름, 트리거 이벤트 등 )					*/
SELECT * FROM DBA_OBJECTS;					/* 데이터베이스 내 모든 객체 정보(객체 이름, 객체 유형, 생성/수정 시간 등)			*/
SELECT * FROM DBA_TAB_PARTITIONS;			/* 테이블 파티션 정보(파티션 이름, 파티션 범위, 테이블 스페이스 등)				*/
SELECT * FROM DBA_TAB_SUBPARTITIONS;		/* 테이블 서브 파티션 정보 												*/


-- 2. 사용자 권한 정보:
SELECT * FROM DBA_USERS;					/* 모든 사용자 계정 정보(계정 이름, 생성 날짜, 잠금 여부, 기본 테이블스페이스 등)		*/
SELECT * FROM DBA_ROLES;					/* 모든 롤 정보( 롤 이름, 롤 ID 등 )										*/
SELECT * FROM DBA_SYS_PRIVS;				/* 사용자 또는 롤에 부여된 시스템 권한 정보									*/
SELECT * FROM DBA_TAB_PRIVS;				/* 테이블 또는 뷰에 대한 객체 권한 정보										*/
SELECT * FROM DBA_ROLE_PRIVS;				/* 롤에 부여된 다른 룰 정보												*/


-- 3. 성능 및 통계 정보:
SELECT * FROM DBA_HIST_SYSSTAT;				/* 시스템 통계 정보( CPU 사용량, I/O 통계 등, 과거 정보 )						*/
SELECT * FROM DBA_HIST_SYSMETRIC_SUMMARY;	/* 시스템 매트릭 요약 정보( CPU 사용률, 메모리 사용률 등, 과거 정보 )				*/
SELECT * FROM DBA_HIST_SQLSTAT;				/* SQL 실행 통계 정보( SQL ID, 실행 횟수, CPU 시간, I/O 횟수 등, 과거 정보 )	*/
SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY;	/* 활성 세션 히스토리 정보( 세션 ID, SQL ID, 이벤트, 대기 시간 등, 과거 정보 )	*/
SELECT * FROM V$SESSION;					/* 현재 활성 세션 정보													*/
SELECT * FROM V$SQL;						/* 현재 실행 중인 SQL 정보												*/
SELECT * FROM DBA_DATA_FILES;				/* 데이터 파일 정보( 파일 이름, 크기, 테이블스페이스 등)						*/
SELECT * FROM DBA_FREE_SPACE;				/* 테이블 스페이스 여유 공간 확보											*/


-- 4. 감사 정보:
SELECT * FROM DBA_AUDIT_TRAIL;				/* 감사 로그 정보(사용자, 객체, 작업, 시간 등) [감사 기능 활성화 필요]				*/
SELECT * FROM DBA_STMT_AUDIT_OPTS;			/* SQL 문 감사 옵션 													*/
SELECT * FROM DBA_PRIV_AUDIT_OPTS;			/* 권한 감사 옵션														*/
SELECT * FROM DBA_OBJ_AUDIT_OPTS;			/* 객체 감사 옵션														*/


-- 5. 리소스 관리(Resource Manager 정보)
SELECT * FROM DBA_RSRC_PLANS;				/* 리소스 플랜 정보														*/
SELECT * FROM DBA_RSRC_CONSUMER_GROUPS;		/* 리소스 소비자 그룹 정보												*/
SELECT * FROM DBA_RSRC_PLAN_DIRECTIVES;		/* 리소스 플랜 지시사항 정보												*/


-- 6. Data Guard 정보
SELECT * FROM V$DATABASE;					/* 데이터베이스 정보( DBID, 이름, 역할 )									*/
SELECT * FROM V$STANDBY_LOG;				/* Standby Redo LOG 파일 정보											*/					*/


-- 7. 테이블스페이스 정보 조회
SELECT * FROM DBA_TABLESPACES;				/* 테이블스페이스의 전체 목록 및 속성										*/
SELECT * FROM DBA_DATA_FILES;				/* 테이블스페이스에 속한 데이터 파일 정보										*/
SELECT * FROM DBA_FREE_SPACE;				/* 테이블스페이스 내의 사용되지 않은 공간										*/


-- 8. 데이터 파일 정보 조회
SELECT * FROM DBA_DATA_FILES;				/* 데이터 파일의 물리적 정보												*/
SELECT * FROM DBA_TEMP_FILES;				/* 임시 테이블스페이스의 데이터 파일 정보										*/


-- 9. 세그먼트 정보 조회
SELECT * FROM DBA_SEGMENTS;					/* 테이블, 인덱스 등 세그먼트 정보											*/
SELECT * FROM DBA_EXTENTS;					/* 특정 세그먼트가 사용하는 익스텐트 정보										*/
SELECT * FROM DBA_LOBS;						/* LOB 데이터가 저장된 세그먼트 정보										*/


-- 10. 익스텐트 정보 조회
SELECT * FROM DBA_EXTENTS;					/* 세그먼트가 할당받은 익스텐트 정보											*/


-- 11. 블록 정보 조회
SELECT * FROM DBA_FREE_SPACE;				/* 사용가능한 블록 정보													*/
SELECT * FROM DBA_EXTENTS;					/* 익스텐트에 포함된 블록 정보												*/

