-- =========================================================
-- [1. 상품 및 레시피 도메인] 
-- 아이스크림, 컵, 사이즈, 옵션, 재고 원자재 및 BOM(레시피)
-- =========================================================

CREATE TABLE CATEGORY (
  id          INT         NOT NULL COMMENT '카테고리 ID',
  name        VARCHAR(30) NOT NULL COMMENT '카테고리명(아이스크림,커피,아이스모찌 등)',
  PRIMARY KEY (id)
) COMMENT '카테고리';

CREATE TABLE CUP (
  id               INT         NOT NULL COMMENT '컵 ID',
  name             VARCHAR(30) NOT NULL COMMENT '형태 명칭(컵,콘,와플 등)',
  additional_price INT         NOT NULL DEFAULT 0 COMMENT '컵 선택 시 추가 금액',
  PRIMARY KEY (id)
) COMMENT '제공 타입(컵/콘)';

CREATE TABLE SIZE (
  id             INT         NOT NULL AUTO_INCREMENT COMMENT '사이즈 ID',
  category_id    INT         NOT NULL COMMENT '카테고리 ID',
  name           VARCHAR(50) NOT NULL COMMENT '사이즈명(싱글,파인트 등)',
  flavor_cnt     INT         NOT NULL COMMENT '선택 가능 맛 갯수',
  price          INT         NOT NULL COMMENT '사이즈 가격',
  total_weight_g INT         NOT NULL COMMENT '해당 사이즈 총 제공 중량(g) - 재고 차감 기준',
  PRIMARY KEY (id)
) COMMENT '상품 사이즈 규격';

CREATE TABLE MENU (
  id          INT         NOT NULL COMMENT '메뉴 ID',
  category_id INT         NOT NULL COMMENT '카테고리 ID',
  name        VARCHAR(30) NULL     COMMENT '메뉴/맛 이름(엄마는 외계인 등)',
  PRIMARY KEY (id)
) COMMENT '판매용 메뉴 (전시용)';

CREATE TABLE MENU_OPTION (
  id          INT         NOT NULL COMMENT '옵션 ID',
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
-- 지점, 키오스크, 지점/본사 관리자 및 재고 관리
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
  id          VARCHAR(50) NOT NULL COMMENT '관리자 ID',
  name        VARCHAR(50) NOT NULL COMMENT '관리자 이름',
  PRIMARY KEY (id)
) COMMENT '본사 관리자 (기본 정보)';

CREATE TABLE BRANCHINVENTORY (
  item_id     INT NOT NULL COMMENT '물품 ID',
  branch_id   INT NOT NULL COMMENT '지점 ID',
  stock_level INT NULL DEFAULT 0 COMMENT '현재 재고량 (단위: g 등)',
  PRIMARY KEY (item_id, branch_id)
) COMMENT '지점별 실시간 재고';

CREATE TABLE HQINVENTORY (
  id               INT         NOT NULL AUTO_INCREMENT COMMENT '발주 요청 ID',
  branch_id        INT         NOT NULL COMMENT '요청 지점 ID',
  item_id          INT         NOT NULL COMMENT '물품 ID',
  hqManager_id     VARCHAR(50) NULL     COMMENT '승인 담당 관리자 ID',
  approval_status  VARCHAR(20) NULL     COMMENT '승인 상태',
  delivery_status  VARCHAR(20) NULL     COMMENT '배송 상태',
  request_quantity INT         NOT NULL COMMENT '요청 수량',
  PRIMARY KEY (id)
) COMMENT '본사-지점 간 발주/물류 이력';


-- =========================================================
-- [3. 고객 및 혜택 도메인]
-- 비회원/회원, 쿠폰, 프로모션
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
  PRIMARY KEY (id)
) COMMENT '이벤트/홍보';


-- =========================================================
-- [4. 주문 및 결제 도메인]
-- 주문 마스터, 상세 상품, 선택 맛/옵션, 결제 및 매출 통계
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
  id                INT          NOT NULL AUTO_INCREMENT COMMENT '결제 ID',
  order_id          INT          NOT NULL COMMENT '주문 번호',
  method            VARCHAR(20)  NOT NULL COMMENT '결제 수단',
  amount            INT          NOT NULL COMMENT '결제 총 금액',
  card_company      VARCHAR(30)  NOT NULL COMMENT '결제 카드사',
  payment_time      DATETIME     NOT NULL COMMENT '결제 시간',
  payment_status    VARCHAR(30)  NULL     COMMENT '상태(승인/취소/실패)',
  pg_transaction_id VARCHAR(100) NULL     COMMENT 'PG사 결제 고유 번호',
  point_used        INT          NULL     DEFAULT 0 COMMENT '사용 포인트',
  point_earned      INT          NULL     DEFAULT 0 COMMENT '적립 포인트',
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
-- [5. CS 및 지원 도메인]
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


-- =========================================================
-- [6. 외래키(FOREIGN KEY) 제약조건 일괄 적용]
-- 생성 순서에 따른 오류 방지를 위해 하단에 배치하며 도메인별로 묶음
-- =========================================================

-- 상품/레시피 관련 관계
ALTER TABLE SIZE ADD CONSTRAINT FK_CAT_TO_SIZE FOREIGN KEY (category_id) REFERENCES CATEGORY (id);
ALTER TABLE MENU ADD CONSTRAINT FK_CAT_TO_MENU FOREIGN KEY (category_id) REFERENCES CATEGORY (id);
ALTER TABLE MENU_OPTION ADD CONSTRAINT FK_CAT_TO_OPT FOREIGN KEY (category_id) REFERENCES CATEGORY (id);
ALTER TABLE ITEM ADD CONSTRAINT FK_CAT_TO_ITEM FOREIGN KEY (category_id) REFERENCES CATEGORY (id);
ALTER TABLE MENU_BOM ADD CONSTRAINT FK_MENU_TO_BOM FOREIGN KEY (menu_id) REFERENCES MENU (id);
ALTER TABLE MENU_BOM ADD CONSTRAINT FK_ITEM_TO_BOM FOREIGN KEY (item_id) REFERENCES ITEM (id);

-- 매장/기기/물류 관련 관계
ALTER TABLE KIOSK ADD CONSTRAINT FK_BR_TO_KIOSK FOREIGN KEY (branch_id) REFERENCES BRANCH (id);
ALTER TABLE BRANCHMANAGER ADD CONSTRAINT FK_BR_TO_BRMGR FOREIGN KEY (branch_id) REFERENCES BRANCH (id);
ALTER TABLE BRANCHINVENTORY ADD CONSTRAINT FK_BR_TO_BRINV FOREIGN KEY (branch_id) REFERENCES BRANCH (id);
ALTER TABLE BRANCHINVENTORY ADD CONSTRAINT FK_ITEM_TO_BRINV FOREIGN KEY (item_id) REFERENCES ITEM (id);
ALTER TABLE HQINVENTORY ADD CONSTRAINT FK_ITEM_TO_HQINV FOREIGN KEY (item_id) REFERENCES ITEM (id);
ALTER TABLE HQINVENTORY ADD CONSTRAINT FK_HQMGR_TO_HQINV FOREIGN KEY (hqManager_id) REFERENCES HQMANAGER (id);
ALTER TABLE HQINVENTORY ADD CONSTRAINT FK_BR_TO_HQINV FOREIGN KEY (branch_id) REFERENCES BRANCH (id);

-- 회원/고객 관련 관계
ALTER TABLE MEMBER ADD CONSTRAINT FK_CUST_TO_MEM FOREIGN KEY (customer_id) REFERENCES CUSTOMER (id);
ALTER TABLE COUPON ADD CONSTRAINT FK_MEM_TO_CPN FOREIGN KEY (member_id) REFERENCES MEMBER (id);

-- 주문/결제/매출 관련 관계
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
ALTER TABLE SALES ADD CONSTRAINT FK_BR_TO_SALES FOREIGN KEY (branch_id) REFERENCES BRANCH (id);

-- CS 관련 관계
ALTER TABLE CS ADD CONSTRAINT FK_BRMGR_TO_CS FOREIGN KEY (manager_id) REFERENCES BRANCHMANAGER (id);
ALTER TABLE CS ADD CONSTRAINT FK_HQMGR_TO_CS FOREIGN KEY (hqManager_id) REFERENCES HQMANAGER (id);