/** 클러스터링 테이블에서 INSERT, UPDATE, DELETE가 발생하면 반드시 재정비(Reorganization)가 필요한가?
 *  
 * ㅇ 클러스터링 테이블에서 DML( INSERT, UPDATE, DELETE )의 영향
 *  1. INSERT가 클러스터링 테이블에 미치는 영향
 *		ㅁ 클러스터링 테이블은 특정 키(Clustering Key) 기준으로 같은 블록(Page)에 저장됨.
 *		ㅁ 하지만, 새로운 데이터가 들어올 때 기존 블록에 공간이 없으면 새로운 블록이 생성됨.
 *		ㅁ 결과적으로 블록 단편화(Fragmentation) 발생 가능
 *
 *	해결방법:
 *		ㅁ 주기적인 테이블 재구성 필요(특히 데이터가 지속적으로 증가할 경우)
 *		ㅁ ALTER TABLE ... MOVE 또는 REORG 수행 가능
 *		-> 쿼리: ALTER TABLE customer_orders MOVE;
 *
 *  
 */
 * */