CREATE TABLE META_DATA
(
  meta_type   VARCHAR(50)  NOT NULL COMMENT '코드 그룹명 (ORDER_STATUS, ORDER_TYPE, PAYMENT_METHOD 등)',
  meta_code   VARCHAR(50)  NOT NULL COMMENT '코드값 (PAID, DINE_IN, CARD 등)',
  lang        VARCHAR(10)  NOT NULL DEFAULT 'ko' COMMENT '언어 코드 (ko, en, ja, zh 등)',
  label_name  VARCHAR(100) NOT NULL COMMENT '키오스크/관리자 화면에 표시될 다국어 라벨',
  price       INT          NULL     COMMENT '코드 자체에 금액이 연관된 경우(예: 포장비)에만 사용, 없으면 NULL',
  description VARCHAR(255) NULL     COMMENT '해당 코드에 대한 설명(관리자 참고용)',
  sort_order  INT          NOT NULL DEFAULT 0 COMMENT '같은 meta_type 내에서 화면 표시 순서',
  is_active   BOOLEAN      NOT NULL DEFAULT TRUE COMMENT '사용 여부(비활성 처리용)',
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
  updated_at  DATETIME     NULL     ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
  PRIMARY KEY (meta_type, meta_code, lang)
) COMMENT '공통 코드 및 다국어 라벨 메타데이터';