-- ==========================================
-- 1. 마스터 테이블 (독립적인 최상위 엔티티)
-- ==========================================

CREATE TABLE CUSTOMER (
    customer_id INT NOT NULL AUTO_INCREMENT COMMENT '고객 고유 ID',
    phone_number VARCHAR(20) COMMENT '연락처',
    PRIMARY KEY (customer_id)
) COMMENT '비회원/고객 일반';

CREATE TABLE BRANCH (
    branch_id INT NOT NULL AUTO_INCREMENT COMMENT '지점 ID',
    branch_name VARCHAR(50) NOT NULL COMMENT '지점명',
    location VARCHAR(100) COMMENT '위치/주소',
    PRIMARY KEY (branch_id)
) COMMENT '지점 정보';

CREATE TABLE MENU (
    menu_id INT NOT NULL AUTO_INCREMENT COMMENT '메뉴 ID',
    menu_name VARCHAR(50) NOT NULL COMMENT '메뉴명',
    price INT NOT NULL COMMENT '가격',
    sale_status VARCHAR(20) COMMENT '판매 상태 (품절여부 등)',
    PRIMARY KEY (menu_id)
) COMMENT '메뉴';

CREATE TABLE ITEM (
    item_id INT NOT NULL AUTO_INCREMENT COMMENT '물품 ID',
    item_name VARCHAR(50) NOT NULL COMMENT '물품명',
    PRIMARY KEY (item_id)
) COMMENT '재고 물품 (본사/지점 공통)';

CREATE TABLE PROMOTION (
    event_id INT NOT NULL AUTO_INCREMENT COMMENT '이벤트 ID',
    event_name VARCHAR(100) NOT NULL COMMENT '이벤트명',
    start_date DATE COMMENT '시작일',
    end_date DATE COMMENT '종료일',
    PRIMARY KEY (event_id)
) COMMENT '이벤트/홍보';

CREATE TABLE HQ_MANAGER (
    admin_id VARCHAR(50) NOT NULL COMMENT '관리자 ID',
    password VARCHAR(255) NOT NULL COMMENT '비밀번호',
    PRIMARY KEY (admin_id)
) COMMENT '본사 관리자';


-- ==========================================
-- 2. 1차 종속 테이블 (마스터를 1개 참조)
-- ==========================================

CREATE TABLE MEMBER (
    member_id INT NOT NULL AUTO_INCREMENT COMMENT '회원 고유 ID',
    customer_id INT NOT NULL COMMENT '고객 ID (외래키)',
    phone_number VARCHAR(20) COMMENT '연락처',
    order_count INT DEFAULT 0 COMMENT '누적 주문 횟수',
    PRIMARY KEY (member_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id) ON DELETE CASCADE
) COMMENT '회원';

CREATE TABLE BRANCH_MANAGER (
    manager_id VARCHAR(50) NOT NULL COMMENT '점주 ID',
    branch_id INT NOT NULL COMMENT '담당 지점 ID',
    PRIMARY KEY (manager_id),
    FOREIGN KEY (branch_id) REFERENCES BRANCH(branch_id)
) COMMENT '지점 관리자/점주';

CREATE TABLE KIOSK (
    kiosk_id INT NOT NULL AUTO_INCREMENT COMMENT '기기 고유 ID',
    branch_id INT NOT NULL COMMENT '소속 지점 ID',
    status VARCHAR(20) COMMENT '기기 상태 (정상, 고장 등)',
    PRIMARY KEY (kiosk_id),
    FOREIGN KEY (branch_id) REFERENCES BRANCH(branch_id)
) COMMENT '개별 키오스크 기기';

CREATE TABLE SALES (
    sales_id INT NOT NULL AUTO_INCREMENT COMMENT '매출 ID',
    branch_id INT NOT NULL COMMENT '지점 ID',
    sales_date DATE NOT NULL COMMENT '매출 일자',
    total_amount INT DEFAULT 0 COMMENT '총액',
    PRIMARY KEY (sales_id),
    FOREIGN KEY (branch_id) REFERENCES BRANCH(branch_id)
) COMMENT '매출 상세';


-- ==========================================
-- 3. 핵심 트랜잭션 및 다대다 연결 테이블
-- ==========================================

CREATE TABLE COUPON (
    coupon_id INT NOT NULL AUTO_INCREMENT COMMENT '쿠폰 ID',
    member_id INT NOT NULL COMMENT '회원 ID',
    issue_date DATE COMMENT '발급일',
    expiry_date DATE COMMENT '만료일',
    PRIMARY KEY (coupon_id),
    FOREIGN KEY (member_id) REFERENCES MEMBER(member_id)
) COMMENT '쿠폰';

-- 🔴 시스템의 정중앙 핵심 테이블
CREATE TABLE ORDERS (
    order_id INT NOT NULL AUTO_INCREMENT COMMENT '주문 번호',
    customer_id INT NOT NULL COMMENT '고객 ID',
    branch_id INT NOT NULL COMMENT '지점 ID',
    order_type VARCHAR(20) COMMENT '주문 유형 (매장/포장 등)',
    language VARCHAR(20) COMMENT '언어 설정',
    status VARCHAR(20) COMMENT '주문 상태',
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (branch_id) REFERENCES BRANCH(branch_id)
) COMMENT '주문';

CREATE TABLE ORDER_ITEM (
    order_item_id INT NOT NULL AUTO_INCREMENT COMMENT '상세 항목 ID',
    order_id INT NOT NULL COMMENT '주문 번호',
    menu_id INT NOT NULL COMMENT '메뉴 ID',
    flavor VARCHAR(30) COMMENT '맛 옵션',
    container VARCHAR(30) COMMENT '용기 옵션',
    insulation_option VARCHAR(30) COMMENT '보온/보냉 옵션',
    quantity INT DEFAULT 1 COMMENT '수량',
    PRIMARY KEY (order_item_id),
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id) ON DELETE CASCADE,
    FOREIGN KEY (menu_id) REFERENCES MENU(menu_id)
) COMMENT '주문 상세 항목';

CREATE TABLE PAYMENT (
    payment_id INT NOT NULL AUTO_INCREMENT COMMENT '결제 ID',
    order_id INT NOT NULL COMMENT '주문 번호',
    member_id INT COMMENT '회원 ID (비회원결제가능)',
    method VARCHAR(20) NOT NULL COMMENT '결제 수단',
    amount INT NOT NULL COMMENT '결제 금액',
    point_used INT DEFAULT 0 COMMENT '사용 포인트',
    point_earned INT DEFAULT 0 COMMENT '적립 포인트',
    PRIMARY KEY (payment_id),
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
    FOREIGN KEY (member_id) REFERENCES MEMBER(member_id)
) COMMENT '결제';

CREATE TABLE BRANCH_INVENTORY (
    item_id INT NOT NULL COMMENT '물품 ID',
    branch_id INT NOT NULL COMMENT '지점 ID',
    stock_level INT DEFAULT 0 COMMENT '현재 재고량',
    PRIMARY KEY (item_id, branch_id),
    FOREIGN KEY (item_id) REFERENCES ITEM(item_id),
    FOREIGN KEY (branch_id) REFERENCES BRANCH(branch_id)
) COMMENT '지점 재고';

CREATE TABLE HQ_INVENTORY (
    request_id INT NOT NULL AUTO_INCREMENT COMMENT '발주 요청 ID',
    branch_id INT NOT NULL COMMENT '요청 지점 ID',
    item_id INT NOT NULL COMMENT '물품 ID',
    approval_status VARCHAR(20) COMMENT '승인 상태',
    delivery_status VARCHAR(20) COMMENT '배송 상태',
    PRIMARY KEY (request_id),
    FOREIGN KEY (branch_id) REFERENCES BRANCH(branch_id),
    FOREIGN KEY (item_id) REFERENCES ITEM(item_id)
) COMMENT '본사 물류/재고 (발주이력)';