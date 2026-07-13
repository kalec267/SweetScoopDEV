-- 기존 DB가 있다면 깔끔하게 지우고 다시 생성
DROP DATABASE IF EXISTS sweetscoop;
CREATE DATABASE sweetscoop DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE sweetscoop;

-- 외래 키 제약 조건 검사 임시 해제
SET FOREIGN_KEY_CHECKS = 0;

-- =========================================================
-- [1. 상품 및 레시피 도메인] 
-- =========================================================
CREATE TABLE CATEGORY (
  id          INT         NOT NULL AUTO_INCREMENT COMMENT '카테고리 ID',
  name        VARCHAR(30) NOT NULL COMMENT '카테고리명(아이스크림,커피,아이스모찌 등)',
  PRIMARY KEY (id)
) COMMENT '카테고리';

CREATE TABLE CUP (
  id                INT         NOT NULL AUTO_INCREMENT COMMENT '컵 ID',
  name              VARCHAR(30) NOT NULL COMMENT '형태 명칭(컵,콘,와플 등)',
  additional_price INT         NOT NULL DEFAULT 0 COMMENT '컵 선택 시 추가 금액',
  PRIMARY KEY (id)
) COMMENT '제공 타입(컵/콘)';

CREATE TABLE SIZE (
  id             INT         NOT NULL AUTO_INCREMENT COMMENT '사이즈 ID',
  category_id    INT         NOT NULL COMMENT '카테고리 ID',
  name           VARCHAR(50) NOT NULL COMMENT '사이즈명(싱글,파인트 등)',
  flavor_cnt     INT         NOT NULL COMMENT '선택 가능 맛 갯수',
  price          INT         NOT NULL COMMENT '사이즈 가격',
  total_weight_g INT         NOT NULL COMMENT '해당 사이즈 총 제공 중량(g)',
  size_img VARCHAR(200) NULL COMMENT '사이즈 이미지 경로',
  PRIMARY KEY (id)
) COMMENT '상품 사이즈 규격';

CREATE TABLE MENU (
  id          INT          NOT NULL AUTO_INCREMENT COMMENT '메뉴 ID',
  category_id INT          NOT NULL COMMENT '카테고리 ID',
  item_id INT NOT NULL COMMENT '물류 ID',
  name        VARCHAR(30)  NOT NULL COMMENT '메뉴/맛 이름(엄마는 외계인 등)',
  menu_img    VARCHAR(500) NULL     COMMENT '메뉴 이미지 경로',
  PRIMARY KEY (id)
) COMMENT '판매용 메뉴 (전시용)';

CREATE TABLE MENU_OPTION (
  id          INT         NOT NULL AUTO_INCREMENT COMMENT '옵션 ID',
  category_id INT         NOT NULL COMMENT '카테고리 ID',
  name        VARCHAR(30) NOT NULL COMMENT '옵션 명칭',
  price       INT         NOT NULL COMMENT '옵션 추가 가격',
  is_active   BOOLEAN     NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id)
) COMMENT '선택형 옵션(토핑 등)';

CREATE TABLE ITEM (
  id          INT         NOT NULL AUTO_INCREMENT COMMENT '물품 ID',
  category_id INT         NOT NULL COMMENT '카테고리 ID',
  unit        INT         NOT NULL COMMENT '통/박스 단위(입고 기준)',
  item_name   VARCHAR(50) NOT NULL COMMENT '물류용 실물품명',
  PRIMARY KEY (id)
) COMMENT '실제 물류/재고 원자재';

CREATE TABLE MENU_BOM (
  menu_id     INT    NOT NULL COMMENT '메뉴 ID',
  item_id     INT    NOT NULL COMMENT '소모될 실제 물품(재고) ID',
  usage_ratio DOUBLE DEFAULT 1.0 COMMENT '소모 비율 (기본 1.0)',
  PRIMARY KEY (menu_id, item_id)
) COMMENT '메뉴별 소모 재고 매핑(BOM/레시피)';

-- =========================================================
-- [2. 매장, 기기 및 물류 도메인]
-- =========================================================
CREATE TABLE BRANCH (
  id          INT          NOT NULL AUTO_INCREMENT COMMENT '지점 ID',
  branch_name VARCHAR(50)  NOT NULL COMMENT '지점명',
  location    VARCHAR(100) NULL     COMMENT '위치/주소',
  PRIMARY KEY (id)
) COMMENT '지점 정보';

CREATE TABLE KIOSK (
  id        INT         NOT NULL AUTO_INCREMENT COMMENT '기기 고유 ID',
  branch_id INT         NOT NULL COMMENT '소속 지점 ID',
  status    VARCHAR(20) NOT NULL COMMENT '기기 상태 (정상, 고장 등)',
  PRIMARY KEY (id)
) COMMENT '개별 키오스크 기기';

CREATE TABLE BRANCHMANAGER (
  id        VARCHAR(50) NOT NULL COMMENT '점주 ID',
  branch_id INT         NOT NULL COMMENT '담당 지점 ID',
  PRIMARY KEY (id)
) COMMENT '지점 관리자/점주';

CREATE TABLE HQMANAGER (
  id   VARCHAR(50) NOT NULL COMMENT '관리자 ID',
  name VARCHAR(50) NOT NULL COMMENT '관리자 이름',
  PRIMARY KEY (id)
) COMMENT '본사 관리자 (기본 정보)';

CREATE TABLE BRANCHINVENTORY (
  item_id     INT NOT NULL COMMENT '물품 ID',
  branch_id   INT NOT NULL COMMENT '지점 ID',
  stock_level INT NULL DEFAULT 0 COMMENT '현재 재고량 (단위: g 등)',
  PRIMARY KEY (item_id, branch_id)
) COMMENT '지점별 실시간 재고';

CREATE TABLE HQINVENTORY (
  id                INT         NOT NULL AUTO_INCREMENT COMMENT '발주 요청 ID',
  branch_id         INT         NOT NULL COMMENT '요청 지점 ID',
  item_id           INT         NOT NULL COMMENT '물품 ID',
  hqManager_id      VARCHAR(50) NULL     COMMENT '승인 담당 관리자 ID',
  approval_status   VARCHAR(20) NULL     COMMENT '승인 상태',
  delivery_status   VARCHAR(20) NULL     COMMENT '배송 상태',
  request_quantity  INT         NOT NULL COMMENT '요청 수량',
  PRIMARY KEY (id)
) COMMENT '본사-지점 간 발주/물류 이력';

-- =========================================================
-- [3. 고객 및 혜택 도메인]
-- =========================================================
CREATE TABLE CUSTOMER (
  id            INT         NOT NULL AUTO_INCREMENT COMMENT '고객 고유 ID',
  customer_type VARCHAR(50) NULL     COMMENT '비회원/회원 구분 플래그',
  PRIMARY KEY (id)
) COMMENT '고객 일반 (회원/비회원 공통)';

CREATE TABLE MEMBER (
  id           INT         NOT NULL AUTO_INCREMENT COMMENT '회원 고유 ID',
  customer_id  INT         NOT NULL COMMENT '고객 ID',
  phone_number VARCHAR(20) NULL     COMMENT '연락처',
  order_count  INT         NULL     DEFAULT 0 COMMENT '누적 주문 횟수',
  point        INT         NULL     DEFAULT 0 COMMENT '적립금',
  created_at   DATETIME    NULL     COMMENT '회원 생성일시',
  PRIMARY KEY (id)
) COMMENT '회원 상세 정보';

CREATE TABLE COUPON (
  id             INT         NOT NULL AUTO_INCREMENT COMMENT '쿠폰 ID',
  member_id      INT         NOT NULL COMMENT '회원 ID',
  name           VARCHAR(50) NOT NULL COMMENT '쿠폰명', 
  issue_date     DATETIME    NULL     COMMENT '발급일시',
  expiry_date    DATETIME    NULL     COMMENT '만료일시',
  discount_value DOUBLE      NULL     COMMENT '할인 비율/금액',
  is_used        BOOLEAN     NULL     DEFAULT FALSE COMMENT '사용 여부',
  used_at        DATETIME    NULL     COMMENT '사용 완료 일시',
  PRIMARY KEY (id)
) COMMENT '발급 쿠폰 이력';

CREATE TABLE PROMOTION (
  id         INT          NOT NULL AUTO_INCREMENT COMMENT '이벤트 ID',
  event_name VARCHAR(100) NOT NULL COMMENT '이벤트명',
  start_date DATE         NULL     COMMENT '시작일',
  end_date   DATE         NULL     COMMENT '종료일',
  start_time DATETIME     NULL     COMMENT '해피아워 시작시간',
  end_time   DATETIME     NULL     COMMENT '해피아워 종료시간',
  PRIMARY KEY (id)
) COMMENT '이벤트/홍보';

-- =========================================================
-- [4. 주문 및 결제 도메인]
-- =========================================================
CREATE TABLE ORDERS (
  id          INT         NOT NULL AUTO_INCREMENT COMMENT '주문 번호',
  customer_id INT         NOT NULL COMMENT '고객 ID (비회원 포함)',
  branch_id   INT         NOT NULL COMMENT '지점 ID',
  kiosk_id    INT         NOT NULL COMMENT '주문 발생 기기 ID',
  order_type  VARCHAR(20) NOT NULL COMMENT '유형 (매장/포장 등)',
  language    VARCHAR(20) NOT NULL COMMENT '언어 설정',
  status      VARCHAR(20) NOT NULL COMMENT '주문 상태(결제완료/준비중/완료)',
  created_at  DATETIME    NOT NULL COMMENT '주문 발생 시각',
  waiting_no  INT         NULL     COMMENT '고객 호출 번호',
  receipt_no  VARCHAR(50) NOT NULL COMMENT '영수증 발급 번호',
  total_price INT         NOT NULL COMMENT '총 주문 금액',
  coupon_used BOOLEAN     NULL     DEFAULT FALSE COMMENT '쿠폰 사용 여부',
  PRIMARY KEY (id)
) COMMENT '통합 주문 내역';

CREATE TABLE ORDERITEM (
  id          INT NOT NULL AUTO_INCREMENT COMMENT '상세 주문 ID',
  order_id    INT NOT NULL COMMENT '소속 주문 번호',
  cup_id      INT NOT NULL COMMENT '선택 컵 ID',
  size_id     INT NOT NULL COMMENT '선택 사이즈 ID',
  quantity    INT NOT NULL DEFAULT 1 COMMENT '주문 수량',
  total_price INT NOT NULL COMMENT '옵션/컵 포함 최종 개별 금액',
  PRIMARY KEY (id)
) COMMENT '주문 상품(1개 사이즈 단위)';

CREATE TABLE ORDERITEMMENU (
  id            INT NOT NULL AUTO_INCREMENT COMMENT '선택 맛 상세 ID',
  order_item_id INT NOT NULL COMMENT '상세 주문 ID',
  menu_id       INT NOT NULL COMMENT '메뉴(맛) ID',
  PRIMARY KEY (id)
) COMMENT '주문 상품의 세부 맛 선택 내역';

CREATE TABLE ORDERITEMOPTION (
  id             INT NOT NULL AUTO_INCREMENT COMMENT '선택 옵션 상세 ID',
  order_item_id  INT NOT NULL COMMENT '상세 주문 ID',
  menu_option_id INT NOT NULL COMMENT '추가 옵션 ID',
  PRIMARY KEY (id)
) COMMENT '주문 상품의 추가 토핑/옵션 내역';

CREATE TABLE PAYMENT (
  id                INT         NOT NULL AUTO_INCREMENT COMMENT '결제 ID',
  order_id          INT         NOT NULL COMMENT '주문 번호',
  coupon_id         INT         NULL     COMMENT '쿠폰 ID',
  method            VARCHAR(20) NOT NULL COMMENT '결제 수단',
  amount            INT         NOT NULL COMMENT '결제 총 금액',
  card_company      VARCHAR(30) NOT NULL COMMENT '결제 카드사',
  payment_time      DATETIME    NOT NULL COMMENT '결제 시간',
  payment_status    VARCHAR(30) NULL     COMMENT '상태(승인/취소/실패)',
  pg_transaction_id VARCHAR(100) NULL    COMMENT 'PG사 결제 고유 번호',
  point_used        INT         NULL     DEFAULT 0 COMMENT '사용 포인트',
  point_earned      INT         NULL     DEFAULT 0 COMMENT '적립 포인트',
  PRIMARY KEY (id)
) COMMENT '결제 승인 내역';

CREATE TABLE SALES (
  id           INT  NOT NULL AUTO_INCREMENT COMMENT '매출 ID',
  branch_id    INT  NOT NULL COMMENT '지점 ID',
  sales_date   DATE NOT NULL COMMENT '매출 일자 (일일 정산용)',
  total_amount INT  NULL     DEFAULT 0 COMMENT '총 매출액',
  PRIMARY KEY (id)
) COMMENT '일별 지점 매출 통계';

-- =========================================================
-- [5. CS, 공지사항 및 지원 도메인]
-- =========================================================
CREATE TABLE CS (
  id           INT         NOT NULL AUTO_INCREMENT COMMENT '문의 ID',
  title        VARCHAR(50) NOT NULL COMMENT '문의 제목',
  content      TEXT        NULL     COMMENT '문의 내용',
  created_at   DATETIME    NULL     COMMENT '문의일시',
  manager_id   VARCHAR(50) NOT NULL COMMENT '작성 점주 ID',
  hqManager_id VARCHAR(50) NULL     COMMENT '담당 본사 관리자 ID',
  PRIMARY KEY (id)
) COMMENT '문의게시판';

CREATE TABLE notice (
  id           INT         NOT NULL AUTO_INCREMENT COMMENT '공지 ID',
  hqmanager_id VARCHAR(50) NOT NULL COMMENT '관리자 ID',
  title        VARCHAR(50) NOT NULL COMMENT '공지 제목',
  content      TEXT        NOT NULL COMMENT '공지 내용',
  created_at   DATETIME    NOT NULL COMMENT '게시일',
  update_at    DATETIME    NOT NULL COMMENT '수정일',
  PRIMARY KEY (id)
) COMMENT '공지 게시판';

-- =========================================================
-- [6. 외래키(FOREIGN KEY) 제약조건 일괄 적용]
-- =========================================================
ALTER TABLE SIZE ADD CONSTRAINT FK_CAT_TO_SIZE FOREIGN KEY (category_id) REFERENCES CATEGORY (id);
ALTER TABLE MENU ADD CONSTRAINT FK_CAT_TO_MENU FOREIGN KEY (category_id) REFERENCES CATEGORY (id);
ALTER TABLE MENU_OPTION ADD CONSTRAINT FK_CAT_TO_OPT FOREIGN KEY (category_id) REFERENCES CATEGORY (id);
ALTER TABLE ITEM ADD CONSTRAINT FK_CAT_TO_ITEM FOREIGN KEY (category_id) REFERENCES CATEGORY (id);
ALTER TABLE MENU_BOM ADD CONSTRAINT FK_MENU_TO_BOM FOREIGN KEY (menu_id) REFERENCES MENU (id);
ALTER TABLE MENU_BOM ADD CONSTRAINT FK_ITEM_TO_BOM FOREIGN KEY (item_id) REFERENCES ITEM (id);

ALTER TABLE KIOSK ADD CONSTRAINT FK_BR_TO_KIOSK FOREIGN KEY (branch_id) REFERENCES BRANCH (id);
ALTER TABLE BRANCHMANAGER ADD CONSTRAINT FK_BR_TO_BRMGR FOREIGN KEY (branch_id) REFERENCES BRANCH (id);
ALTER TABLE BRANCHINVENTORY ADD CONSTRAINT FK_BR_TO_BRINV FOREIGN KEY (branch_id) REFERENCES BRANCH (id);
ALTER TABLE BRANCHINVENTORY ADD CONSTRAINT FK_ITEM_TO_BRINV FOREIGN KEY (item_id) REFERENCES ITEM (id);
ALTER TABLE HQINVENTORY ADD CONSTRAINT FK_ITEM_TO_HQINV FOREIGN KEY (item_id) REFERENCES ITEM (id);
ALTER TABLE HQINVENTORY ADD CONSTRAINT FK_HQMGR_TO_HQINV FOREIGN KEY (hqManager_id) REFERENCES HQMANAGER (id);
ALTER TABLE HQINVENTORY ADD CONSTRAINT FK_BR_TO_HQINV FOREIGN KEY (branch_id) REFERENCES BRANCH (id);

ALTER TABLE MEMBER ADD CONSTRAINT FK_CUST_TO_MEM FOREIGN KEY (customer_id) REFERENCES CUSTOMER (id);
ALTER TABLE COUPON ADD CONSTRAINT FK_MEM_TO_CPN FOREIGN KEY (member_id) REFERENCES MEMBER (id);

ALTER TABLE ORDERS ADD CONSTRAINT FK_CUST_TO_ORD FOREIGN KEY (customer_id) REFERENCES CUSTOMER (id);
ALTER TABLE ORDERS ADD CONSTRAINT FK_BR_TO_ORD FOREIGN KEY (branch_id) REFERENCES BRANCH (id);
ALTER TABLE ORDERS ADD CONSTRAINT FK_KIOSK_TO_ORD FOREIGN KEY (kiosk_id) REFERENCES KIOSK (id);
ALTER TABLE ORDERITEM ADD CONSTRAINT FK_ORD_TO_ORDITM FOREIGN KEY (order_id) REFERENCES ORDERS (id);
ALTER TABLE ORDERITEM ADD CONSTRAINT FK_CUP_TO_ORDITM FOREIGN KEY (cup_id) REFERENCES CUP (id);
ALTER TABLE ORDERITEM ADD CONSTRAINT FK_SIZE_TO_ORDITM FOREIGN KEY (size_id) REFERENCES SIZE (id);
ALTER TABLE ORDERITEMMENU ADD CONSTRAINT FK_ORDITM_TO_OIMENU FOREIGN KEY (order_item_id) REFERENCES ORDERITEM (id);
ALTER TABLE ORDERITEMMENU ADD CONSTRAINT FK_MENU_TO_OIMENU FOREIGN KEY (menu_id) REFERENCES MENU (id);
ALTER TABLE ORDERITEMOPTION ADD CONSTRAINT FK_ORDITM_TO_OIOPT FOREIGN KEY (order_item_id) REFERENCES ORDERITEM (id);
ALTER TABLE ORDERITEMOPTION ADD CONSTRAINT FK_OPT_TO_OIOPT FOREIGN KEY (menu_option_id) REFERENCES MENU_OPTION (id);
ALTER TABLE PAYMENT ADD CONSTRAINT FK_ORD_TO_PAY FOREIGN KEY (order_id) REFERENCES ORDERS (id);
ALTER TABLE PAYMENT ADD CONSTRAINT FK_CPN_TO_PAY FOREIGN KEY (coupon_id) REFERENCES COUPON (id);
ALTER TABLE SALES ADD CONSTRAINT FK_BR_TO_SALES FOREIGN KEY (branch_id) REFERENCES BRANCH (id);

ALTER TABLE CS ADD CONSTRAINT FK_BRMGR_TO_CS FOREIGN KEY (manager_id) REFERENCES BRANCHMANAGER (id);
ALTER TABLE CS ADD CONSTRAINT FK_HQMGR_TO_CS FOREIGN KEY (hqManager_id) REFERENCES HQMANAGER (id);
ALTER TABLE notice ADD CONSTRAINT FK_HQMGR_TO_NOTICE FOREIGN KEY (hqmanager_id) REFERENCES HQMANAGER (id);

-- =================================================================
-- [7. 데이터 삽입 (INSERT)]
-- =================================================================

-- 1. 카테고리 (1: 아이스크림, 2: 아이스모찌, 3: 음료, 4: 디저트)
INSERT INTO CATEGORY (name) VALUES 
('아이스크림'), ('아이스모찌'), ('음료'), ('디저트');

-- 2. 컵
INSERT INTO CUP (name, additional_price) VALUES 
('컵', 0), ('콘', 0), ('와플콘', 500);

-- 3. 지점
INSERT INTO BRANCH (branch_name, location) VALUES 
('스윗스쿱 강남역점', '서울시 강남구 테헤란로 1'),
('스윗스쿱 홍대점', '서울시 마포구 홍익로 10');

-- 4. 본사 관리자
INSERT INTO HQMANAGER (id, name) VALUES 
('admin_hq', '김본사'), 
('admin_sub', '이대리');

-- 5. 프로모션
INSERT INTO PROMOTION (event_name, start_date, end_date, start_time, end_time) VALUES 
('이달의 맛 500원 추가 시 더블업', '2026-07-01', '2026-07-31', '2026-07-01 10:00:00', '2026-07-31 22:00:00');

-- 6. 고객
INSERT INTO CUSTOMER (customer_type) VALUES 
('회원'), ('비회원');

-- 7. 사이즈
INSERT INTO SIZE (id, category_id, name, flavor_cnt, price, total_weight_g, size_img) VALUES 
(1, 1, '싱글 레귤러', 1, 3900, 115, '싱글레귤러.png'),
(2, 1, '싱글 킹', 1, 4700, 145, '싱글킹.png'),
(3, 1, '더블 주니어', 2, 5100, 150, '더블주니어.png'),
(4, 1, '더블 레귤러', 2, 7300, 230, '더블레귤러.png'),
(5, 1, '트리플 주니어', 3, 7200, 225, '트리플주니어.png'),

(6, 1, '파인트', 3, 9800, 336, '파인트.png'),
(7, 1, '쿼터', 4, 18500, 643, '쿼터.png'),
(8, 1, '패밀리', 5, 26000, 989, '패밀리.png'),
(9, 1, '하프갤런', 6, 31500, 1237, '하프갤런.png'),
(10, 3, '(R)', 0, 3000, 350, NULL),
(11, 3, '(L)', 0, 4000, 450, NULL);

-- 8. 물류 아이템
INSERT INTO ITEM (category_id, unit, item_name) VALUES 
(1, 1, '엄마는 외계인 튜브(1000g)'),
(1, 1, '아몬드 봉봉 튜브(1000g)'),
(1, 1, '민트 초콜릿 칩 튜브(1000g)'),
(1, 1, '두바이에서 온 엄마는 외계인(1000g)'),
(1, 1, '오레오 쿠키 앤 밀크(1000g)'),
(1, 1, '그린티(1000g)'),
(1, 1, '애플민트(1000g)'),
(1, 1, '뉴욕 치즈케이크(1000g)'),
(1, 1, '바람과 함께 사라지다(1000g)'),
(1, 1, '자모카 아몬드 훠지(1000g)'),
(1, 1, '베리베리 스트로베리(1000g)'),
(1, 1, '피스타치오 아몬드(1000g)'),

(2, 1, '아이스 모찌 소금우유(ea)'),
(2, 1, '아이스 모찌 그린티(ea)'),
(2, 1, '아이스 모찌 스트로베리(ea)'),
(2, 1, '아이스 모찌 초코바닐라(ea)'),
(2, 1, '아이스 모찌 크림치즈(ea)'),

(3, 1, '에스프레소 원두(1000g)');

-- 9. 메뉴 옵션
INSERT INTO MENU_OPTION (category_id, name, price, is_active) VALUES 
(1, '초코 코팅 추가', 500, TRUE),
(3, '샷 추가', 500, TRUE);

-- 10. 키오스크
INSERT INTO KIOSK (branch_id, status) VALUES 
(1, '정상'), (1, '정상'), (2, '정상');

-- 11. 지점 관리자
INSERT INTO BRANCHMANAGER (id, branch_id) VALUES 
('gangnam_mgr', 1), ('hongdae_mgr', 2);

-- 12. 회원 정보
INSERT INTO MEMBER (customer_id, phone_number, order_count, point, created_at) VALUES 
(1, '010-1234-5678', 5, 1500, NOW());

-- 13. 공지사항
INSERT INTO notice (hqmanager_id, title, content, created_at, update_at) VALUES 
('admin_hq', '여름 시즌 위생 관리 철저 요망', '각 지점 점주님들은 쇼케이스 온도 유지에 신경써주세요.', NOW(), NOW());

-- 14. 판매용 메뉴
INSERT INTO MENU (category_id, item_id, name, menu_img) VALUES 
(1,1,'엄마는 외계인', 'https://www.baskinrobbins.co.kr/upload/product/main/91c8668227bcf556c43a968b97e342e6.png'),
(1,2, '아몬드 봉봉', 'https://www.baskinrobbins.co.kr/upload/product/main/e7cb5667c3147ddb0b31e28d1f365980.png'),
(1,3, '민트 초콜릿 칩', 'https://www.baskinrobbins.co.kr/upload/product/main/fb92d70dee836652115c4f3b13175541.png'),
(1,4, '두바이에서 온 엄마는 외계인', 'https://www.baskinrobbins.co.kr/upload/product/main/60b01f68d496cc0ce0ba1709dbd83cd8.png'),
(1,5, '오레오 쿠키 앤 밀크', 'https://www.baskinrobbins.co.kr/upload/product/main/f86820f7c16ffeaa77e75d8c9d71a487.png'),
(1,6, '그린티', 'https://www.baskinrobbins.co.kr/upload/product/main/8442bc93873c58520f38a113a86effd4.png'),
(1,7, '애플민트', 'https://www.baskinrobbins.co.kr/upload/product/main/269b34eb3367108169b7eac45df01471.png'),
(1,8, '뉴욕 치즈케이크', 'https://www.baskinrobbins.co.kr/upload/product/main/60a04a3a5d1b0119f065d12ee7797b2c.png'),
(1,9, '바람과 함께 사라지다', 'https://www.baskinrobbins.co.kr/upload/product/main/01ecc320f5d3a6f32e5188eda373842d.png'),
(1,10, '자모카 아몬드 훠지', 'https://www.baskinrobbins.co.kr/upload/product/main/f31388da0371388c2086a7c90990a097.png'),
(1,11, '베리베리 스트로베리', 'https://www.baskinrobbins.co.kr/upload/product/main/ea6608b4f72563b360da5c44c946ddc7.png'),
(1,12, '피스타치오 아몬드', 'https://www.baskinrobbins.co.kr/upload/product/main/868364b0ed6038d0c9aee0a10e50d4a9.png'),

(2,13, '아이스 모찌 소금우유', 'https://www.baskinrobbins.co.kr/upload/product/main/c976f291579a446b8f56a9aca7c9274d.png'),
(2,14, '아이스 모찌 그린티', 'https://www.baskinrobbins.co.kr/upload/product/main/866935365b96c08934b33be614fcf724.png'),
(2,15, '아이스 모찌 스트로베리', 'https://www.baskinrobbins.co.kr/upload/product/main/bc2b065ccd40e0fb0fad9daa82fb2334.png'),
(2,16, '아이스 모찌 초코바닐라', 'https://www.baskinrobbins.co.kr/upload/product/main/ed9b0e2804f9e304d29df56df631d3d2.png'),
(2,17, '아이스 모찌 크림치즈', 'https://www.baskinrobbins.co.kr/upload/product/main/8a82b571539d4fcfbd77f95ab2cd7095.png'),

(3,18, '아메리카노', 'https://www.baskinrobbins.co.kr/upload/product/main/71cdac7da36c6b86f558809d55fa89d7.png'),
(3,18, '초코 스모어 라떼', 'https://www.baskinrobbins.co.kr/upload/product/main/f170b4f4f2e26203a86e3d98c0dbe674.png'),
(3,18, '엄마는 외계인 카페모카', 'https://www.baskinrobbins.co.kr/upload/product/main/e0cf14f4875c051361d0551257f15d95.png'),
(3,18, '아포가토 라떼', 'https://www.baskinrobbins.co.kr/upload/product/main/b87fa403b37c6ae08c515b6802a6b1f6.png'),
(3,18, '슈가밤 커피', 'https://www.baskinrobbins.co.kr/upload/product/main/c7ba28249f196d9c002d6c459cb4b7a1.png');

-- 15. 메뉴 BOM
INSERT INTO MENU_BOM (menu_id, item_id, usage_ratio) VALUES 
(1, 1, 1.0), (2, 2, 1.0), (3, 3, 1.0), (4, 4, 1.0);

-- 16. 지점 재고
INSERT INTO BRANCHINVENTORY (branch_id, item_id, stock_level) VALUES 
(1, 1, 10000), (1, 2, 8500), (1, 3, 12000), (1, 4, 1000);

-- 17. 본사 발주 이력
INSERT INTO HQINVENTORY (branch_id, item_id, hqManager_id, approval_status, delivery_status, request_quantity) VALUES 
(1, 1, 'admin_sub', '승인완료', '배송중', 5);

-- 18. CS 게시판
INSERT INTO CS (title, content, created_at, manager_id, hqManager_id) VALUES 
('키오스크 1번 영수증 용지 부족', '영수증 용지 1박스 추가 발주 부탁드립니다.', NOW(), 'gangnam_mgr', 'admin_hq');

-- 19. 쿠폰 발급
INSERT INTO COUPON (member_id, name, issue_date, expiry_date, discount_value, is_used) VALUES 
(1, '가입 축하 2000원 할인쿠폰', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 2000, FALSE);

-- 20. 주문 마스터
INSERT INTO ORDERS (customer_id, branch_id, kiosk_id, order_type, language, status, created_at, waiting_no, receipt_no, total_price, coupon_used) VALUES 
(1, 1, 1, '포장', 'KOR', '결제완료', NOW(), 101, 'R-20260710-0001', 9800, TRUE);

-- 21. 주문 상세
INSERT INTO ORDERITEM (order_id, cup_id, size_id, quantity, total_price) VALUES 
(1, 1, 3, 1, 9800);

-- 22. 결제
INSERT INTO PAYMENT (order_id, coupon_id, method, amount, card_company, payment_time, payment_status, pg_transaction_id, point_used, point_earned) VALUES 
(1, 1, '신용카드', 7800, '신한카드', NOW(), '승인', 'PG-0987654321', 0, 390);

-- 23. 매출
INSERT INTO SALES (branch_id, sales_date, total_amount) VALUES 
(1, CURDATE(), 9800);

-- 24. 주문 맛 선택 내역
INSERT INTO ORDERITEMMENU (order_item_id, menu_id) VALUES 
(1, 1), (1, 2), (1, 3);

-- 25. 주문 옵션 선택 내역
INSERT INTO ORDERITEMOPTION (order_item_id, menu_option_id) VALUES 
(1, 1);

-- 외래 키 제약 조건 검사 재활성화
SET FOREIGN_KEY_CHECKS = 1;