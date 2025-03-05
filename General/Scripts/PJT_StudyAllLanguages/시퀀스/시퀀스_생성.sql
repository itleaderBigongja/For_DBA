-- 유저정보(시퀀스 생성)
CREATE SEQUENCE SEQ_USER_INFO
    START WITH 1001           -- 시작값을 1001로 설정
    INCREMENT BY 1            -- 1씩 증가
    MAXVALUE 9999999          -- 최대값 설정
    MINVALUE 1000             -- 최소값 설정
    NOCYCLE                   -- 최대값 도달 시 다시 돌아가지 않음
    CACHE 1000                -- 1000개 미리 할당하여 성능 최적화
    ORDER;                    -- RAC 환경에서 순서 보장

-- 유저주소이력(시퀀스 생성)
CREATE SEQUENCE SEQ_USER_ADDR_HST
    START WITH 1001           -- 시작값을 1001로 설정
    INCREMENT BY 1            -- 1씩 증가
    MAXVALUE 9999999          -- 최대값 설정
    MINVALUE 1000             -- 최소값 설정
    NOCYCLE                   -- 최대값 도달 시 다시 돌아가지 않음
    CACHE 1000                -- 1000개 미리 할당하여 성능 최적화
    ORDER;                    -- RAC 환경에서 순서 보장
    
-- 다국어적재(시퀀스 생성)
CREATE SEQUENCE SEQ_LANGUAGES_LOAD
	START WITH 1001			  -- 시작값을 1001로 설정
	INCREMENT BY 1			  -- 1씩 증가
	MAXVALUE 9999999		  -- 최대값 설정
	MINVALUE 1000			  -- 최소값 설정
	NOCYCLE					  -- 최대값 도달 시 다시 돌아가지 않음
	CACHE 1000				  -- 1000개 미리 할당하여 성능 최적화
	ORDER;					  -- RAC 환경에서 순서 보장
	
-- 전송작업(시퀀스 생성)
CREATE SEQUENCE SEQ_TRANSFER_TASK
	START WITH 1001			  -- 시작값을 1001로 설정
	INCREMENT BY 1			  -- 1씩 증가
	MAXVALUE 9999999		  -- 최대값 설정
	MINVALUE 1000			  -- 최소값 설정
	NOCYCLE					  -- 최대값 도달 시 다시 돌아가지 않음
	CACHE 1000				  -- 1000개 미리 할당해서 성능 최적화
	ORDER;					  -- RAC 환경에서 순서 보장
	
-- 전송작업로그(시퀀스 생성)
CREATE SEQUENCE SEQ_TRANSFER_TASK_LOG
	START WITH 1001			  -- 시작값을 1001로 설정
	INCREMENT BY 1			  -- 1씩 증가
	MAXVALUE 9999999	      -- 최대값 설정
	MINVALUE 1000			  -- 최소값 설정
	NOCYCLE					  -- 최대값 도달 시 다시 돌아가지 않음
	CACHE 1000				  -- 1000개 미리 할당해서 성능 최적화
	ORDER;					  -- RAC 환경에서 순서 보장
	
SELECT * FROM ALL_SEQUENCES WHERE SEQUENCE_OWNER = 'BIGONGJA';
