BEGIN;

CREATE SCHEMA IF NOT EXISTS nolbir_flutter;
SET search_path TO nolbir_flutter;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA nolbir_flutter;
CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA nolbir_flutter;

-- Sistemin Log gecmisini tutar
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id TEXT NOT NULL,
    action TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_record ON audit_logs(table_name, record_id);

-- Sistemin gecerli para birimlerinin anlik aktivlik kaydini tutar
CREATE TABLE IF NOT EXISTS supported_currencies (
    currency_code SMALLINT PRIMARY KEY,-- 'SAP':0, 'USD':1,'EUR':2,'TRY':3, 'TMM':4
    currency_name VARCHAR(50) NOT NULL,
    decimal_places SMALLINT NOT NULL DEFAULT 2 CHECK (decimal_places BETWEEN 0 AND 8),
    wallet_columns_provisioned BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,-- pasif = whitelist'te ama işlem kabul etmiyor (örn. geçici askıya alma)
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP);
COMMENT ON TABLE supported_currencies IS 'Sistemde işlem görebilecek para birimlerinin TEK doğruluk kaynağı. Dinamik SQL üreten her fonksiyon, kolon adını kurmadan önce buraya karşı doğrulama yapmak ZORUNDADIR.';
COMMENT ON COLUMN supported_currencies.wallet_columns_provisioned IS 'true olmadan bu para birimiyle hiçbir cüzdan hareketi yapılamaz — kolonun fiziksel olarak var olduğunun garantisidir.';

-- Ulke bazli vergi kuruluslarinin bilgilerini tutar
CREATE TABLE IF NOT EXISTS government_tax_authorities (
    id SERIAL PRIMARY KEY,
    country_code VARCHAR(3) NOT NULL,                  -- ISO 3166-1 alpha-3 ('TUR','USA','DEU' vb.)
    authority_name VARCHAR(150) NOT NULL,               -- 'Gelir İdaresi Başkanlığı', 'IRS', 'HMRC' vb.
    tax_office_code VARCHAR(50),                        -- Yerel vergi dairesi / mükellef kodu (opsiyonel referans)
    accepted_currency SMALLINT NOT NULL,             -- Bu devletin ödeme kabul ettiği para birimi
    official_iban_or_account_no VARCHAR(64),            -- Devlete ait resmi tahsilat hesabı (varsa, sadece referans)
    is_active BOOLEAN NOT NULL DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_gta_country ON government_tax_authorities(country_code);
COMMENT ON TABLE government_tax_authorities IS
 'Ülkeden bağımsız, parametrik devlet/vergi dairesi tanım tablosu. Yeni ülke = yeni satır.';

-- Ulke bazli vergi kurallarini ve miktarini tutar
CREATE TABLE IF NOT EXISTS tax_rates_and_rules (
    id SERIAL PRIMARY KEY,                       -- Maps to 30 Vertical Marketplaces
    country_code SMALLINT NOT NULL,                -- ISO 3166-1 alpha-3 (e.g., 'TUR', 'USA', 'DEU')
    tax_authority_id INTEGER REFERENCES government_tax_authorities(id) ON DELETE RESTRICT,
    state_or_region VARCHAR(50),                     -- For US states or specific tax zones
    tax_type VARCHAR(30) NOT NULL,                   -- 'VAT_KDV', 'WITHHOLDING_STOPAJ', 'STAMP_TAX', 'CORPORATE'
    category_code VARCHAR(50),                       -- Sub-category tax exemption or rate code
    tax_rate NUMERIC(5, 4) NOT NULL CHECK (tax_rate >= 0.0000 AND tax_rate <= 1.0000),
    is_withholding BOOLEAN DEFAULT FALSE,            -- If true, deducted at source during payouts
    is_active BOOLEAN DEFAULT TRUE,
    effective_from DATE NOT NULL,
    effective_until DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tax_effective_dates CHECK (effective_until IS NULL OR effective_until >= effective_from) );
CREATE INDEX IF NOT EXISTS idx_tax_lookup ON tax_rates_and_rules (country_code, tax_type, is_active);
COMMENT ON TABLE tax_rates_and_rules IS 'Jurisdiction and vertical specific tax calculation rules for automatic ledger splitting.';

-- Gercek dunya hesaplarini tutar
CREATE TABLE IF NOT EXISTS real_world_accounts (
    id SERIAL PRIMARY KEY,
    account_code VARCHAR(30) UNIQUE NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    account_type SMALLINT NOT NULL,
    bank_name VARCHAR(100),
    iban_or_account_no VARCHAR(64),
    currency SMALLINT NOT NULL,
    current_balance DECIMAL(18, 8) DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );

-- Finansal islem amacli hesap turu bilgilerini tutar
CREATE TABLE IF NOT EXISTS chart_of_accounts (
    id SERIAL PRIMARY KEY,
    account_code VARCHAR(30) UNIQUE NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    account_category SMALLINT NOT NULL, -- 0=ASSET, 1=LIABILITY, 2=EQUITY, 3=REVENUE, 4=EXPENSE
    currency SMALLINT NOT NULL,
    total_debit DECIMAL(18, 8) DEFAULT 0.00 CHECK (total_debit >= 0),
    total_credit DECIMAL(18, 8) DEFAULT 0.00 CHECK (total_credit >= 0),
    current_balance DECIMAL(18, 8) DEFAULT 0.00,
    real_world_account_id INTEGER REFERENCES real_world_accounts(id) ON DELETE RESTRICT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );

-- Ana islem gunlugu bilgilerini tutar
CREATE TABLE IF NOT EXISTS journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_number VARCHAR(50) UNIQUE NOT NULL,
    trace_id UUID NOT NULL DEFAULT gen_random_uuid(),
    journal_entri_description TEXT NOT NULL,
    reference_type VARCHAR(50), -- 'VOUCHER_BATCH', 'DIVIDEND_DISTRIBUTION', 'CASH_OUTFLOW'
    reference_id UUID,
    journal_entri_status SMALLINT DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );

-- Cift yonlu hesap kaydini tutar muhasebe islemleri
CREATE TABLE IF NOT EXISTS journal_entry_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE RESTRICT,
    account_id INTEGER NOT NULL REFERENCES chart_of_accounts(id) ON DELETE RESTRICT,
    debit_amount DECIMAL(18, 8) DEFAULT 0.00 CHECK (debit_amount >= 0),
    credit_amount DECIMAL(18, 8) DEFAULT 0.00 CHECK (credit_amount >= 0),
    currency SMALLINT NOT NULL,
    line_description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_debit_credit_mutually_exclusive CHECK (
        (debit_amount > 0 AND credit_amount = 0) OR (credit_amount > 0 AND debit_amount = 0) ) );

--  Ana kullanici bilgilerini tutar
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    user_name VARCHAR(20),
    birth_date DATE,
    nationality_country_code SMALLINT, 
    local_doc_no VARCHAR(11) UNIQUE,
    local_doc_expiry_date DATE,
    global_doc_no VARCHAR(11) UNIQUE,
    global_doc_expiry_date DATE,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_no VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255),
    digital_pin VARCHAR(255),
    provisioning_status SMALLINT DEFAULT 0,
    provisioning_error TEXT,
    gender SMALLINT,
    is_active BOOLEAN DEFAULT true,
    verified_tier SMALLINT DEFAULT 0,
    identity_verified_by_worker_id INTEGER,
    identity_verification_method SMALLINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    identity_verified_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_users_birth_date_past CHECK (birth_date IS NULL OR birth_date <= CURRENT_DATE),
    CONSTRAINT chk_users_min_age CHECK (birth_date IS NULL OR birth_date <= CURRENT_DATE - INTERVAL '18 years') );
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_lower ON users (lower(email));

-- Sistemin ilk Kurucularinin bilgilerini islem loglarini tutar
CREATE TABLE IF NOT EXISTS genesis_audit_log (
    id BIGSERIAL PRIMARY KEY,
    invoked_by_ip VARCHAR(64) NOT NULL,
    cert_fingerprint VARCHAR(128),
    action SMALLINT NOT NULL,
    target_user_id INTEGER REFERENCES users(id),
    modules_added SMALLINT[],
    success BOOLEAN NOT NULL,
    error_detail TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );

-- Sistemin tum onaylama islemleri bilgilerini tutar
CREATE TABLE IF NOT EXISTS approvals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_root_id INTEGER NOT NULL REFERENCES users(id),
    requester_role VARCHAR(20) NOT NULL,
    approval_type VARCHAR(50) NOT NULL,
    approval_status SMALLINT DEFAULT 0, -- 0=PENDING, 1=APPROVED, 2=REJECTED
    priority_score INTEGER DEFAULT 0,
    total_weight NUMERIC(10,4) NOT NULL DEFAULT 0,
    approve_weight NUMERIC(10,4) NOT NULL DEFAULT 0,
    reject_weight NUMERIC(10,4) NOT NULL DEFAULT 0,
    approval_threshold  NUMERIC(5,4)  NOT NULL DEFAULT 0.5000,
    request_data JSONB NOT NULL, 
    ai_analysis_report JSONB, 
    reviewer_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE );
CREATE INDEX IF NOT EXISTS idx_approvals_request_data_gin ON approvals USING gin (request_data);
CREATE INDEX IF NOT EXISTS idx_approvals_ai_analysis_report_gin ON approvals USING gin (ai_analysis_report);

-- Onaylama mekanizmasinda oy agirligini dondurma 
CREATE TABLE IF NOT EXISTS approval_eligible_voters (
    approval_id UUID NOT NULL REFERENCES approvals(id) ON DELETE RESTRICT,
    voter_id INTEGER NOT NULL REFERENCES users(id),
    voter_type SMALLINT NOT NULL,
    vote_weight NUMERIC(10,4) NOT NULL CHECK (vote_weight > 0),
    PRIMARY KEY (approval_id, voter_id) );

-- Onaylama icin verilen oy bilgilerini tutar
CREATE TABLE IF NOT EXISTS approval_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    approval_id UUID NOT NULL REFERENCES approvals(id) ON DELETE CASCADE,
    voter_id INTEGER NOT NULL REFERENCES users(id),            -- workers.id veya institution_shareholders.id
    voter_type SMALLINT NOT NULL,         -- 1: Kurum Ortağı (Shareholder), 2: Çalışan/Yönetici (Worker)
    vote BOOLEAN NOT NULL,                -- true = Kabul (APPROVED), false = Red (REJECTED)
    comment TEXT,                         -- Oy gerekçesi / Yorumu
    vote_weight NUMERIC(10, 4) NOT NULL DEFAULT 1.0000, -- O anki hesaplanan oy gücü/ağırlığı
    voted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_voter_per_approval UNIQUE (approval_id, voter_id),
    CONSTRAINT fk_vote_eligible FOREIGN KEY (approval_id, voter_id)
        REFERENCES approval_eligible_voters(approval_id, voter_id) );
CREATE INDEX IF NOT EXISTS idx_approval_votes_lookup ON approval_votes(approval_id, voter_id);

-- MQTT kullanicisi bilgilerini temel kullanici ile esitler 
CREATE TABLE IF NOT EXISTS mqtt_acl (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    username VARCHAR(255) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    rw INT DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_topic UNIQUE (user_id, topic) );

-- MQTT kullanicisini tanimlar 
CREATE TABLE IF NOT EXISTS mqtt_user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP );

-- Calisanlar tablosu calisma bilgilerini tutar
CREATE TABLE IF NOT EXISTS workers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    worker_name VARCHAR(20),
    is_verified BOOLEAN DEFAULT false,
    rating DECIMAL(3, 2) DEFAULT 5.00 CHECK (rating BETWEEN 0 AND 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
DO $$ BEGIN IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_users_identity_verified_by_worker'
    ) THEN ALTER TABLE users ADD CONSTRAINT fk_users_identity_verified_by_worker 
        FOREIGN KEY (identity_verified_by_worker_id) REFERENCES workers(id);
    END IF; END $$;

-- Sistemin tum media bilgilerini tutar
CREATE TABLE IF NOT EXISTS media_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    category SMALLINT NOT NULL,
    entity_type VARCHAR(50),
    entity_id VARCHAR(64),
    visibility SMALLINT NOT NULL DEFAULT 0,
    minio_bucket VARCHAR(100) NOT NULL,
    minio_object_key TEXT NOT NULL,
    transcoding_status SMALLINT DEFAULT 0,
    segment_count INTEGER,
    segment_duration_seconds INTEGER DEFAULT 6,
    thumbnail_object_key TEXT,
    duration_seconds NUMERIC(8,2),
    scan_result TEXT,
    scanned_at TIMESTAMP WITH TIME ZONE,
    transcode_error TEXT,
    mime_type VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    media_status SMALLINT NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );

-- KULLANICI/KURUM DOĞRULAMA VE DENETİM OTURUMLARI (Identity & Compliance Audit Sessions)
CREATE TABLE IF NOT EXISTS identity_verification_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    conducted_by_worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    verification_method SMALLINT NOT NULL, 
    target_verification_tier SMALLINT NOT NULL DEFAULT 3, -- Hangi seviye hedefleniyor? (Örn: 3=B1, 5=C1)
    scheduled_at TIMESTAMP WITH TIME ZONE, -- Planlanan randevu tarihi
    conducted_at TIMESTAMP WITH TIME ZONE, -- Gerçekleştiği tarih
    recording_media_id UUID REFERENCES media_assets(id) ON DELETE SET NULL,
    session_status SMALLINT NOT NULL DEFAULT 0,
    worker_notes TEXT, -- Yetkilinin denetim/doğrulama notları
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ivs_live_call_needs_recording CHECK (
        NOT (verification_method = 1 AND session_status = 1 AND recording_media_id IS NULL) ) );
CREATE INDEX IF NOT EXISTS idx_ivs_target_user ON identity_verification_sessions(target_user_id);
CREATE INDEX IF NOT EXISTS idx_ivs_worker ON identity_verification_sessions(conducted_by_worker_id);

-- ANA KURUM / ŞİRKET TABLOSU bilgilerini tutar
CREATE TABLE IF NOT EXISTS institutions (
    id SERIAL PRIMARY KEY,
    owner_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    institution_name VARCHAR(150) NOT NULL,
    tax_number VARCHAR(50) UNIQUE NOT NULL,
    tax_office VARCHAR(100),
    country_code SMALLINT NOT NULL, -- Veya ISO alpha-3 için VARCHAR(3) tercih edilebilir
    registration_number VARCHAR(50),
    incorporation_contract_media_id UUID REFERENCES media_assets(id),
    trade_registry_gazette_media_id UUID REFERENCES media_assets(id),
    is_platform_genesis BOOLEAN DEFAULT false,
    board_approval_threshold DECIMAL(5,4) NOT NULL DEFAULT 0.5000 
        CHECK (board_approval_threshold > 0 AND board_approval_threshold <= 1.0000),
    collateral_stake NUMERIC(18, 8) DEFAULT 0.0000 CHECK (collateral_stake >= 0), -- Kilitli teminat tutarı
    reputation_score NUMERIC(5, 2) DEFAULT 1.00 CHECK (reputation_score >= 0),    -- Güvenilirlik/Başarı puanı 
    is_verified BOOLEAN DEFAULT false,
    verified_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT, -- Doğrulayan platform yöneticisi/çalışanı
    is_active BOOLEAN NOT NULL DEFAULT true,
    compliance_status SMALLINT NOT NULL DEFAULT 1, -- 1: ACTIVE, 2: SUSPENDED_TEMP (Geçici dondurulan), 3: BANNED_PERMANENT (İhraç)
    suspension_reason TEXT,                       -- Şüpheli işlem / yasal inceleme gerekçesi
    suspended_at TIMESTAMP WITH TIME ZONE,        -- Dondurulma tarihi
    suspended_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT, -- Donduran yetkili
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_institutions_compliance ON institutions(compliance_status);
CREATE INDEX IF NOT EXISTS idx_institutions_tax ON institutions(tax_number);
CREATE UNIQUE INDEX IF NOT EXISTS idx_institutions_platform_genesis ON institutions((true)) WHERE is_platform_genesis;

-- Sirketlerin lisans turlerini tutar
CREATE TABLE IF NOT EXISTS institution_licenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    license_number VARCHAR(100) UNIQUE NOT NULL,
    license_type SMALLINT NOT NULL, -- Lisans Türü
    license_document_media_id UUID REFERENCES media_assets(id), -- Lisans Belgesi / PDF
    issued_by_authority VARCHAR(150), -- Lisansı Veren Resmi Kurum / Devlet Makamı
    issued_at DATE NOT NULL,
    expires_at DATE NOT NULL, -- Lisans Son Geçerlilik Tarihi
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_license_dates CHECK (expires_at > issued_at) );
CREATE INDEX IF NOT EXISTS idx_licenses_institution ON institution_licenses(institution_id);

-- Kullanici Calisan ve Kurum cuzdanlarini tutar 
CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_type SMALLINT NOT NULL, -- 1: USER, 2: INSTITUTION, 3: WORKER  
    user_id INTEGER REFERENCES users(id),
    institution_id INTEGER REFERENCES institutions(id),
    worker_id INTEGER REFERENCES workers(id),
    wallet_number VARCHAR(24) UNIQUE NOT NULL,
    currency SMALLINT NOT NULL DEFAULT 0, 
    balance DECIMAL(18, 8) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_wallet_owner CHECK (
        (user_id IS NOT NULL AND institution_id IS NULL AND worker_id IS NULL) OR
        (user_id IS NULL AND institution_id IS NOT NULL AND worker_id IS NULL) OR
        (user_id IS NULL AND institution_id IS NULL AND worker_id IS NOT NULL) ) );
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_user_currency 
    ON wallets (user_id, currency) WHERE user_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_institution_currency 
    ON wallets (institution_id, currency) WHERE institution_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_worker_currency 
    ON wallets (worker_id, currency) WHERE worker_id IS NOT NULL;

-- Finansal islem kaydinini tutar
CREATE TABLE IF NOT EXISTS transactions (
    id UUID DEFAULT gen_random_uuid(),
    trace_id UUID NOT NULL DEFAULT gen_random_uuid(), -- İşlem izleme/korelasyon ID'si (Idempotency için)
    sender_wallet_id UUID REFERENCES wallets(id) ON DELETE RESTRICT,   -- NULL ise Dış Nakit/Kupon Yükleme işlemidir
    receiver_wallet_id UUID REFERENCES wallets(id) ON DELETE RESTRICT, -- NULL ise Dışarıya Para Çıkış/Sistem İptal işlemidir
    initiated_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    amount NUMERIC(18, 8) NOT NULL CHECK (amount > 0),
    fee_amount NUMERIC(18, 8) NOT NULL DEFAULT 0.0000 CHECK (fee_amount >= 0),
    currency SMALLINT NOT NULL DEFAULT 1, -- 1: TMT, 2: USD vb.
    tx_type SMALLINT NOT NULL, 
    transaction_status SMALLINT NOT NULL DEFAULT 0, 
    transaction_metadata JSONB, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_transactions PRIMARY KEY (id, created_at),
    CONSTRAINT uk_transactions_trace_id UNIQUE (trace_id, created_at),
    CONSTRAINT chk_tx_different_wallets CHECK (
        sender_wallet_id IS DISTINCT FROM receiver_wallet_id
    ) ) PARTITION BY RANGE (created_at);
CREATE TABLE IF NOT EXISTS transactions_default 
    PARTITION OF transactions DEFAULT;
CREATE TABLE IF NOT EXISTS transactions_2026 
    PARTITION OF transactions 
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
CREATE INDEX IF NOT EXISTS idx_tx_sender ON transactions(sender_wallet_id, created_at);
CREATE INDEX IF NOT EXISTS idx_tx_receiver ON transactions(receiver_wallet_id, created_at);
CREATE INDEX IF NOT EXISTS idx_tx_user ON transactions(initiated_by_user_id, created_at);

-- Hakemlik kurallari turunu tutar
CREATE TABLE IF NOT EXISTS jurisdiction_rule_types (
    rule_code VARCHAR(50) PRIMARY KEY,    -- 'EMPLOYMENT_NOTICE', 'EMPLOYMENT_SEVERANCE', 'LEAVE_PAYOUT', 'PARTNER_EXIT_ENTITLEMENT', 'DISPUTE_PROCESS'
    rule_domain SMALLINT NOT NULL,        -- 0=ÇALIŞAN AYRILIŞI, 1=ORTAK AYRILIŞI, 2=UYUŞMAZLIK/HAKEMLİK
    description TEXT,
    parameter_schema JSONB NOT NULL  );   -- parameters alanının JSON Schema'sı

-- Hakemlik rollerini ulke bazli tutar
CREATE TABLE IF NOT EXISTS jurisdiction_rules (
    id SERIAL PRIMARY KEY,
    country_code SMALLINT NOT NULL,     
    state_or_region VARCHAR(50),
    rule_code VARCHAR(50) NOT NULL REFERENCES jurisdiction_rule_types(rule_code),
    termination_type SMALLINT,            -- opsiyonel seçici: sadece bu fesih türünde geçerli
    position_type SMALLINT,               -- opsiyonel seçici
    parameters JSONB NOT NULL CHECK (jsonb_typeof(parameters) = 'object'),
    legal_reference TEXT,                 -- kanun / madde atfı
    legal_document_media_asset_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT, -- kanun metni / resmi belge
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    effective_from DATE NOT NULL,
    effective_until DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_jr_effective_dates CHECK (effective_until IS NULL OR effective_until >= effective_from) );
CREATE INDEX IF NOT EXISTS idx_jr_lookup ON jurisdiction_rules(country_code, rule_code, is_active, effective_from);

-- Kurum ortaklarini ve sermaye katki oranlarini tutar
CREATE TABLE IF NOT EXISTS institution_shareholders (
    id SERIAL PRIMARY KEY,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    share_percentage NUMERIC(9, 8) NOT NULL CHECK (share_percentage >= 0 AND share_percentage <= 1),
    partner_type SMALLINT NOT NULL DEFAULT 0,
    board_member BOOLEAN DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    exited_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_shareholder_active_share CHECK ((is_active AND share_percentage > 0 AND exited_at IS NULL) OR
        (NOT is_active AND share_percentage = 0 AND exited_at IS NOT NULL)) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_institution_shareholder_active
    ON institution_shareholders(institution_id, user_id) WHERE is_active;
CREATE INDEX IF NOT EXISTS idx_inst_shareholders ON institution_shareholders(institution_id);

--  Calisanlarin sirketlerdeki pozisyonlarini tutar
CREATE TABLE IF NOT EXISTS worker_institution_positions (
    id SERIAL PRIMARY KEY,
    worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    position_type SMALLINT NOT NULL DEFAULT 0,
    monthly_salary DECIMAL(18, 8) DEFAULT 0.00 CHECK (monthly_salary >= 0),
    commission_rate DECIMAL(5, 4) DEFAULT 0.0000 CHECK (commission_rate >= 0 AND commission_rate <= 1.0000),
    currency SMALLINT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notice_given_at TIMESTAMP WITH TIME ZONE,      -- istifa/fesih bildirim tarihi
    ended_at TIMESTAMP WITH TIME ZONE,             -- fiilen ayrılış tarihi
    termination_type SMALLINT,                     -- enum_termination_type: istifa, işten çıkarma, karşılıklı fesih, sözleşme sonu
    terminated_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    termination_reason TEXT,
    CONSTRAINT chk_wip_termination CHECK ((is_active AND ended_at IS NULL AND termination_type IS NULL) OR
        (NOT is_active AND ended_at IS NOT NULL AND termination_type IS NOT NULL)) );
CREATE INDEX IF NOT EXISTS idx_wip_worker ON worker_institution_positions(worker_id);

-- Sirketlerin performans bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_sla_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id),
    metric_type VARCHAR(50) NOT NULL,                -- 'DELIVERY_LATENCY', 'UPTIME_PERCENTAGE', 'RESPONSE_TIME'
    target_value NUMERIC(12, 4) NOT NULL,            -- e.g., Target 30 mins
    actual_value NUMERIC(12, 4) NOT NULL,            -- e.g., Actual 55 mins
    unit_of_measure VARCHAR(20) NOT NULL,            -- 'MINUTES', 'PERCENTAGE', 'HOURS'
    is_violated BOOLEAN DEFAULT FALSE,
    penalty_amount NUMERIC(18, 8) DEFAULT 0.00 CHECK (penalty_amount >= 0),
    penalty_currency SMALLINT DEFAULT 0,
    measured_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT );
CREATE INDEX IF NOT EXISTS idx_sla_violated ON institution_sla_metrics (is_violated) WHERE is_violated IS TRUE;
COMMENT ON TABLE institution_sla_metrics IS 'Operational SLA compliance records and automatic penalty calculations.';

-- Kurumların Şube ve Mahalle Dükkanı Listelerini Tutar
CREATE TABLE IF NOT EXISTS institution_branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    branch_code VARCHAR(30) NOT NULL,
    branch_name VARCHAR(150) NOT NULL,
    country_code SMALLINT NOT NULL,
    manager_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    requested_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,  
    institution_branche_address TEXT,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    address_proof_media_id UUID REFERENCES media_assets(id), 
    verification_status SMALLINT NOT NULL DEFAULT 0,
    approval_id UUID REFERENCES approvals(id) ON DELETE SET NULL, 
    verified_at TIMESTAMP WITH TIME ZONE,                        
    rejection_reason TEXT,                        
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_institution_branch_code UNIQUE (institution_id, branch_code) );
CREATE INDEX IF NOT EXISTS idx_branches_institution ON institution_branches(institution_id);
CREATE INDEX IF NOT EXISTS idx_branches_pending ON institution_branches(verification_status) WHERE verification_status = 0;
CREATE INDEX IF NOT EXISTS idx_branches_approval ON institution_branches(approval_id);

-- Sirketler arasi kampanya promosyonlarini tanimlar
CREATE TABLE IF NOT EXISTS promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issuer_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT, 
    campaign_code VARCHAR(50) UNIQUE NOT NULL, -- Örn: VIP_TRAVEL_HEALTH_2026
    campaign_title VARCHAR(150) NOT NULL,
    description TEXT,
    campaign_scope SMALLINT NOT NULL DEFAULT 0, -- enum_campaign_scope (0=Intra, 1=Cross, 2=Global)
    target_institution_ids INTEGER[] DEFAULT '{}', -- İndirimin geçerli olduğu spesifik kurumlar
    discount_type SMALLINT NOT NULL DEFAULT 0, -- enum_discount_type
    discount_value DECIMAL(18, 8) NOT NULL CHECK (discount_value > 0), -- Yüzde (örn: 0.1500 = %15) veya sabit tutar
    currency SMALLINT DEFAULT 0,
    min_order_amount DECIMAL(18, 8) DEFAULT 0.00 CHECK (min_order_amount >= 0),
    max_discount_amount DECIMAL(18, 8), -- Yüzdeli indirimlerde uygulanacak tavan tutar
    min_user_reputation_score DECIMAL(3, 2) DEFAULT 1.00 CHECK (min_user_reputation_score BETWEEN 1.00 AND 5.00),
    required_user_badge_level VARCHAR(50), -- Örn: 'VIP_TRAVELER', 'TOP_CUSTOMER' vb.
    max_total_uses INTEGER CHECK (max_total_uses > 0), -- Kampanya genel kullanım limiti
    current_uses INTEGER DEFAULT 0 CHECK (current_uses >= 0),
    max_uses_per_user INTEGER DEFAULT 1 CHECK (max_uses_per_user > 0),
    promotion_starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
    promotion_expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_promo_dates CHECK (promotion_expires_at > promotion_starts_at) );
CREATE INDEX IF NOT EXISTS idx_promotions_code ON promotions(campaign_code);

-- Promosyon kullanim bilgilerini loglarii tutar
CREATE TABLE IF NOT EXISTS promotion_redemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    promotion_id UUID NOT NULL REFERENCES promotions(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    redeemed_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT, -- İndirimin kullanıldığı kurum
    transaction_id UUID NOT NULL,
    transaction_created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    applied_discount_amount DECIMAL(18, 8) NOT NULL CHECK (applied_discount_amount >= 0),
    currency SMALLINT DEFAULT 0,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_redemption_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_redemptions_promo ON promotion_redemptions(promotion_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_user ON promotion_redemptions(user_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_inst ON promotion_redemptions(redeemed_institution_id);

-- Alt sirketlerin kendi aralarindaki konsortiumlari tanimlar
CREATE TABLE IF NOT EXISTS consortiums (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consortium_name VARCHAR(150) NOT NULL,
    consortium_code VARCHAR(50) UNIQUE NOT NULL, 
    consortium_type SMALLINT NOT NULL DEFAULT 0, 
    lead_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT, 
    consortium_description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_consortiums_code ON consortiums(consortium_code);

-- Konsortsyuma uyelik bilgilerini turlerini belirler
CREATE TABLE IF NOT EXISTS consortium_members (
    id SERIAL PRIMARY KEY,
    consortium_id UUID NOT NULL REFERENCES consortiums(id) ON DELETE RESTRICT,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    role_title VARCHAR(100) DEFAULT 'MEMBER', -- 'FOUNDER', 'MEMBER', 'RESOURCE_PROVIDER'
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT unq_consortium_institution UNIQUE (consortium_id, institution_id) );
CREATE INDEX IF NOT EXISTS idx_cm_consortium ON consortium_members(consortium_id);
CREATE INDEX IF NOT EXISTS idx_cm_institution ON consortium_members(institution_id);

-- Aynı sektördeki kurumların paylaştığı araç, mevduat, ekipman veya kontenjan havuzu
CREATE TABLE IF NOT EXISTS consortium_resource_pools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consortium_id UUID NOT NULL REFERENCES consortiums(id) ON DELETE RESTRICT,
    provider_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    resource_type SMALLINT NOT NULL, -- enum_resource_type (0=Vehicles, 1=Liquidity, etc.)
    resource_name VARCHAR(150) NOT NULL, -- Örn: "Zırhlı Transfer Aracı Filosu", "Gecelik Likidite Havuzu"
    total_capacity DECIMAL(18, 8) NOT NULL CHECK (total_capacity > 0), -- Toplam adet, araç sayısı veya bakiye
    available_capacity DECIMAL(18, 8) NOT NULL CHECK (available_capacity >= 0),
    unit_symbol VARCHAR(20) NOT NULL, -- 'UNIT', 'USD', 'TRY', 'VEHICLE'
    b2b_unit_price DECIMAL(18, 8) NOT NULL CHECK (b2b_unit_price >= 0), -- Konsorsiyum içi indirimli birim fiyatı
    currency SMALLINT DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_pool_capacity CHECK (available_capacity <= total_capacity) );
CREATE INDEX IF NOT EXISTS idx_crp_consortium ON consortium_resource_pools(consortium_id);
CREATE INDEX IF NOT EXISTS idx_crp_provider ON consortium_resource_pools(provider_institution_id);

-- Farklı sektördeki kurumların çalışanları, ortakları veya tedarikleri için anlaşmaları
CREATE TABLE IF NOT EXISTS b2b_corporate_agreements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT, -- İndirimi Talep Eden / Alıcı Kurum
    seller_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT, -- Hizmet/Ürün Sağlayan Kurum
    agreement_title VARCHAR(150) NOT NULL, -- Örn: "Sağlık Personeli Özel Turizm/Eğitim Anlaşması"
    agreement_target SMALLINT NOT NULL DEFAULT 0, -- enum_agreement_target (0=Employees, 1=Shareholders, 2=Supply)
    discount_percentage DECIMAL(5, 4) DEFAULT 0.0000 CHECK (discount_percentage BETWEEN 0.0000 AND 1.0000), -- Örn: 0.2500 (%25 B2B İndirim)
    custom_price_tier_json JSONB DEFAULT '{}'::jsonb, -- Özel matris/fiyat listesi
    valid_from TIMESTAMP WITH TIME ZONE NOT NULL,
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
    agreement_media_id UUID REFERENCES media_assets(id),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_b2b_institutions CHECK (buyer_institution_id <> seller_institution_id),
    CONSTRAINT chk_b2b_dates CHECK (valid_until > valid_from) );
CREATE INDEX IF NOT EXISTS idx_b2b_buyer ON b2b_corporate_agreements(buyer_institution_id);
CREATE INDEX IF NOT EXISTS idx_b2b_seller ON b2b_corporate_agreements(seller_institution_id);

-- Konsorsyium kaynak kullanimi ve mahpuslasma loglarini tutar
CREATE TABLE IF NOT EXISTS consortium_resource_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pool_id UUID REFERENCES consortium_resource_pools(id) ON DELETE RESTRICT,
    agreement_id UUID REFERENCES b2b_corporate_agreements(id) ON DELETE RESTRICT,
    consumer_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    beneficiary_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT, -- Kullanıcı bazlı ise (Çalışan/Hissedar)
    beneficiary_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    requested_amount DECIMAL(18, 8) NOT NULL CHECK (requested_amount > 0),
    total_b2b_cost DECIMAL(18, 8) NOT NULL CHECK (total_b2b_cost >= 0),
    currency SMALLINT DEFAULT 0,
    transaction_id UUID NOT NULL,
    transaction_created_at TIMESTAMP WITH TIME ZONE NOT NULL, -- B2B ödeme/mahsuplaşma kaydı
    consortium_resource_usage_status SMALLINT DEFAULT 1, -- 0=PENDING, 1=APPROVED, 2=REJECTED
    used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cru_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_cru_consumer ON consortium_resource_usage(consumer_institution_id);
CREATE INDEX IF NOT EXISTS idx_cru_transaction ON consortium_resource_usage(transaction_id);

-- Sirketlerin vergi hesaplarini tutar
CREATE TABLE IF NOT EXISTS institution_government_tax_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    government_tax_authority_id INTEGER NOT NULL REFERENCES government_tax_authorities(id) ON DELETE RESTRICT,
    chart_account_id INTEGER NOT NULL REFERENCES chart_of_accounts(id) ON DELETE RESTRICT, -- "Ödenecek Vergi" GL hesabı
    currency SMALLINT NOT NULL,-- diğer tüm mali kayıtlarla aynı para birimi mantığı
    accrued_balance DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (accrued_balance >= 0), -- tahakkuk etmiş, henüz ödenmemiş
    total_accrued_lifetime DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (total_accrued_lifetime >= 0),
    total_remitted_lifetime DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (total_remitted_lifetime >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_institution_tax_authority_currency UNIQUE (institution_id, government_tax_authority_id, currency) );
CREATE INDEX IF NOT EXISTS idx_igta_institution ON institution_government_tax_accounts(institution_id);
CREATE INDEX IF NOT EXISTS idx_igta_authority ON institution_government_tax_accounts(government_tax_authority_id);
COMMENT ON TABLE institution_government_tax_accounts IS 'Kurumun, kendi ülkesindeki devlete karşı tuttuğu vergi tahakkuk/tahsilat hesabı. Gerçek para hareketi değil, muhasebe bakiyesidir.';

-- Sirketlerin vergi tahakkuk hesaplarini tutar
CREATE TABLE IF NOT EXISTS tax_accruals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_government_tax_account_id UUID NOT NULL REFERENCES institution_government_tax_accounts(id) ON DELETE RESTRICT,
    tax_rate_rule_id INTEGER REFERENCES tax_rates_and_rules(id) ON DELETE RESTRICT, -- 07_system_extensions.sql
    transaction_id UUID NOT NULL,
    transaction_created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    base_amount DECIMAL(18, 8) NOT NULL CHECK (base_amount >= 0),
    tax_amount DECIMAL(18, 8) NOT NULL CHECK (tax_amount >= 0),
    currency SMALLINT NOT NULL,
    journal_entry_id UUID REFERENCES journal_entries(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tax_accrual_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_tax_accruals_account ON tax_accruals(institution_government_tax_account_id);
CREATE INDEX IF NOT EXISTS idx_tax_accruals_transaction ON tax_accruals(transaction_id);
COMMENT ON TABLE tax_accruals IS 'Append-only vergi tahakkuk kayıtları — her satır bir işlemden doğan vergiyi temsil eder.';

-- Sirketlerin devletlere yapilan vergi odemelerini tutar
CREATE TABLE IF NOT EXISTS government_tax_remittances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_government_tax_account_id UUID NOT NULL REFERENCES institution_government_tax_accounts(id) ON DELETE RESTRICT,
    real_world_account_id INTEGER NOT NULL REFERENCES real_world_accounts(id) ON DELETE RESTRICT, -- ödemenin çıktığı gerçek banka hesabı
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    currency SMALLINT NOT NULL,
    remittance_reference VARCHAR(100),                 -- devlete yapılan ödeme dekont/referans no
    journal_entry_id UUID REFERENCES journal_entries(id) ON DELETE RESTRICT,
    issued_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    government_tax_remittance_status SMALLINT NOT NULL DEFAULT 1,                -- enum_tax_remittance_status
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_gtr_tax_account ON government_tax_remittances(institution_government_tax_account_id);
CREATE INDEX IF NOT EXISTS idx_gtr_status ON government_tax_remittances(government_tax_remittance_status);
COMMENT ON TABLE government_tax_remittances IS 'Kurumdan devlete fiilen yapılan vergi ödeme fişleri.';

-- Kurumların hak kazanabileceği imtiyaz ve prestij eşiklerini tutar
CREATE TABLE IF NOT EXISTS institution_privilege_tiers (
    id SERIAL PRIMARY KEY,
    category_code SMALLINT,                      -- NULL = app geneli, 1 = Mobilya, 2 = Gıda vb.
    tier_code VARCHAR(50) NOT NULL,              -- 'FEATURED_ELIGIBLE', 'PRIORITY_SUPPORT', 'RELAXED_REVIEW_WINDOW' vb.
    basis SMALLINT NOT NULL DEFAULT 0,           -- Hangi kritere dayanıyor? (Puan, işlem hacmi, uyum skoru vb.)
    min_threshold DECIMAL(5, 2) NOT NULL,        -- Örn. 4.70 (average_score) ya da 90.00 (compliance_score)
    min_rating_count INTEGER NOT NULL DEFAULT 0 CHECK (min_rating_count >= 0), -- İstatistiksel anlamlılık için taban
    effect_json JSONB NOT NULL DEFAULT '{}'::jsonb,  -- Örn. {"featured_boost": true, "commission_discount_bps": 50}
    description TEXT NOT NULL,                   -- ZORUNLU: Gerekçe her zaman herkese açık okunabilir olmalı
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_privilege_tier UNIQUE (category_code, tier_code) );
CREATE INDEX IF NOT EXISTS idx_privilege_tiers_lookup ON institution_privilege_tiers(category_code, is_active);

-- Kurumların tanımlı eşik bazında kazandığı hak ve skorların geçmişini tutar
CREATE TABLE IF NOT EXISTS institution_privilege_grants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    category_code SMALLINT,
    tier_id INTEGER NOT NULL REFERENCES institution_privilege_tiers(id) ON DELETE RESTRICT,
    achieved_score DECIMAL(5, 2) NOT NULL,       -- Grant anındaki gerçek skor (kanıt)
    achieved_rating_count INTEGER NOT NULL,
    is_current BOOLEAN NOT NULL DEFAULT true,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP WITH TIME ZONE );
CREATE INDEX IF NOT EXISTS idx_privilege_grants_institution ON institution_privilege_grants(institution_id, is_current);
CREATE INDEX IF NOT EXISTS idx_privilege_grants_tier ON institution_privilege_grants(tier_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_current_privilege_grant
ON institution_privilege_grants (institution_id, tier_id) WHERE is_current = true;

-- Sirket kurma basvuru bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_formation_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    applicant_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    institution_name VARCHAR(150) NOT NULL,
    tax_number VARCHAR(50) NOT NULL,
    tax_office VARCHAR(100),
    country_code SMALLINT NOT NULL,
    registration_number VARCHAR(50),
    board_approval_threshold DECIMAL(5,4) NOT NULL DEFAULT 0.5000
        CHECK (board_approval_threshold > 0 AND board_approval_threshold <= 1.0000),
    office_address TEXT NOT NULL,
    office_latitude DECIMAL(9, 6),
    office_longitude DECIMAL(9, 6),
    incorporation_contract_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    trade_registry_gazette_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    institution_formation_application_status SMALLINT NOT NULL DEFAULT 0,
    reviewed_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    rejection_reason TEXT,
    created_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_ifa_rejection_reason CHECK (institution_formation_application_status <> 2 OR rejection_reason IS NOT NULL) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_ifa_pending_tax_number
    ON institution_formation_applications (tax_number) WHERE institution_formation_application_status = 0;
CREATE INDEX IF NOT EXISTS idx_ifa_applicant ON institution_formation_applications(applicant_user_id);
CREATE INDEX IF NOT EXISTS idx_ifa_pending ON institution_formation_applications(institution_formation_application_status) WHERE institution_formation_application_status = 0;

-- Sirkete sube acma bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_branch_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    applicant_worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    branch_code VARCHAR(30) NOT NULL,
    branch_name VARCHAR(150) NOT NULL,
    country_code SMALLINT NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    address_proof_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    institution_branch_application_status SMALLINT NOT NULL DEFAULT 0,
    reviewed_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    rejection_reason TEXT,
    created_branch_id UUID REFERENCES institution_branches(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_iba_rejection_reason CHECK (institution_branch_application_status <> 2 OR rejection_reason IS NOT NULL) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_iba_pending_branch_code
    ON institution_branch_applications (institution_id, branch_code) WHERE institution_branch_application_status = 0;
CREATE INDEX IF NOT EXISTS idx_iba_institution ON institution_branch_applications(institution_id);
CREATE INDEX IF NOT EXISTS idx_iba_pending ON institution_branch_applications(institution_branch_application_status) WHERE institution_branch_application_status = 0;

DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'voucher_batch_seq') THEN 
        CREATE SEQUENCE voucher_batch_seq START WITH 1; END IF; END $$;

-- Para girisi icin uretilen digital kuponlar
CREATE TABLE IF NOT EXISTS vouchers ( 
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hash_code VARCHAR(64) UNIQUE NOT NULL,
    issuer_institution_id INTEGER REFERENCES institutions(id),
    created_by_worker_id INTEGER REFERENCES workers(id),  
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    currency SMALLINT NOT NULL,
    is_used BOOLEAN DEFAULT false,
    used_by_user_id INTEGER REFERENCES users(id),
    used_at TIMESTAMP WITH TIME ZONE,
    is_cancelled BOOLEAN DEFAULT false,
    cancel_reason TEXT,
    expiry_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    batch_id INTEGER,
    CONSTRAINT chk_voucher_state CHECK (NOT (is_used = true AND is_cancelled = true) ) );

--Para cikisi icin uretilecek dogrulama kodu ve islemler
CREATE TABLE IF NOT EXISTS withdrawal_requests ( 
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(id),
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    fee_deducted DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (fee_deducted >= 0),
    currency SMALLINT NOT NULL,
    verification_code VARCHAR(6),
    is_verified BOOLEAN DEFAULT false,
    withdrawal_status SMALLINT DEFAULT 0,
    assigned_institution_id INTEGER REFERENCES institutions(id),
    assigned_worker_id INTEGER REFERENCES workers(id),
    qr_data TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL '15 minutes'),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE );

-- Sistemin uygulayacagi komisyon sinirlarini tutar
CREATE TABLE IF NOT EXISTS system_commissions (
    id SERIAL PRIMARY KEY,
    currency SMALLINT NOT NULL,
    user_type SMALLINT NOT NULL DEFAULT 0,
    tx_type SMALLINT NOT NULL DEFAULT 0,
    base_rate DECIMAL(5, 4) DEFAULT 0.002 CHECK (base_rate BETWEEN 0 AND 1),
    promo_rate DECIMAL(5, 4) CHECK (promo_rate BETWEEN 0 AND 1),
    promo_expiry TIMESTAMP WITH TIME ZONE,
    updated_by_worker_id INTEGER REFERENCES workers(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_app_rate_per_type UNIQUE (currency, user_type, tx_type) );

-- Cüzdanlarda anlık ön bloke (Hold / Rezervasyon) tutarını tutar
CREATE TABLE IF NOT EXISTS wallet_holds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    initiated_by_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    amount DECIMAL(18,8) NOT NULL CHECK (amount > 0),
    currency SMALLINT NOT NULL DEFAULT 0, 
    purpose SMALLINT NOT NULL, 
    reference_type VARCHAR(30) NOT NULL, -- İlgili tablo adı (Örn: 'orders', 'auctions')
    reference_id UUID NOT NULL,    
    wallet_hold_status SMALLINT NOT NULL DEFAULT 0, 
    metadata JSONB, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,      -- Blokajın otomatik düşeceği son tarih
    resolved_at TIMESTAMP WITH TIME ZONE  );
CREATE INDEX IF NOT EXISTS idx_wallet_holds_wallet ON wallet_holds(wallet_id, wallet_hold_status);
CREATE INDEX IF NOT EXISTS idx_wallet_holds_reference ON wallet_holds(reference_type, reference_id);
CREATE INDEX IF NOT EXISTS idx_wallet_holds_status ON wallet_holds(wallet_hold_status);
CREATE INDEX IF NOT EXISTS idx_wallet_holds_metadata_gin ON wallet_holds USING gin (metadata);
COMMENT ON TABLE wallet_holds IS
 'Cüzdanlarda anlık sipariş, teklif veya rezervasyon amaçlı geçici bakiye blokajları.';

-- Blokeli ortak güvence (Escrow / Emanet) hesaplarını tutar
CREATE TABLE IF NOT EXISTS escrow_records (
    id UUID DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL,
    transaction_created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    payer_wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    payee_wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount >= 0),
    system_commission_amount DECIMAL(18, 8) DEFAULT 0.00 CHECK (system_commission_amount >= 0),
    net_payee_amount DECIMAL(18, 8) NOT NULL CHECK (net_payee_amount >= 0),
    currency SMALLINT NOT NULL DEFAULT 0, -- Transactions tablosuyla uyumlu para birimi
    escrow_status SMALLINT DEFAULT 0,
    metadata JSONB, -- Kargo takip no, sipariş detayları vb.
    expires_at TIMESTAMP WITH TIME ZONE, -- Otomatik serbest bırakılma veya zaman aşımı süresi
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_escrow_records PRIMARY KEY (id, created_at),
    CONSTRAINT fk_escrow_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_escrow_different_wallets CHECK (
        payer_wallet_id IS DISTINCT FROM payee_wallet_id ) ) PARTITION BY RANGE (created_at);
CREATE TABLE IF NOT EXISTS escrow_records_default 
    PARTITION OF escrow_records DEFAULT;
CREATE TABLE IF NOT EXISTS escrow_records_2026 
    PARTITION OF escrow_records 
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
CREATE INDEX IF NOT EXISTS idx_escrow_payer ON escrow_records(payer_wallet_id);
CREATE INDEX IF NOT EXISTS idx_escrow_payee ON escrow_records(payee_wallet_id);
CREATE INDEX IF NOT EXISTS idx_escrow_status ON escrow_records(escrow_status);
CREATE INDEX IF NOT EXISTS idx_escrow_metadata_gin ON escrow_records USING gin (metadata);
COMMENT ON TABLE escrow_records IS
 'Güvenli ticaret ve veresiye işlemleri için fonların blokede tutulduğu emanet (Escrow) defteri.';

-- Sirket calisanlari ve yoneticileri icin yetki sinirlarini tutar
CREATE TABLE IF NOT EXISTS worker_permission_catalog (
    id SERIAL PRIMARY KEY,
    permission_key VARCHAR(100) UNIQUE NOT NULL,          -- 'VIEW_FULL_LEDGER','VERIFY_CUSTOMER_QR' vb.
    screen_key VARCHAR(100) NOT NULL,               -- Flutter route/ekran anahtarı
    description TEXT NOT NULL,
    is_sensitive BOOLEAN NOT NULL DEFAULT false,             -- finansal/bilanço görünürlüğü gibi hassas erişim
    is_default_for_employee BOOLEAN NOT NULL DEFAULT false,  -- SALARIED/COMMISSION worker'a otomatik verilir mi
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_permission_catalog_app ON worker_permission_catalog(is_active);

-- Sirket calisanlarinin ve yoneticilerinin yetki kayitlarini tutar
CREATE TABLE IF NOT EXISTS worker_position_permissions (
    id SERIAL PRIMARY KEY,
    position_id INTEGER NOT NULL REFERENCES worker_institution_positions(id) ON DELETE RESTRICT,
    permission_id INTEGER NOT NULL REFERENCES worker_permission_catalog(id) ON DELETE RESTRICT,
    granted_by_shareholder_id INTEGER REFERENCES institution_shareholders(id) ON DELETE RESTRICT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP WITH TIME ZONE,
    revoked_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    CONSTRAINT unq_position_permission UNIQUE (position_id, permission_id) );
CREATE INDEX IF NOT EXISTS idx_wpp_position_active ON worker_position_permissions(position_id) WHERE is_active = true;


-- KULLANICI VERİ MAHREMİYETİ VE ANONİMLEŞTİRME TALEPLERİ (GDPR / KVKK)
CREATE TABLE IF NOT EXISTS gdpr_anonymization_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    request_type SMALLINT NOT NULL DEFAULT 0, 
    reason TEXT, -- Talep gerekçesi
    request_status SMALLINT NOT NULL DEFAULT 0, 
    approval_id UUID REFERENCES approvals(id) ON DELETE SET NULL, -- Uyum/Etik oylama motoru referansı
    processed_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT, -- İşlemi onaylayan/yürüten yetkili
    anonymized_fields JSONB DEFAULT '[]'::jsonb, 
    rejection_reason TEXT, -- Eğer talep reddedildiyse nedeni
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_gdpr_user_status ON gdpr_anonymization_requests (user_id, request_status);
CREATE INDEX IF NOT EXISTS idx_gdpr_approval ON gdpr_anonymization_requests (approval_id);
COMMENT ON TABLE gdpr_anonymization_requests IS
 'GDPR/KVKK Right-to-be-Forgotten request tracking and audit log.';

-- Sistemin farkli durumlarini yonetmek icin hizli yonetim bayraklari tutar
CREATE TABLE IF NOT EXISTS system_feature_flags (
    id SERIAL PRIMARY KEY,
    feature_key VARCHAR(100) UNIQUE NOT NULL,-- e.g., 'WITHDRAWAL_ENABLED', 'B2B_EXCHANGE_ACTIVE'
    is_enabled BOOLEAN DEFAULT TRUE,
    rules_json JSONB DEFAULT '{}'::jsonb,           -- Granular controls (e.g., {"max_tx_limit": 5000})
    description TEXT,
    updated_by_worker_id INTEGER REFERENCES workers(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_feature_flags_key ON system_feature_flags (feature_key);
COMMENT ON TABLE system_feature_flags IS
 'Dynamic kill-switches and operational feature toggles for high availability.';

-- Doviz ceviri arbitraj bilgilerini tutar 
CREATE TABLE IF NOT EXISTS currency_exchange_rates (
    id BIGSERIAL PRIMARY KEY,
    base_currency SMALLINT NOT NULL,            -- e.g., 'USD', 'EUR'
    target_currency SMALLINT NOT NULL,          -- e.g., 'TRY', 'JPY'
    exchange_rate NUMERIC(18, 8) NOT NULL CHECK (exchange_rate > 0),
    source VARCHAR(50) DEFAULT 'CENTRAL_BANK',     -- 'ECB', 'TCMB', 'BINANCE', 'REFINITIV'
    metadata JSONB DEFAULT '{}'::jsonb,            -- Raw API response / telemetry
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_currency_pair_time UNIQUE (base_currency, target_currency, fetched_at) );
CREATE INDEX IF NOT EXISTS idx_exchange_rates_lookup 
    ON currency_exchange_rates (base_currency, target_currency, fetched_at DESC);
COMMENT ON TABLE currency_exchange_rates IS
 'Real-time and historical currency exchange rates for cross-market ledger accounting.';

-- Komisyon kurallarini taraflarini tutar
CREATE TABLE IF NOT EXISTS commission_rules (
    id SERIAL PRIMARY KEY,
    category_code SMALLINT,                             -- NULL = app içindeki tüm kategoriler
    actor_type SMALLINT NOT NULL,                       -- enum_commission_actor_type (kimden kesilecek)
    commission_type SMALLINT NOT NULL,                  -- enum_commission_type
    commission_value DECIMAL(18, 8) NOT NULL CHECK (commission_value >= 0),  -- 0.0250 = %2.5 ya da sabit tutar
    min_commission_amount DECIMAL(18, 8) CHECK (min_commission_amount IS NULL OR min_commission_amount >= 0),
    max_commission_amount DECIMAL(18, 8) CHECK (max_commission_amount IS NULL OR max_commission_amount >= 0),
    currency SMALLINT,                                  -- FIXED_AMOUNT için zorunlu
    is_active BOOLEAN NOT NULL DEFAULT true,
    effective_from TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_commission_dates CHECK (effective_until IS NULL OR effective_until > effective_from),
    CONSTRAINT chk_commission_min_max CHECK (max_commission_amount IS NULL OR min_commission_amount IS NULL OR max_commission_amount >= min_commission_amount) );
CREATE INDEX IF NOT EXISTS idx_commission_lookup ON commission_rules (category_code, actor_type, is_active);

-- Cok tarafli islem bazli kesilen komisyonlari tutar
CREATE TABLE IF NOT EXISTS transaction_commissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL,
    transaction_created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    commission_rule_id INTEGER REFERENCES commission_rules(id) ON DELETE RESTRICT,
    charged_actor_type SMALLINT NOT NULL,          -- enum_commission_actor_type
    charged_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    charged_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    charged_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount >= 0),
    currency SMALLINT NOT NULL,
    system_wallet_id UUID REFERENCES wallets(id) ON DELETE RESTRICT,  -- hangi komisyon havuzuna gitti
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_commission_charged_ref CHECK (
        (charged_user_id IS NOT NULL AND charged_worker_id IS NULL AND charged_institution_id IS NULL) OR
        (charged_worker_id IS NOT NULL AND charged_user_id IS NULL AND charged_institution_id IS NULL) OR
        (charged_institution_id IS NOT NULL AND charged_user_id IS NULL AND charged_worker_id IS NULL) ),
    CONSTRAINT fk_txcommission_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_txcommission_transaction ON transaction_commissions(transaction_id);

-- Sistemin Sirketler icin kural setini tutar
CREATE TABLE IF NOT EXISTS institution_operating_rules (
    id SERIAL PRIMARY KEY,   
    category_code SMALLINT,                                -- NULL = app geneli
    rule_key VARCHAR(100) NOT NULL,                        -- 'REQUIRES_LICENSE', 'MAX_REFUND_WINDOW_DAYS', 'MIN_STOCK_ALERT'
    rule_value JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_mandatory BOOLEAN NOT NULL DEFAULT true,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_operating_rule UNIQUE (category_code, rule_key) );
CREATE INDEX IF NOT EXISTS idx_operating_rules_lookup ON institution_operating_rules(category_code, is_active);

-- Alt sirketlerin kural seti loglarini tutar
CREATE TABLE IF NOT EXISTS institution_compliance_checks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    branch_id UUID REFERENCES institution_branches(id) ON DELETE RESTRICT,
    rule_id INTEGER NOT NULL REFERENCES institution_operating_rules(id) ON DELETE RESTRICT,
    check_result SMALLINT NOT NULL,                        -- enum_compliance_result
    details JSONB DEFAULT '{}'::jsonb,
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_compliance_institution ON institution_compliance_checks(institution_id, checked_at DESC);
CREATE INDEX IF NOT EXISTS idx_compliance_result ON institution_compliance_checks(check_result) WHERE check_result <> 0;

-- Sistem içerisindeki finansal itiraz, anlaşmazlık ve iade işlemlerini tutar
CREATE TABLE IF NOT EXISTS transaction_disputes_and_refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL,
    transaction_created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    dispute_type SMALLINT NOT NULL DEFAULT 0,     
    requested_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    claimed_amount NUMERIC(18, 8) NOT NULL CHECK (claimed_amount > 0),
    approved_amount NUMERIC(18, 8) DEFAULT 0.00 CHECK (approved_amount >= 0),
    currency SMALLINT NOT NULL,
    reason_code VARCHAR(50) NOT NULL, -- 'DEFECTIVE_SERVICE', 'NON_DELIVERY', 'FRAUD_SUSPECT'
    reason_description TEXT,
    transaction_dispute_and_refund_status SMALLINT DEFAULT 0,
    evidence_media_ids UUID[] DEFAULT '{}', -- Kanıt dosyaları / medya referansları
    resolved_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT, 
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_approved_lte_claimed CHECK (approved_amount <= claimed_amount),
    CONSTRAINT fk_dispute_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_disputes_transaction ON transaction_disputes_and_refunds (transaction_id);
CREATE INDEX IF NOT EXISTS idx_disputes_user ON transaction_disputes_and_refunds (requested_by_user_id);
CREATE INDEX IF NOT EXISTS idx_disputes_status ON transaction_disputes_and_refunds (transaction_dispute_and_refund_status);
COMMENT ON TABLE transaction_disputes_and_refunds IS
 'Müşteri ve esnaf arasındaki ödeme itirazları, iade talepleri ve emanet çözüve bağlama defteri.';

-- Sistem icerisindeki tum sikayet bilgilerini tutar
CREATE TABLE IF NOT EXISTS complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_root_id INT NOT NULL REFERENCES users(id),
    reporter_internal_id INTEGER,
    target_root_id INTEGER REFERENCES users(id),
    target_internal_id INTEGER,
    routed_to SMALLINT NOT NULL DEFAULT 1,
    escalated_to_system BOOLEAN DEFAULT false,
    escalated_at TIMESTAMP WITH TIME ZONE,
    evidence_media_ids UUID[],
    reporter_role SMALLINT NOT NULL,
    target_role SMALLINT NOT NULL,
    reason_category TEXT NOT NULL,
    description TEXT NOT NULL,
    complaint_status SMALLINT DEFAULT 0,
    ai_analysis JSONB,
    admin_note TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_complaints_ai_analysis_gin ON complaints USING gin (ai_analysis);

-- Sistem icerisindeki tum bildirim bilgilerini tutar
CREATE TABLE IF NOT EXISTS notification_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_type SMALLINT NOT NULL,
    sender_worker_id INTEGER REFERENCES workers(id),
    target_scope SMALLINT NOT NULL,
    target_institution_worker_id INTEGER REFERENCES workers(id),
    target_user_ids INTEGER[],
    target_age_min SMALLINT,
    target_age_max SMALLINT,
    target_nationality_codes VARCHAR(3)[],
    notification_campaign_severity SMALLINT NOT NULL DEFAULT 0,
    notification_campaign_title TEXT NOT NULL,
    notification_campaign_message TEXT NOT NULL,
    metadata JSONB,
    recipient_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_notification_campaigns_metadata_gin ON notification_campaigns USING gin (metadata);

-- Bildirimlerin okunma bilgilerini tutar 
CREATE TABLE IF NOT EXISTS notification_deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES notification_campaigns(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_notif_delivery UNIQUE (campaign_id, user_id) );

  -- Sistem içerisindeki tarafların birbirini karşılıklı puanlama ve değerlendirme bilgileri
CREATE TABLE IF NOT EXISTS ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_code SMALLINT NOT NULL, -- Kategori / Sektör kodu (Örn: Yem, Mobilya, Lojistik)
    reference_transaction_id UUID,
    reference_transaction_created_at TIMESTAMP WITH TIME ZONE, -- Yapılan işleme/siparişe ait referans
    evaluator_type SMALLINT NOT NULL, -- Puan veren türü (0: User, 1: Worker, 2: Institution)
    evaluator_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    evaluator_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    evaluator_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    target_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    target_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    target_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    score DECIMAL(3, 2) NOT NULL CHECK (score >= 1.00 AND score <= 5.00), -- 1.00 - 5.00 arası standart skor
    trust_score DECIMAL(5, 2) CHECK (trust_score >= 0.00 AND trust_score <= 100.00), -- Finans / Güvenilirlik yüzdesi (opsiyonel)
    review_title VARCHAR(150),
    review_comment TEXT,
    proof_media_ids UUID[], -- Kanıt / Görsel materyaller (media_assets)
    rating_status SMALLINT DEFAULT 1, -- 0: Pending, 1: Approved/Active, 2: Hidden
    is_anonymous BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_evaluator_ref CHECK (
        (evaluator_user_id IS NOT NULL AND evaluator_institution_id IS NULL AND evaluator_worker_id IS NULL) OR
        (evaluator_institution_id IS NOT NULL AND evaluator_user_id IS NULL AND evaluator_worker_id IS NULL) OR
        (evaluator_worker_id IS NOT NULL AND evaluator_user_id IS NULL AND evaluator_institution_id IS NULL) ),
    CONSTRAINT chk_target_ref CHECK (
        (target_user_id IS NOT NULL AND target_institution_id IS NULL AND target_worker_id IS NULL) OR
        (target_institution_id IS NOT NULL AND target_user_id IS NULL AND target_worker_id IS NULL) OR
        (target_worker_id IS NOT NULL AND target_user_id IS NULL AND target_institution_id IS NULL) ),
    CONSTRAINT fk_ratings_transaction FOREIGN KEY (reference_transaction_id, reference_transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_ratings_category ON ratings(category_code);
CREATE INDEX IF NOT EXISTS idx_ratings_target_user ON ratings(target_user_id) WHERE target_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_ratings_target_worker ON ratings(target_worker_id) WHERE target_worker_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_ratings_target_inst ON ratings(target_institution_id) WHERE target_institution_id IS NOT NULL;  
    
-- Ana kullanıcıların kategori bazlı itibar ve risk skorlarını tutar
CREATE TABLE IF NOT EXISTS user_domain_reputations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    category_code SMALLINT NOT NULL, 
    total_rating_count INTEGER DEFAULT 0 CHECK (total_rating_count >= 0),
    average_score DECIMAL(3, 2) DEFAULT 5.00 CHECK (average_score BETWEEN 1.00 AND 5.00),
    credit_trust_score DECIMAL(5, 2) DEFAULT 100.00 CHECK (credit_trust_score BETWEEN 0.00 AND 100.00), 
    badge_level VARCHAR(50) DEFAULT 'STANDARD', -- 'VIP_CUSTOMER', 'TRUSTED_BUYER' vb.
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_user_category_reputation UNIQUE (user_id, category_code) );

-- Şirket çalışanlarının kategori bazlı itibar ve performans skorlarını tutar
CREATE TABLE IF NOT EXISTS worker_domain_reputations (
    id SERIAL PRIMARY KEY,
    worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    category_code SMALLINT NOT NULL,
    total_rating_count INTEGER DEFAULT 0 CHECK (total_rating_count >= 0),
    average_score DECIMAL(3, 2) DEFAULT 5.00 CHECK (average_score BETWEEN 1.00 AND 5.00),
    credit_trust_score DECIMAL(5, 2) DEFAULT 100.00 CHECK (credit_trust_score BETWEEN 0.00 AND 100.00), 
    badge_level VARCHAR(50) DEFAULT 'STANDARD', 
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_worker_category_reputation UNIQUE (worker_id, category_code) );

-- Kurumların ve mahalle esnaflarının kategori/sektör bazlı itibar ve uyum skorlarını tutar
CREATE TABLE IF NOT EXISTS institution_domain_reputations (
    id SERIAL PRIMARY KEY,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    category_code SMALLINT NOT NULL, -- Örn: Yem üretimi, mobilya, tarım donanımı vb.
    total_rating_count INTEGER DEFAULT 0 CHECK (total_rating_count >= 0),
    average_score DECIMAL(3, 2) DEFAULT 5.00 CHECK (average_score BETWEEN 1.00 AND 5.00),
    compliance_score DECIMAL(5, 2) DEFAULT 100.00 CHECK (compliance_score BETWEEN 0.00 AND 100.00), -- Yasal/Sektörel Uyum Skoru
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_inst_app_category_reputation UNIQUE (institution_id, category_code) );

-- Sirketlere ortak alimi ile ilgili bilgileri tutar
CREATE TABLE IF NOT EXISTS institution_partner_application_details (
    approval_id UUID PRIMARY KEY REFERENCES approvals(id) ON DELETE RESTRICT,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    offered_total_value DECIMAL(18,8) NOT NULL CHECK (offered_total_value > 0), -- bu başvurunun PENDING katkı satırlarının toplamı
    projected_equity_percentage NUMERIC(9,8) GENERATED ALWAYS AS
        ((offered_total_value / (company_value_snapshot + offered_total_value))::NUMERIC(9,8)) STORED,
    currency SMALLINT NOT NULL DEFAULT 0,
    company_value_snapshot DECIMAL(18,8) NOT NULL CHECK (company_value_snapshot >= 0),
    motivation_text TEXT,
    resulting_shareholder_id INTEGER REFERENCES institution_shareholders(id) ON DELETE RESTRICT,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    application_kind SMALLINT NOT NULL DEFAULT 0,   -- 0 = YENİ ORTAK, 1 = MEVCUT ORTAK SERMAYE ARTIRIMI
    position_type SMALLINT,                         -- sadece yeni ortakta dolu: 2=EQUITY_PARTNER, 3=MANAGING_PARTNER
    CONSTRAINT chk_partner_app_kind CHECK ((application_kind = 0 AND position_type IN (2, 3)) OR
        (application_kind = 1 AND position_type IS NULL)));
CREATE INDEX IF NOT EXISTS idx_partner_app_details_institution
    ON institution_partner_application_details (institution_id);

-- Sirketlere eleman alimi ile ilgili bilgileri tutar
CREATE TABLE IF NOT EXISTS institution_employment_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    applicant_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    position_type SMALLINT NOT NULL DEFAULT 0, -- 0=SALARIED_EMPLOYEE, 1=COMMISSION_WORKER
    proposed_monthly_salary DECIMAL(18, 8) DEFAULT 0.00 CHECK (proposed_monthly_salary >= 0),
    proposed_commission_rate DECIMAL(5, 4) DEFAULT 0.0000 CHECK (proposed_commission_rate >= 0 AND proposed_commission_rate <= 1.0000),
    currency SMALLINT DEFAULT 0,
    cover_note TEXT,
    institution_employment_application_status SMALLINT NOT NULL DEFAULT 0, -- 0=PENDING, 1=APPROVED, 2=REJECTED
    reviewed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    review_note TEXT,
    resulting_position_id INTEGER REFERENCES worker_institution_positions(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_employment_no_self_review
       CHECK (reviewed_by_user_id IS NULL OR reviewed_by_user_id <> applicant_user_id),
    CONSTRAINT chk_employment_position_type CHECK (position_type IN (0, 1)) );
CREATE INDEX IF NOT EXISTS idx_employment_apps_institution ON institution_employment_applications(institution_id, institution_employment_application_status);
CREATE INDEX IF NOT EXISTS idx_employment_apps_applicant ON institution_employment_applications(applicant_user_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_employment_apps_pending ON institution_employment_applications (institution_id, applicant_user_id)
    WHERE institution_employment_application_status = 0;

-- Çıkışa özgü detay: approvals ile 1:1
CREATE TABLE IF NOT EXISTS institution_partner_exit_details (
    approval_id UUID PRIMARY KEY REFERENCES approvals(id) ON DELETE RESTRICT,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    shareholder_id INTEGER NOT NULL REFERENCES institution_shareholders(id) ON DELETE RESTRICT,
    exit_type SMALLINT NOT NULL DEFAULT 1,
    redistribution_mode SMALLINT NOT NULL,
    reason TEXT NOT NULL,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_pea_exit_type CHECK (exit_type IN (0, 1)),
    CONSTRAINT chk_pea_redistribution_mode CHECK (redistribution_mode IN (0, 1)));
CREATE UNIQUE INDEX uq_partner_exit_open
    ON institution_partner_exit_details (shareholder_id) WHERE is_open;

-- Maddi varlik bilgilerini tutar
CREATE TABLE IF NOT EXISTS fixed_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT, -- şirket malı
    owner_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,                -- ortağın kişisel malı (henüz katkı yapılmamış)
    branch_id UUID REFERENCES institution_branches(id) ON DELETE RESTRICT,
    asset_type SMALLINT NOT NULL,
    asset_name VARCHAR(200) NOT NULL,
    description TEXT,
    title_deed_no VARCHAR(100),
    plate_number VARCHAR(20),
    serial_number VARCHAR(100),
    address TEXT,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    acquisition_value DECIMAL(18, 8) NOT NULL CHECK (acquisition_value > 0),
    acquisition_currency SMALLINT NOT NULL,
    acquisition_date DATE NOT NULL,
    current_book_value DECIMAL(18, 8) NOT NULL CHECK (current_book_value >= 0),
    fixed_asset_status SMALLINT NOT NULL DEFAULT 0,
    disposal_reason TEXT,
    disposed_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    registered_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_fa_single_owner CHECK (num_nonnulls(owner_institution_id, owner_user_id) = 1),
    CONSTRAINT chk_fa_branch_needs_institution CHECK (branch_id IS NULL OR owner_institution_id IS NOT NULL),
    CONSTRAINT chk_fa_disposal_reason_required CHECK (fixed_asset_status NOT IN (2, 3, 4) OR disposal_reason IS NOT NULL));
CREATE INDEX IF NOT EXISTS idx_fixed_assets_owner_institution ON fixed_assets(owner_institution_id) WHERE owner_institution_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fixed_assets_owner_user ON fixed_assets(owner_user_id) WHERE owner_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fixed_assets_branch ON fixed_assets(branch_id) WHERE branch_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fixed_assets_type ON fixed_assets(asset_type);

-- Mal varliklarin evrak kayitlarini tutar
CREATE TABLE IF NOT EXISTS fixed_asset_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fixed_asset_id UUID NOT NULL REFERENCES fixed_assets(id) ON DELETE RESTRICT,
    media_asset_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT, -- MinIO fiziksel dosyaya media_asset_storage_refs (19) üzerinden bağlanır
    uploaded_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    document_type SMALLINT NOT NULL,        -- enum_fixed_asset_document_type
    document_title VARCHAR(200),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_fad_asset ON fixed_asset_documents(fixed_asset_id);
CREATE INDEX IF NOT EXISTS idx_fad_type ON fixed_asset_documents(fixed_asset_id, document_type);
COMMENT ON TABLE fixed_asset_documents IS
 'Tapu, ruhsat, ekspertiz raporu, sigorta poliçesi, fatura, sermaye katkı sözleşmesi gibi belgeler — gerçek dosya MinIO''da (media_assets + media_asset_storage_refs, bkz. 19. dosya), burada sadece bağlantı ve tip bilgisi tutulur.';

-- Mal varliklarin degerleme gecmisini tutar
CREATE TABLE IF NOT EXISTS fixed_asset_valuations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fixed_asset_id UUID NOT NULL REFERENCES fixed_assets(id) ON DELETE RESTRICT,
    valuation_amount DECIMAL(18, 8) NOT NULL CHECK (valuation_amount > 0),
    currency SMALLINT NOT NULL,
    valuation_date DATE NOT NULL,
    valuation_method VARCHAR(100),          -- 'BAĞIMSIZ EKSPERTİZ', 'PİYASA DEĞERİ', 'SİGORTA DEĞERİ' vb.
    appraiser_name VARCHAR(150),
    appraisal_document_id UUID NOT NULL REFERENCES fixed_asset_documents(id) ON DELETE RESTRICT,
    notes TEXT,
    recorded_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_fa_valuations_asset ON fixed_asset_valuations(fixed_asset_id, valuation_date DESC);

-- Sirket ortaklarinin varlik katki defteri
CREATE TABLE IF NOT EXISTS institution_capital_contributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    contributor_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    approval_id UUID REFERENCES approvals(id) ON DELETE RESTRICT,   -- NULL: kuruluş sermayesi
    contribution_type SMALLINT NOT NULL,        -- 0 = nakit (cüzdan), 1 = maddi varlık
    cash_amount DECIMAL(18, 8) CHECK (cash_amount > 0),
    cash_currency SMALLINT,
    fixed_asset_id UUID REFERENCES fixed_assets(id) ON DELETE RESTRICT,
    valuation_id UUID REFERENCES fixed_asset_valuations(id) ON DELETE RESTRICT, -- katkıda esas alınan değerleme
    contribution_value DECIMAL(18, 8) NOT NULL CHECK (contribution_value > 0), -- ortak para biriminde normalize değer
    valuation_currency SMALLINT NOT NULL,
    institution_capital_contribution_status SMALLINT NOT NULL DEFAULT 0, -- 0=PENDING, 1=ACTIVE, 2=CANCELLED, 3=RETURNED (enum'una göre uyarla)
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolution_notes TEXT,
    contributed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_icc_type_fields CHECK (
        (contribution_type = 0 AND cash_amount IS NOT NULL AND cash_currency IS NOT NULL
            AND fixed_asset_id IS NULL AND valuation_id IS NULL) OR
        (contribution_type = 1 AND fixed_asset_id IS NOT NULL AND valuation_id IS NOT NULL
            AND cash_amount IS NULL AND cash_currency IS NULL)));
CREATE INDEX IF NOT EXISTS idx_icc_institution_status ON institution_capital_contributions(institution_id, institution_capital_contribution_status);
CREATE INDEX IF NOT EXISTS idx_icc_contributor ON institution_capital_contributions(contributor_user_id);
CREATE INDEX IF NOT EXISTS idx_icc_approval ON institution_capital_contributions(approval_id) WHERE approval_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_icc_asset_open ON institution_capital_contributions(fixed_asset_id)
    WHERE fixed_asset_id IS NOT NULL AND institution_capital_contribution_status IN (0, 1);

-- Isden ayrilma ortakliktan cikis kurallarini belirler
CREATE TABLE IF NOT EXISTS institution_exit_settlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,           -- ayrılan kişi
    exit_kind SMALLINT NOT NULL,  
    governing_country_code SMALLINT NOT NULL,
    governing_region VARCHAR(50),                                              -- 0 = ÇALIŞAN AYRILIŞI, 1 = ORTAK AYRILIŞI
    worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    shareholder_id INTEGER REFERENCES institution_shareholders(id) ON DELETE RESTRICT,
    exit_approval_id UUID REFERENCES approvals(id) ON DELETE RESTRICT,          -- ortak çıkarma/ayrılma onayı
    currency SMALLINT NOT NULL,
    company_value_snapshot DECIMAL(18, 8) CHECK (company_value_snapshot >= 0),  -- ortak ayrılışında çıkış tarihindeki şirket değeri
    share_percentage_at_exit NUMERIC(9, 8) CHECK (share_percentage_at_exit > 0 AND share_percentage_at_exit <= 1),
    net_amount DECIMAL(18, 8) NOT NULL DEFAULT 0,       -- kalemlerin toplamı: (+) şirket ayrılana öder, (−) ayrılan şirkete öder
    settlement_status SMALLINT NOT NULL DEFAULT 0,      -- enum_settlement_status: 0=TASLAK, 1=SUNULDU, 2=İTİRAZLI, 3=ONAYLANDI, 4=ÖDENDİ, 5=İPTAL
    prepared_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    reviewed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    accepted_by_leaver_at TIMESTAMP WITH TIME ZONE,     -- ayrılanın hesabı kabul ettiği an
    release_media_asset_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT, -- imzalı ibraname / hesaplaşma belgesi
    settlement_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_ies_kind CHECK (
        (exit_kind = 0 AND worker_id IS NOT NULL AND shareholder_id IS NULL AND exit_approval_id IS NULL
            AND company_value_snapshot IS NULL AND share_percentage_at_exit IS NULL) OR
        (exit_kind = 1 AND shareholder_id IS NOT NULL AND worker_id IS NULL AND exit_approval_id IS NOT NULL
            AND company_value_snapshot IS NOT NULL AND share_percentage_at_exit IS NOT NULL)) );
CREATE INDEX IF NOT EXISTS idx_ies_institution_status ON institution_exit_settlements(institution_id, settlement_status);
CREATE INDEX IF NOT EXISTS idx_ies_user ON institution_exit_settlements(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_ies_open
    ON institution_exit_settlements(institution_id, user_id, exit_kind) WHERE settlement_status < 4;

-- Sirket ici veya Sirketler arasi anlasmazlik durumlarini tutar
CREATE TABLE IF NOT EXISTS disputes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_type VARCHAR(30) NOT NULL,    -- 'exit_settlement', ...
    subject_id UUID NOT NULL,
    governing_country_code SMALLINT NOT NULL,
    governing_region VARCHAR(50),
    process_rule_id INTEGER REFERENCES jurisdiction_rules(id) ON DELETE RESTRICT, -- uygulanan kuralın o günkü sürümü
    forum_type SMALLINT NOT NULL,         -- 0=ŞİRKET İÇ EKİBİ, 1=PLATFORM EKİBİ, 2=HAKEM HEYETİ, 3=DIŞ MERCİ (sadece kayıt)
    dispute_status SMALLINT NOT NULL DEFAULT 0, -- 0=BAŞVURU, 1=SAVUNMA, 2=ARABULUCULUK, 3=HAKEMLİK, 4=KARAR, 5=KAPANDI, 6=GERİ ÇEKİLDİ
    claimed_amount DECIMAL(18, 8) CHECK (claimed_amount >= 0),
    currency SMALLINT,                 
    description TEXT NOT NULL,
    filed_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    filed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    response_due_at TIMESTAMP WITH TIME ZONE,   -- başvuruda kuraldan hesaplanıp dondurulur, kural sonradan değişse etkilenmez
    decision_due_at TIMESTAMP WITH TIME ZONE,
    decided_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    escrow_id UUID,                              -- itiraz konusu tutarın bloke edildiği emanet kaydı
    escrow_created_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_dispute_escrow FOREIGN KEY (escrow_id, escrow_created_at)
        REFERENCES escrow_records (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_dispute_escrow_pair CHECK ((escrow_id IS NULL) = (escrow_created_at IS NULL)) );
CREATE INDEX IF NOT EXISTS idx_disputes_subject ON disputes(subject_type, subject_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_disputes_open ON disputes(subject_type, subject_id) WHERE dispute_status < 5;

-- Tum suraclerde davaci davali dava kayitlarinin birlesik belgesini tutar
CREATE TABLE IF NOT EXISTS dispute_parties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES disputes(id) ON DELETE RESTRICT,
    party_role SMALLINT NOT NULL,          -- 0=DAVACI, 1=DAVALI
    user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    CONSTRAINT chk_dp_party CHECK (num_nonnulls(user_id, institution_id) = 1) );
CREATE INDEX IF NOT EXISTS idx_dp_dispute ON dispute_parties(dispute_id);

-- Süreç günlüğü: başvuru, savunma, delil, süre uzatma, arabuluculuk, atama, karar (değiştirilmez, sadece eklenir)
CREATE TABLE IF NOT EXISTS dispute_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES disputes(id) ON DELETE RESTRICT,
    event_type SMALLINT NOT NULL,
    actor_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    note TEXT,
    media_asset_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,   -- delil / belge
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_de_dispute ON dispute_events(dispute_id, occurred_at);

CREATE TABLE IF NOT EXISTS dispute_arbitrators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES disputes(id) ON DELETE RESTRICT,
    arbitrator_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    panel_role SMALLINT NOT NULL DEFAULT 1,   -- 0=TEK HAKEM, 1=ÜYE, 2=BAŞKAN
    appointed_by SMALLINT NOT NULL,           -- 0=DAVACI, 1=DAVALI, 2=ORTAK ANLAŞMA, 3=PLATFORM
    conflict_checked_at TIMESTAMP WITH TIME ZONE,  -- tarafsızlık / çıkar çatışması kontrolü
    accepted_at TIMESTAMP WITH TIME ZONE,
    recused_at TIMESTAMP WITH TIME ZONE,
    recusal_reason TEXT,
    CONSTRAINT unq_dispute_arbitrator UNIQUE (dispute_id, arbitrator_user_id) );

CREATE TABLE IF NOT EXISTS dispute_awards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES disputes(id) ON DELETE RESTRICT,
    approval_id UUID REFERENCES approvals(id) ON DELETE RESTRICT,      -- hakem heyeti oylaması (genel onay motoru)
    decided_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT, -- tek karar vericide (ekip/tek hakem)
    outcome SMALLINT NOT NULL,                -- 0=TAMAMEN KABUL, 1=KISMEN KABUL, 2=RED
    awarded_amount DECIMAL(18, 8) CHECK (awarded_amount >= 0),
    currency SMALLINT,
    reasoning TEXT NOT NULL,
    award_media_asset_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT, -- imzalı karar belgesi
    appeal_deadline_at TIMESTAMP WITH TIME ZONE,
    is_final BOOLEAN NOT NULL DEFAULT FALSE,
    decided_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_award_decider CHECK (num_nonnulls(approval_id, decided_by_user_id) = 1) );
CREATE INDEX IF NOT EXISTS idx_awards_dispute ON dispute_awards(dispute_id);

-- Isden ayrilma surecinin kaydini tutar 
CREATE TABLE IF NOT EXISTS institution_exit_settlement_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    settlement_id UUID NOT NULL REFERENCES institution_exit_settlements(id) ON DELETE RESTRICT,
    line_type SMALLINT NOT NULL,   -- enum_settlement_line_type: 0=ÖDENMEMİŞ MAAŞ, 1=PRİM/KOMİSYON, 2=TAZMİNAT/İZİN, 3=BORÇ/AVANS KESİNTİSİ, 4=HİSSE BEDELİ, 5=AYNİ VARLIK İADESİ, 6=MANUEL DÜZELTME
    amount DECIMAL(18, 8) NOT NULL CHECK (amount <> 0),  -- (+) ayrılana ödenecek, (−) ayrılandan tahsil edilecek veya ayni iade ile karşılanan
    currency SMALLINT NOT NULL,
    jurisdiction_rule_id INTEGER REFERENCES jurisdiction_rules(id) ON DELETE RESTRICT,  -- hesapta kullanılan kural sürümü
    tax_rule_id INTEGER REFERENCES tax_rates_and_rules(id) ON DELETE RESTRICT,
    dispute_award_id UUID REFERENCES dispute_awards(id) ON DELETE RESTRICT,
    transaction_id UUID,
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_iesl_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_iesl_tx_pair CHECK ((transaction_id IS NULL) = (transaction_created_at IS NULL)),
    CONSTRAINT chk_iesl_tax CHECK (line_type <> 2 OR (tax_rule_id IS NOT NULL AND amount < 0)),
    position_id INTEGER REFERENCES worker_institution_positions(id) ON DELETE RESTRICT, -- maaş/prim kalemleri için
    contribution_id UUID REFERENCES institution_capital_contributions(id) ON DELETE RESTRICT,
    fixed_asset_id UUID REFERENCES fixed_assets(id) ON DELETE RESTRICT,
    valuation_id UUID REFERENCES fixed_asset_valuations(id) ON DELETE RESTRICT,         -- iade anındaki değerleme
    supporting_media_asset_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,      -- hesaplamaya dayanak belge
    due_date DATE,                 -- vadeli/taksitli ödemede
    settled_at TIMESTAMP WITH TIME ZONE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_iesl_asset_return CHECK (
        line_type <> 6 OR (fixed_asset_id IS NOT NULL AND valuation_id IS NOT NULL AND contribution_id IS NOT NULL)),
    CONSTRAINT chk_iesl_adjustment_note CHECK (line_type <> 7 OR description IS NOT NULL) );
CREATE INDEX IF NOT EXISTS idx_iesl_settlement ON institution_exit_settlement_lines(settlement_id);
CREATE INDEX IF NOT EXISTS idx_iesl_unsettled ON institution_exit_settlement_lines(due_date) WHERE settled_at IS NULL;

-- Isden ayrilma surecinde cuzdan sifirlama islemlerini tutar
CREATE TABLE IF NOT EXISTS institution_exit_wallet_sweeps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    settlement_id UUID NOT NULL REFERENCES institution_exit_settlements(id) ON DELETE RESTRICT,
    source_wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,       -- işçi cüzdanı (wallet_type 3)
    destination_wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,  -- kullanıcının kişisel cüzdanı (wallet_type 1)
    currency SMALLINT NOT NULL,
    swept_amount DECIMAL(18, 8) NOT NULL CHECK (swept_amount > 0),
    sweep_status SMALLINT NOT NULL DEFAULT 0,   -- 0=BEKLİYOR, 1=TAMAMLANDI, 2=ENGELLİ (açık hold/escrow var)
    transaction_id UUID,
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_iews_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_iews_tx_pair CHECK ((transaction_id IS NULL) = (transaction_created_at IS NULL)),
    CONSTRAINT chk_iews_wallets CHECK (source_wallet_id <> destination_wallet_id),
    CONSTRAINT unq_iews_source UNIQUE (settlement_id, source_wallet_id) );

-- Kullanicilarin oturum bilgilerini tutar
CREATE TABLE IF NOT EXISTS auth_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    token_jti UUID NOT NULL DEFAULT gen_random_uuid(),
    device_info TEXT,                   -- User-Agent / cihaz bilgisi
    ip_address VARCHAR(64),
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,  -- JWT'nin doğal bitişiyle AYNI olmalı (bugünkü 30 gün)
    last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    revoked_at TIMESTAMP WITH TIME ZONE,
    revoked_reason SMALLINT,            -- enum_revocation_reason
    revoked_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT ); -- FORCED_BY_ADMIN ise dolu
CREATE INDEX IF NOT EXISTS idx_auth_sessions_user ON auth_sessions(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_jti ON auth_sessions(token_jti) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_auth_sessions_active_window ON auth_sessions(user_id, issued_at, last_seen_at) WHERE is_active = true;
COMMENT ON TABLE auth_sessions IS
 'Her login ile bir satır açılır. Middleware her istekte token_jti''nin is_active=true olduğunu doğrulamalı (JWT tek başına yeterli kimlik kanıtı DEĞİLDİR — DB/Redis''teki oturum durumu esastır).';



COMMIT;

-- SADECE TEK BASINA LAZIM OLDUGUNDA KULLANILIR COMMIT ICERISINE ASLA EKLENMEMELI 
-- ACIKLAMA STATUSU DEGISTIRILMEMELI DROP SCHEMA IF EXISTS nolbir_flutter CASCADE; 