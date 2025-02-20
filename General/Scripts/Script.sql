/** 
 *   ㅇ CASCADE 옵션: 해당 유저가 소유한 모든 객체(테이블, 인덱스, 시퀀스 등)을 함께 삭제
 *   ㅇ 주의사항: 해당 유저의 데이터가 모두 삭제되므로, 실제 운영 환경에서는 신중하게 수행해야 함.
 *   ㅇ 대체 방법: 특정 객체만 삭제하려면 DROP TABLE, DROP INDEX 등을 개별 실행 
 ** /
-- 유저 삭제
DROP USER BIGONGJA CASCADE;

-- 테이블 삭제
DROP TABLE CUSTOMER_ORDERS;
DROP TABLE TEMP_TABLE;

/**
 *  ㅇ CASCADE CONSTRAINTS 옵션: 이 테이블이 참조하는 외래 키(FK)도 함께 삭제
 **/
-- 클러스터링 테이블을 삭제할 경우
DROP TABLE CUSTOMER_ORDERS CASCADE CONSTRAINTS;
DROP TABLE TEMP_TABLE CASCADE CONSTRAINTS;

-- 인덱스 삭제
DROP INDEX IDX_CUSTOMER_ORDERS;
DROP INDEX IDX_TEMP_TABLE;

/**
 *  ㅇ INCLUDING TABLES 옵션: 해당 클러스터에 속한 모든 테이블을 함께 삭제
 *  ㅇ CASCADE CONSTRAINTS 옵션: 외래 키(FK) 관계도 함께 삭제
 *  ㅇ 클러스터를 삭제하면 클러스터 내부의 데이터 및 인덱스도 함게 삭제됨
 **/
-- 클러스터 삭제
DROP CLUSTER CUSTOMER_ORDERS_CLUSTER INCLUDING TABLES CASCADE CONSTRAINTS;

