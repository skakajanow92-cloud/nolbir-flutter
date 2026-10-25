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
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_currency_code_format CHECK (currency_code ~ '^[A-Z]{2,10}$')
);

COMMENT ON TABLE supported_currencies IS 'Sistemde işlem görebilecek para birimlerinin TEK doğruluk kaynağı. Dinamik SQL üreten her fonksiyon, kolon adını kurmadan önce buraya karşı doğrulama yapmak ZORUNDADIR.';
COMMENT ON COLUMN supported_currencies.wallet_columns_provisioned IS 'true olmadan bu para birimiyle hiçbir cüzdan hareketi yapılamaz — kolonun fiziksel olarak var olduğunun garantisidir.';

-- Ulke bazli vergi kuruluslarinin tanimlamalarini tutar
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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gta_country ON government_tax_authorities(country_code);

COMMENT ON TABLE government_tax_authorities IS 'Ülkeden bağımsız, parametrik devlet/vergi dairesi tanım tablosu. Yeni ülke = yeni satır.';

-- Ulke bazli vergi kurallarini ve miktarini tutar
CREATE TABLE IF NOT EXISTS tax_rates_and_rules (
    id SERIAL PRIMARY KEY,                       -- Maps to 30 Vertical Marketplaces
    country_code VARCHAR(3) NOT NULL,                -- ISO 3166-1 alpha-3 (e.g., 'TUR', 'USA', 'DEU')
    state_or_region VARCHAR(50),                     -- For US states or specific tax zones
    tax_type VARCHAR(30) NOT NULL,                   -- 'VAT_KDV', 'WITHHOLDING_STOPAJ', 'STAMP_TAX', 'CORPORATE'
    category_code VARCHAR(50),                       -- Sub-category tax exemption or rate code
    tax_rate NUMERIC(5, 4) NOT NULL CHECK (tax_rate >= 0.0000 AND tax_rate <= 1.0000),
    is_withholding BOOLEAN DEFAULT FALSE,            -- If true, deducted at source during payouts
    is_active BOOLEAN DEFAULT TRUE,
    effective_from DATE NOT NULL,
    effective_until DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tax_effective_dates CHECK (effective_until IS NULL OR effective_until >= effective_from)
);

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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

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
        (debit_amount > 0 AND credit_amount = 0) OR (credit_amount > 0 AND debit_amount = 0)
    )
);

-- Sistemin gelir gider komisyon ve saire cuzdanlarini tutar
CREATE TABLE IF NOT EXISTS system_wallets (
    id SERIAL PRIMARY KEY,
    wallet_number VARCHAR(24) UNIQUE NOT NULL,
    wallet_purpose SMALLINT NOT NULL,
    currency SMALLINT NOT NULL DEFAULT 0, 
    balance DECIMAL(18, 8) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_system_wallet UNIQUE (currency, wallet_purpose)
);

-- ANA KULLANICI TABLOSU (Herhangi bir kullanici turu) ana kullanici bilgilerini tutar
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
    verified_type SMALLINT DEFAULT 0,
    identity_verified_by_admin_id INTEGER,
    identity_verification_method SMALLINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    identity_verified_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_users_birth_date_past CHECK (birth_date IS NULL OR birth_date <= CURRENT_DATE),
    CONSTRAINT chk_users_min_age CHECK (birth_date IS NULL OR birth_date <= CURRENT_DATE - INTERVAL '18 years')
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_lower ON users (lower(email));

-- Kullanicinin Ana cuzdanlarini tutar
CREATE TABLE IF NOT EXISTS user_wallets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    wallet_number VARCHAR(24) UNIQUE NOT NULL,
    currency SMALLINT NOT NULL DEFAULT 0, 
    balance DECIMAL(18, 8) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unq_user_currency UNIQUE (user_id, currency)
);

-- Sistemin Direk hesap acan Kurucularinin bilgilerini tutar
CREATE TABLE IF NOT EXISTS genesis_audit_log (
    id BIGSERIAL PRIMARY KEY,
    invoked_by_ip VARCHAR(64) NOT NULL,
    cert_fingerprint VARCHAR(128),
    action SMALLINT NOT NULL,
    target_user_id INTEGER REFERENCES users(id),
    modules_added SMALLINT[],
    success BOOLEAN NOT NULL,
    error_detail TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- MQTT kullanicisi bilgilerini temel kullanici ile esitler 
CREATE TABLE IF NOT EXISTS mqtt_acl (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    username VARCHAR(255) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    rw INT DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_topic UNIQUE (user_id, topic)
);

-- MQTT kullanicisini tanimlar 
CREATE TABLE IF NOT EXISTS mqtt_user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--  HOLDİNG ORTAKLIK / KURUCULAR YAPISI (N-Founder & Shareholders) ortaklarin bilgilerini tutar
CREATE TABLE IF NOT EXISTS system_shareholders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    share_percentage DECIMAL(5, 4) NOT NULL CHECK (share_percentage > 0 AND share_percentage <= 1.0000), -- Örn: 0.2500 = %25
    partner_type SMALLINT NOT NULL DEFAULT 0, -- enum_partner_type
    board_member BOOLEAN DEFAULT false, -- Yönetim Kurulunda oy hakkı var mı?
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Sistem ortaklarinin kar payi cuzdanlarini tutar
CREATE TABLE IF NOT EXISTS founder_wallets (
    id SERIAL PRIMARY KEY,
    shareholder_id INTEGER NOT NULL REFERENCES system_shareholders(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    wallet_number VARCHAR(24) UNIQUE NOT NULL,
    currency SMALLINT NOT NULL DEFAULT 0, 
    balance DECIMAL(18, 8) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_founder_currency UNIQUE (user_id, shareholder_id, currency)
);

-- WORKERS (ÇALIŞAN / KURUMSAL İŞ ORTAĞI) Alt sirketlerin yonetici calisan bilgilerini tutar
CREATE TABLE IF NOT EXISTS workers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    worker_name VARCHAR(20),
    is_verified BOOLEAN DEFAULT false,
    rating DECIMAL(3, 2) DEFAULT 5.00 CHECK (rating BETWEEN 0 AND 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Alt sirketlerde calisan yonetici olan kisilerin is cuzdanlarini tutar
CREATE TABLE IF NOT EXISTS worker_wallets (
    id SERIAL PRIMARY KEY,
    worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    wallet_number VARCHAR(24) UNIQUE NOT NULL,
    currency SMALLINT NOT NULL DEFAULT 0, 
    balance DECIMAL(18, 8) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unq_worker_currency UNIQUE (worker_id, currency)
);

-- ADMINLER (Profesyonel Yönetim & Yöneticiler) Sistemmin maasli calisan denetleyici bilgilerini tutar
CREATE TABLE IF NOT EXISTS admins (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    admin_name VARCHAR(20),
    admin_level INTEGER DEFAULT 1, -- 1-10 arası yönetici kademeleri
    permissions SMALLINT[] DEFAULT '{}',
    session_count BIGINT,
    total_active_duration INTERVAL,
    last_seen_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_admin_level CHECK (admin_level BETWEEN 1 AND 10)
);

-- Sistemin yonetici denetleyici elemanlarinin maas cuzdanlarini tutar
CREATE TABLE IF NOT EXISTS admin_wallets (
    id SERIAL PRIMARY KEY,
    admin_id INTEGER NOT NULL REFERENCES admins(id) ON DELETE RESTRICT,
    wallet_number VARCHAR(24) UNIQUE NOT NULL,
    currency SMALLINT NOT NULL DEFAULT 0, 
    balance DECIMAL(18, 8) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unq_admin_currency UNIQUE (admin_id, currency)
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM pg_constraint 
        WHERE conname = 'fk_users_identity_verified_by_admin'
    ) THEN
        ALTER TABLE users 
        ADD CONSTRAINT fk_users_identity_verified_by_admin 
        FOREIGN KEY (identity_verified_by_admin_id) 
        REFERENCES admins(id);
    END IF;
END $$;

-- Finansal islem kayitlarini tutar
CREATE TABLE IF NOT EXISTS transactions (
    id UUID DEFAULT gen_random_uuid(),
    trace_id UUID NOT NULL DEFAULT gen_random_uuid(), -- UNIQUE kaldırıldı, aşağıda bileşik kısıtlama olarak eklendi
    sender_internal_id INTEGER, 
    sender_type SMALLINT NOT NULL, -- 0=USER, 1=WORKER, 2=ADMIN, 3=SYSTEM, 4=SHAREHOLDER
    sender_root_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    receiver_internal_id INTEGER,
    receiver_type SMALLINT NOT NULL, -- 0=USER, 1=WORKER, 2=ADMIN, 3=SYSTEM, 4=SHAREHOLDER
    receiver_root_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    sender_system_wallet_id INTEGER REFERENCES system_wallets(id) ON DELETE RESTRICT,
    receiver_system_wallet_id INTEGER REFERENCES system_wallets(id) ON DELETE RESTRICT,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount >= 0),
    fee_amount DECIMAL(18, 8) DEFAULT 0 CHECK (fee_amount >= 0),
    currency SMALLINT NOT NULL DEFAULT 0,
    tx_type SMALLINT NOT NULL,
    transaction_status SMALLINT DEFAULT 0,
    transaction_metadata JSONB, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_transactions PRIMARY KEY (id, created_at),
    CONSTRAINT uk_transactions_trace_id UNIQUE (trace_id, created_at),
    CONSTRAINT chk_tx_sender_ref CHECK (
        (sender_type IN (0, 1, 2, 4, 5) AND sender_internal_id IS NOT NULL
        AND sender_root_user_id IS NOT NULL AND sender_system_wallet_id IS NULL)
        OR
        (sender_type = 3 AND sender_system_wallet_id IS NOT NULL
        AND sender_internal_id IS NULL AND sender_root_user_id IS NULL)
    ),
    CONSTRAINT chk_tx_receiver_ref CHECK (
        (receiver_type IN (0, 1, 2, 4, 5) AND receiver_internal_id IS NOT NULL
        AND receiver_root_user_id IS NOT NULL AND receiver_system_wallet_id IS NULL)
        OR
        (receiver_type = 3 AND receiver_system_wallet_id IS NOT NULL
        AND receiver_internal_id IS NULL AND receiver_root_user_id IS NULL)
    )
) PARTITION BY RANGE (created_at);

-- DEFAULT PARTITION
CREATE TABLE IF NOT EXISTS transactions_default 
    PARTITION OF transactions DEFAULT;

-- GERÇEK PARTITION'LAR
CREATE TABLE IF NOT EXISTS transactions_2026 
    PARTITION OF transactions 
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

CREATE INDEX IF NOT EXISTS idx_tx_root_user ON transactions(sender_root_user_id);
CREATE INDEX IF NOT EXISTS idx_tx_receiver_root ON transactions(receiver_root_user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_sender_status_created 
    ON transactions (sender_root_user_id, transaction_status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_metadata_gin 
    ON transactions USING gin (transaction_metadata);

-- Kullanicilarin anonimlestirme bilgilerini tutar
CREATE TABLE IF NOT EXISTS gdpr_anonymization_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(id),
    request_type SMALLINT DEFAULT 0,                 -- 0=ANONYMIZE_PII, 1=EXPORT_DATA, 2=RESTRICT_PROCESSING
    reason TEXT,
    gdpr_anonymization_request_status SMALLINT DEFAULT 0,-- 0=PENDING, 1=APPROVED, 2=PROCESSING, 3=COMPLETED, 4=REJECTED
    approved_by_admin_id INTEGER REFERENCES admins(id),
    anonymized_fields JSONB DEFAULT '[]'::jsonb,     -- Audit list of fields scrubbed
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gdpr_user_status ON gdpr_anonymization_requests (user_id, gdpr_anonymization_request_status);

COMMENT ON TABLE gdpr_anonymization_requests IS 'GDPR/KVKK Right-to-be-Forgotten request tracking and audit log.';

-- Sistemin farkli durumlarini yonetmek icin hizli yonetim bayraklari tutar
CREATE TABLE IF NOT EXISTS system_feature_flags (
    id SERIAL PRIMARY KEY,
    feature_key VARCHAR(100) UNIQUE NOT NULL,-- e.g., 'WITHDRAWAL_ENABLED', 'B2B_EXCHANGE_ACTIVE'
    is_enabled BOOLEAN DEFAULT TRUE,
    rules_json JSONB DEFAULT '{}'::jsonb,           -- Granular controls (e.g., {"max_tx_limit": 5000})
    description TEXT,
    updated_by_admin_id INTEGER REFERENCES admins(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_feature_flags_key ON system_feature_flags (feature_key);

COMMENT ON TABLE system_feature_flags IS 'Dynamic kill-switches and operational feature toggles for high availability.';

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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Adminler tarafindan kullanici dogrulama bilgilerini tutar
CREATE TABLE IF NOT EXISTS identity_verification_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    admin_id INTEGER NOT NULL REFERENCES admins(id),
    verification_method SMALLINT NOT NULL,
    scheduled_at TIMESTAMP WITH TIME ZONE,
    conducted_at TIMESTAMP WITH TIME ZONE,
    recording_media_id UUID REFERENCES media_assets(id),
    identity_verification_session_status SMALLINT NOT NULL DEFAULT 0,
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ivs_live_call_needs_recording CHECK (
        NOT (verification_method = 1 AND identity_verification_session_status = 1 AND recording_media_id IS NULL)
    )
);


-- ANA KURUM / ŞİRKET TABLOSU Sistemin Alt sirketlerinin bilgilerini tutar
-- ANA KURUM / ŞİRKET TABLOSU: Sistemdeki tüm bağımsız tüzel kişiliklerin (ilk platform kurumu dahil) bilgilerini tutar
CREATE TABLE IF NOT EXISTS institutions (
    id SERIAL PRIMARY KEY,
    owner_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    institution_name VARCHAR(150) NOT NULL,
    tax_number VARCHAR(50) UNIQUE NOT NULL,
    tax_office VARCHAR(100),
    country_code SMALLINT NOT NULL, -- Veya ISO alpha-3 için VARCHAR(3) tercih edilebilir
    registration_number VARCHAR(50),
    
    -- Kurumsal evraklar (Medya varlıkları)
    incorporation_contract_media_id UUID REFERENCES media_assets(id),
    trade_registry_gazette_media_id UUID REFERENCES media_assets(id),
    
    -- Kurum içi karar ve oylama eşiği (Örn: %50 veya %75 çoğunluk)
    board_approval_threshold DECIMAL(5,4) NOT NULL DEFAULT 0.5000
        CHECK (board_approval_threshold > 0 AND board_approval_threshold <= 1.0000),
    
    -- Doğrulama ve Onay Bilgileri (Eski admins referansı workers tablosuna uyarlandı)
    is_verified BOOLEAN DEFAULT false,
    verified_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT, -- Doğrulayan platform yöneticisi/çalışanı
    
    -- Yasal ve Operasyonel Durum / Güvenlik Kontrolleri (Compliance & Freeze)
    is_active BOOLEAN NOT NULL DEFAULT true,
    compliance_status SMALLINT NOT NULL DEFAULT 1, -- 1: ACTIVE, 2: SUSPENDED_TEMP (Geçici dondurulan), 3: BANNED_PERMANENT (İhraç)
    suspension_reason TEXT,                       -- Şüpheli işlem / yasal inceleme gerekçesi
    suspended_at TIMESTAMP WITH TIME ZONE,        -- Dondurulma tarihi
    suspended_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT, -- Donduran yetkili
    
    -- Zaman Damgaları
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Hızlı aramalar ve indeksler
CREATE INDEX IF NOT EXISTS idx_institutions_compliance ON institutions(compliance_status);
CREATE INDEX IF NOT EXISTS idx_institutions_tax ON institutions(tax_number);

-- Sirketlerin lisans turlerini tutar
CREATE TABLE IF NOT EXISTS institution_licenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    license_number VARCHAR(100) NOT NULL,
    license_type SMALLINT NOT NULL, -- Lisans Türü
    license_document_media_id UUID REFERENCES media_assets(id), -- Lisans Belgesi / PDF
    issued_by_authority VARCHAR(150), -- Lisansı Veren Resmi Kurum / Devlet Makamı
    issued_at DATE NOT NULL,
    expires_at DATE NOT NULL, -- Lisans Son Geçerlilik Tarihi
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_license_dates CHECK (expires_at > issued_at)
);

CREATE INDEX IF NOT EXISTS idx_licenses_institution ON institution_licenses(institution_id);

-- Alt sirketlerin kurumsal cuzdanlarini tutar
CREATE TABLE IF NOT EXISTS institution_wallets (
    id SERIAL PRIMARY KEY,
    institution_id INTEGER  NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    wallet_number VARCHAR(24) UNIQUE NOT NULL,
    currency SMALLINT NOT NULL DEFAULT 0, 
    balance DECIMAL(18, 8) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unq_institution_currency UNIQUE (institution_id, currency)
);

-- Alt sirketlerin performans bilgilerini tutar
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
    notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_sla_violated ON institution_sla_metrics (is_violated) WHERE is_violated IS TRUE;

COMMENT ON TABLE institution_sla_metrics IS 'Operational SLA compliance records and automatic penalty calculations.';

-- Alt Sirketlerin Sube listelerini tutar
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
    verified_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,            
    verified_at TIMESTAMP WITH TIME ZONE,                                             
    rejection_reason TEXT,                                                            
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_institution_branch_code UNIQUE (institution_id, branch_code)
);

CREATE INDEX IF NOT EXISTS idx_branches_institution ON institution_branches(institution_id);
CREATE INDEX IF NOT EXISTS idx_branches_pending ON institution_branches(verification_status) WHERE verification_status = 0;

-- Alt Sirketlerin kendi arasinda is birligi bilgilerini tutar
CREATE TABLE IF NOT EXISTS collaboration_agreements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agreement_code VARCHAR(50) UNIQUE NOT NULL, -- Örn: 'TOUR-PACKAGE-2026-SUMMER'
    agreement_name VARCHAR(150) NOT NULL,       -- "Yaz 2026 Her Şey Dahil Tur Paketi"
    holding_platform_fee_pct DECIMAL(5, 4) DEFAULT 0.0500, -- Platformun (sizin holdingin) alacağı garanti taban komisyon (%5)
    collaboration_agreement_status SMALLINT NOT NULL DEFAULT 1,         -- 0=DRAFT, 1=ACTIVE, 2=EXPIRED, 3=SUSPENDED
    collaboration_agreement_start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    collaboration_agreement_end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    agreement_document_media_id UUID REFERENCES media_assets(id), -- Sözleşme PDF'i
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_agreement_dates CHECK (collaboration_agreement_end_date > collaboration_agreement_start_date)
);

-- Sozlesmelere taraf olan sirketlerin bilgilerini tutar
CREATE TABLE IF NOT EXISTS collaboration_parties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agreement_id UUID NOT NULL REFERENCES collaboration_agreements(id) ON DELETE RESTRICT,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    party_role SMALLINT NOT NULL, -- 0=PLATFORM/HOLDING, 1=AGENCY (Aracı), 2=HOTEL (Otel), 3=TRANSPORT (Ulaşım), 4=INSURANCE (Sigorta)
    calculation_type SMALLINT NOT NULL, -- 0=PERCENTAGE (Genel yüzde), 1=FIXED_AMOUNT (Sabit tutar), 2=PER_UNIT_OR_KM (Kilometre veya birim başı tutar)
    share_value DECIMAL(18, 8) NOT NULL CHECK (share_value >= 0), -- Yüzde ise örn: 0.3000 (%30), KM başı ise örn: 12.5000 (Birim fiyat)
    min_payout_amount DECIMAL(18, 8) DEFAULT 0.00, -- Bu tarafa ödenecek minimum tutar sınırı
    max_payout_amount DECIMAL(18, 8),              -- Bu tarafın alabileceği maksimum üst sınır (Cap)
    metadata JSONB, -- Kilometre çarpanı formülü, özel vergi oranları vb. esnek parametreler için
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_agreement_institution UNIQUE (agreement_id, institution_id)
);

-- Alt sirketler arasi kampanya promosyonlarini tanimlar
CREATE TABLE IF NOT EXISTS promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issuer_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT, -- Boş ise sistem geneli kampanyadır
    collaboration_id UUID REFERENCES collaboration_agreements(id) ON DELETE RESTRICT, -- Bir B2B işbirliğine bağlı ise
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
    min_user_reputation_score DECIMAL(3, 2) DEFAULT 1.00 CHECK (min_user_reputation_score BETWEEN 1.00 AND 5.00), -- Menşe app_id'deki min ortalama puanı
    required_user_badge_level VARCHAR(50), -- Örn: 'VIP_TRAVELER', 'TOP_CUSTOMER' vb.
    max_total_uses INTEGER CHECK (max_total_uses > 0), -- Kampanya genel kullanım limiti
    current_uses INTEGER DEFAULT 0 CHECK (current_uses >= 0),
    max_uses_per_user INTEGER DEFAULT 1 CHECK (max_uses_per_user > 0),
    promotion_starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
    promotion_expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_promo_dates CHECK (promotion_expires_at > promotion_starts_at)
);

CREATE INDEX IF NOT EXISTS idx_promotions_code ON promotions(campaign_code);

-- Promosyon kullanim bilgilerini loglarii tutar
CREATE TABLE IF NOT EXISTS promotion_redemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    promotion_id UUID NOT NULL REFERENCES promotions(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    redeemed_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT, -- İndirimin kullanıldığı kurum
    transaction_id UUID NOT NULL,
    transaction_created_at TIMESTAMP WITH TIME ZONE NOT NULL, -- Bağlı finansal işlem kaydı
    applied_discount_amount DECIMAL(18, 8) NOT NULL CHECK (applied_discount_amount >= 0),
    currency SMALLINT DEFAULT 0,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_redemption_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_redemptions_promo ON promotion_redemptions(promotion_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_user ON promotion_redemptions(user_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_inst ON promotion_redemptions(redeemed_institution_id);

-- Alt sirketlerin kendi aralarindaki konsortiumlari tanimlar
CREATE TABLE IF NOT EXISTS consortiums (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consortium_name VARCHAR(150) NOT NULL,
    consortium_code VARCHAR(50) UNIQUE NOT NULL, -- Örn: FLEET_SHARE_APP29, BANK_LIQUIDITY_APP1
    consortium_type SMALLINT NOT NULL DEFAULT 0, -- enum_consortium_type
    lead_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT, -- Konsorsiyum Lideri / Yönetici Kurum
    consortium_description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_consortiums_code ON consortiums(consortium_code);

-- Konsortsyuma uyelik bilgilerini turlerini belirler
CREATE TABLE IF NOT EXISTS consortium_members (
    id SERIAL PRIMARY KEY,
    consortium_id UUID NOT NULL REFERENCES consortiums(id) ON DELETE RESTRICT,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    role_title VARCHAR(100) DEFAULT 'MEMBER', -- 'FOUNDER', 'MEMBER', 'RESOURCE_PROVIDER'
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT unq_consortium_institution UNIQUE (consortium_id, institution_id)
);

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
    CONSTRAINT chk_pool_capacity CHECK (available_capacity <= total_capacity)
);

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
    CONSTRAINT chk_b2b_dates CHECK (valid_until > valid_from)
);

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
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_cru_consumer ON consortium_resource_usage(consumer_institution_id);
CREATE INDEX IF NOT EXISTS idx_cru_transaction ON consortium_resource_usage(transaction_id);

-- Alt sirketlerin vergi hesaplarini tutar
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
    CONSTRAINT unq_institution_tax_authority_currency UNIQUE (institution_id, government_tax_authority_id, currency)
);

CREATE INDEX IF NOT EXISTS idx_igta_institution ON institution_government_tax_accounts(institution_id);
CREATE INDEX IF NOT EXISTS idx_igta_authority ON institution_government_tax_accounts(government_tax_authority_id);

COMMENT ON TABLE institution_government_tax_accounts IS 'Kurumun, kendi ülkesindeki devlete karşı tuttuğu vergi tahakkuk/tahsilat hesabı. Gerçek para hareketi değil, muhasebe bakiyesidir.';

-- Alt sirketlerin vergi tahakkuk hesaplarini tutar
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
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_tax_accruals_account ON tax_accruals(institution_government_tax_account_id);
CREATE INDEX IF NOT EXISTS idx_tax_accruals_transaction ON tax_accruals(transaction_id);

COMMENT ON TABLE tax_accruals IS 'Append-only vergi tahakkuk kayıtları — her satır bir işlemden doğan vergiyi temsil eder.';

-- Alt sirketlerin devletlere yapilan vergi odemelerini tutar
CREATE TABLE IF NOT EXISTS government_tax_remittances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_government_tax_account_id UUID NOT NULL REFERENCES institution_government_tax_accounts(id) ON DELETE RESTRICT,
    real_world_account_id INTEGER NOT NULL REFERENCES real_world_accounts(id) ON DELETE RESTRICT, -- ödemenin çıktığı gerçek banka hesabı
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    currency SMALLINT NOT NULL,
    remittance_reference VARCHAR(100),                 -- devlete yapılan ödeme dekont/referans no
    journal_entry_id UUID REFERENCES journal_entries(id) ON DELETE RESTRICT,
    issued_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    issued_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    government_tax_remittance_status SMALLINT NOT NULL DEFAULT 1,                -- enum_tax_remittance_status
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gtr_tax_account ON government_tax_remittances(institution_government_tax_account_id);
CREATE INDEX IF NOT EXISTS idx_gtr_status ON government_tax_remittances(government_tax_remittance_status);

COMMENT ON TABLE government_tax_remittances IS 'Kurumdan devlete fiilen yapılan vergi ödeme fişleri.';

-- Alt sirketlerin esik degerlerini tutar
CREATE TABLE IF NOT EXISTS institution_privilege_tiers (
    id SERIAL PRIMARY KEY,
    category_code SMALLINT,                    -- NULL = app geneli
    tier_code VARCHAR(50) NOT NULL,              -- 'FEATURED_ELIGIBLE','PRIORITY_SUPPORT','RELAXED_REVIEW_WINDOW' vb.
    basis SMALLINT NOT NULL DEFAULT 0,           -- enum_privilege_basis
    min_threshold DECIMAL(5, 2) NOT NULL,        -- örn. 4.70 (average_score) ya da 90.00 (compliance_score)
    min_rating_count INTEGER NOT NULL DEFAULT 0 CHECK (min_rating_count >= 0), -- istatistiksel anlamlılık için taban
    effect_json JSONB NOT NULL DEFAULT '{}'::jsonb,  -- örn. {"featured_boost": true, "commission_discount_bps": 50}
    description TEXT NOT NULL,                   -- ZORUNLU: gerekçe her zaman herkese açık okunabilir olmalı
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_privilege_tier UNIQUE (category_code, tier_code)
);

CREATE INDEX IF NOT EXISTS idx_privilege_tiers_lookup ON institution_privilege_tiers(category_code, is_active);

-- Alt sirketlerin tanimli esik bazinda skorlarini tutar
CREATE TABLE IF NOT EXISTS institution_privilege_grants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    category_code SMALLINT,
    tier_id INTEGER NOT NULL REFERENCES institution_privilege_tiers(id) ON DELETE RESTRICT,
    achieved_score DECIMAL(5, 2) NOT NULL,        -- grant anındaki gerçek skor (kanıt)
    achieved_rating_count INTEGER NOT NULL,
    is_current BOOLEAN NOT NULL DEFAULT true,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP WITH TIME ZONE                -- skor eşiğin altına düşerse doldurulur
);

CREATE INDEX IF NOT EXISTS idx_privilege_grants_institution ON institution_privilege_grants(institution_id, is_current);
CREATE INDEX IF NOT EXISTS idx_privilege_grants_tier ON institution_privilege_grants(tier_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_current_privilege_grant
ON institution_privilege_grants (institution_id, tier_id) WHERE is_current = true;

-- Alt sirket kurma basvuru bilgilerini tutar
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
    reviewed_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    rejection_reason TEXT,
    created_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_ifa_rejection_reason CHECK (institution_formation_application_status <> 2 OR rejection_reason IS NOT NULL)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_ifa_pending_tax_number
    ON institution_formation_applications (tax_number) WHERE institution_formation_application_status = 0;
CREATE INDEX IF NOT EXISTS idx_ifa_applicant ON institution_formation_applications(applicant_user_id);
CREATE INDEX IF NOT EXISTS idx_ifa_pending ON institution_formation_applications(institution_formation_application_status) WHERE institution_formation_application_status = 0;

-- Atl sirkete sube acma bilgilerini tutar
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
    reviewed_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    rejection_reason TEXT,
    created_branch_id UUID REFERENCES institution_branches(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_iba_rejection_reason CHECK (institution_branch_application_status <> 2 OR rejection_reason IS NOT NULL)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_iba_pending_branch_code
    ON institution_branch_applications (institution_id, branch_code) WHERE institution_branch_application_status = 0;
CREATE INDEX IF NOT EXISTS idx_iba_institution ON institution_branch_applications(institution_id);
CREATE INDEX IF NOT EXISTS idx_iba_pending ON institution_branch_applications(institution_branch_application_status) WHERE institution_branch_application_status = 0;

--  Calisanlarin sirketlerdeki pozisyonlarini tutar
CREATE TABLE IF NOT EXISTS worker_institution_positions (
    id SERIAL PRIMARY KEY,
    worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    institution_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    position_type SMALLINT NOT NULL DEFAULT 0,
    is_board_member BOOLEAN NOT NULL DEFAULT false,  -- YENİ: kurumun KENDİ yönetim kurulu oy hakkı
    equity_percentage DECIMAL(5, 4) DEFAULT 0.0000 CHECK (equity_percentage >= 0 AND equity_percentage <= 1.0000),
    monthly_salary DECIMAL(18, 8) DEFAULT 0.00 CHECK (monthly_salary >= 0),
    commission_rate DECIMAL(5, 4) DEFAULT 0.0000 CHECK (commission_rate >= 0 AND commission_rate <= 1.0000),
    currency SMALLINT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wip_worker ON worker_institution_positions(worker_id);
CREATE INDEX IF NOT EXISTS idx_wip_institution ON worker_institution_positions(institution_worker_id);
CREATE INDEX IF NOT EXISTS idx_wip_institution_board ON worker_institution_positions(institution_id) WHERE is_board_member = true;

-- Alt sirket calisanlari ve yoneticileri icin yetki sinirlarini tutar
CREATE TABLE IF NOT EXISTS worker_permission_catalog (
    id SERIAL PRIMARY KEY,
    permission_key VARCHAR(100) UNIQUE NOT NULL,          -- 'VIEW_FULL_LEDGER','VERIFY_CUSTOMER_QR' vb.
    screen_key VARCHAR(100) NOT NULL,               -- Flutter route/ekran anahtarı
    description TEXT NOT NULL,
    is_sensitive BOOLEAN NOT NULL DEFAULT false,             -- finansal/bilanço görünürlüğü gibi hassas erişim
    is_default_for_employee BOOLEAN NOT NULL DEFAULT false,  -- SALARIED/COMMISSION worker'a otomatik verilir mi
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_permission_catalog_app ON worker_permission_catalog(is_active);

-- Alt sirket calisanlarinin ve yoneticilerinin yetki kayitlarini tutar
CREATE TABLE IF NOT EXISTS worker_position_permissions (
    id SERIAL PRIMARY KEY,
    position_id INTEGER NOT NULL REFERENCES worker_institution_positions(id) ON DELETE RESTRICT,
    permission_id INTEGER NOT NULL REFERENCES worker_permission_catalog(id) ON DELETE RESTRICT,
    granted_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT, -- NULL = sistem varsayılan ataması
    is_active BOOLEAN NOT NULL DEFAULT true,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP WITH TIME ZONE,
    revoked_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    CONSTRAINT unq_position_permission UNIQUE (position_id, permission_id)
);

CREATE INDEX IF NOT EXISTS idx_wpp_position_active ON worker_position_permissions(position_id) WHERE is_active = true;

-- VOUCHERS & WITHDRAWALS Sistemin ana para giris cikis tablolari
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'voucher_batch_seq') THEN 
        CREATE SEQUENCE voucher_batch_seq START WITH 1; 
    END IF; 
END $$;

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
    CONSTRAINT chk_voucher_state CHECK (NOT (is_used = true AND is_cancelled = true))
);

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
    completed_at TIMESTAMP WITH TIME ZONE
);

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
    CONSTRAINT unique_app_rate_per_type UNIQUE (currency, user_type, tx_type)
);

-- Doviz ceviri arbitraj bilgilerini tutar 
CREATE TABLE IF NOT EXISTS currency_exchange_rates (
    id BIGSERIAL PRIMARY KEY,
    base_currency SMALLINT NOT NULL,            -- e.g., 'USD', 'EUR'
    target_currency SMALLINT NOT NULL,          -- e.g., 'TRY', 'JPY'
    exchange_rate NUMERIC(18, 8) NOT NULL CHECK (exchange_rate > 0),
    source VARCHAR(50) DEFAULT 'CENTRAL_BANK',     -- 'ECB', 'TCMB', 'BINANCE', 'REFINITIV'
    metadata JSONB DEFAULT '{}'::jsonb,            -- Raw API response / telemetry
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_currency_pair_time UNIQUE (base_currency, target_currency, fetched_at)
);

CREATE INDEX IF NOT EXISTS idx_exchange_rates_lookup 
    ON currency_exchange_rates (base_currency, target_currency, fetched_at DESC);

COMMENT ON TABLE currency_exchange_rates IS 'Real-time and historical currency exchange rates for cross-market ledger accounting.';

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
    CONSTRAINT chk_commission_min_max CHECK (max_commission_amount IS NULL OR min_commission_amount IS NULL OR max_commission_amount >= min_commission_amount)
);

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
    system_wallet_id INTEGER REFERENCES system_wallets(id) ON DELETE RESTRICT,  -- hangi komisyon havuzuna gitti
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_commission_charged_ref CHECK (
        (charged_user_id IS NOT NULL AND charged_worker_id IS NULL AND charged_institution_id IS NULL) OR
        (charged_worker_id IS NOT NULL AND charged_user_id IS NULL AND charged_institution_id IS NULL) OR
        (charged_institution_id IS NOT NULL AND charged_user_id IS NULL AND charged_worker_id IS NULL)
    ),
    CONSTRAINT fk_txcommission_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_txcommission_transaction ON transaction_commissions(transaction_id);

-- Sistemin Alt sirketler icin kural setini tutar
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
    CONSTRAINT unq_operating_rule UNIQUE (category_code, rule_key)
);

CREATE INDEX IF NOT EXISTS idx_operating_rules_lookup ON institution_operating_rules(category_code, is_active);

-- Alt sirketlerin kural seti loglarini tutar
CREATE TABLE IF NOT EXISTS institution_compliance_checks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    branch_id UUID REFERENCES institution_branches(id) ON DELETE RESTRICT,
    rule_id INTEGER NOT NULL REFERENCES institution_operating_rules(id) ON DELETE RESTRICT,
    check_result SMALLINT NOT NULL,                        -- enum_compliance_result
    details JSONB DEFAULT '{}'::jsonb,
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_compliance_institution ON institution_compliance_checks(institution_id, checked_at DESC);
CREATE INDEX IF NOT EXISTS idx_compliance_result ON institution_compliance_checks(check_result) WHERE check_result <> 0;

-- Blokeli ortak guvence hesaplarini tutar
CREATE TABLE IF NOT EXISTS escrow_records (
    id UUID DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL,
    transaction_created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    payer_type SMALLINT NOT NULL, -- 0=USER, 1=WORKER, 2=ADMIN, 3=SYSTEM, 4=SHAREHOLDER, 5=INSTITUTION
    payer_internal_id INTEGER,
    payer_root_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    payer_system_wallet_id INTEGER REFERENCES system_wallets(id) ON DELETE RESTRICT,
    payee_type SMALLINT NOT NULL, -- 0=USER, 1=WORKER, 2=ADMIN, 3=SYSTEM, 4=SHAREHOLDER, 5=INSTITUTION
    payee_internal_id INTEGER,
    payee_root_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    payee_system_wallet_id INTEGER REFERENCES system_wallets(id) ON DELETE RESTRICT,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount >= 0),
    system_commission_amount DECIMAL(18, 8) DEFAULT 0.00 CHECK (system_commission_amount >= 0),
    net_payee_amount DECIMAL(18, 8) NOT NULL CHECK (net_payee_amount >= 0),
    currency SMALLINT NOT NULL DEFAULT 0, -- Transactions tablosuyla uyumlu SMALLINT enum
    status SMALLINT DEFAULT 0, -- 0=LOCKED/PENDING (Blokede), 1=RELEASED (Serbest bırakıldı/Ödendi), 2=REFUNDED (İade edildi), 3=DISPUTED (İtiraz/Uyuşmazlık)
    metadata JSONB, 
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_escrow_records PRIMARY KEY (id, created_at),
    CONSTRAINT fk_escrow_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_escrow_payer_ref CHECK (
        (payer_type IN (0, 1, 2, 4, 5) AND payer_internal_id IS NOT NULL AND payer_system_wallet_id IS NULL)
        OR
        (payer_type = 3 AND payer_system_wallet_id IS NOT NULL AND payer_internal_id IS NULL)
    ),
    CONSTRAINT chk_escrow_payee_ref CHECK (
        (payee_type IN (0, 1, 2, 4, 5) AND payee_internal_id IS NOT NULL AND payee_system_wallet_id IS NULL)
        OR
        (payee_type = 3 AND payee_system_wallet_id IS NOT NULL AND payee_internal_id IS NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_escrow_payer_root ON escrow_records(payer_root_user_id);
CREATE INDEX IF NOT EXISTS idx_escrow_payee_root ON escrow_records(payee_root_user_id);
CREATE INDEX IF NOT EXISTS idx_escrow_status ON escrow_records(status);
CREATE INDEX IF NOT EXISTS idx_escrow_metadata_gin ON escrow_records USING gin (metadata);

-- Cuzdanlarda hizli on bloke tutarlarini tutar
CREATE TABLE IF NOT EXISTS wallet_holds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    holder_type SMALLINT NOT NULL, -- 0=USER, 1=WORKER, 2=ADMIN, 3=SYSTEM, 4=SHAREHOLDER, 5=INSTITUTION
    holder_internal_id INTEGER,
    holder_root_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    holder_system_wallet_id INTEGER REFERENCES system_wallets(id) ON DELETE RESTRICT,
    amount DECIMAL(18,8) NOT NULL CHECK (amount > 0),
    currency SMALLINT NOT NULL DEFAULT 0, -- Diğer tablolarla uyumlu SMALLINT enum
    purpose SMALLINT NOT NULL, -- 1=AUCTION_BID (Açık artırma teklifi), 2=ORDER_CHECKOUT (Sipariş rezervasyonu), 3=BULK_FEED_HOLD (Hammadde/Yem siparişi), 4=SERVICE_RESERVATION
    reference_type VARCHAR(30) NOT NULL, -- İlgili tablo adı (Örn: 'auctions', 'orders', 'raw_material_requests')
    reference_id UUID NOT NULL, -- İlgili tablonun ID'si
    wallet_hold_status SMALLINT NOT NULL DEFAULT 0, -- 0=ACTIVE/HELD (Blokede), 1=CAPTURED (Tahsil edildi/Başarılı), 2=RELEASED (Serbest bırakıldı/İptal), 3=EXPIRED (Süresi doldu)
    metadata JSONB, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE, -- Blokajın otomatik düşeceği son tarih
    resolved_at TIMESTAMP WITH TIME ZONE, -- Çözümlendiği (captured/released) tarih
    CONSTRAINT chk_wallet_hold_holder_ref CHECK (
        (holder_type IN (0, 1, 2, 4, 5) AND holder_internal_id IS NOT NULL AND holder_system_wallet_id IS NULL)
        OR
        (holder_type = 3 AND holder_system_wallet_id IS NOT NULL AND holder_internal_id IS NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_wallet_holds_holder ON wallet_holds(holder_root_user_id);
CREATE INDEX IF NOT EXISTS idx_wallet_holds_reference ON wallet_holds(reference_type, reference_id);
CREATE INDEX IF NOT EXISTS idx_wallet_holds_status ON wallet_holds(wallet_hold_status);
CREATE INDEX IF NOT EXISTS idx_wallet_holds_metadata_gin ON wallet_holds USING gin (metadata);

-- Sistem icerisindeki finansal itiraz ve iade islemlerini tutar
CREATE TABLE IF NOT EXISTS transaction_disputes_and_refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL,
    transaction_created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    dispute_type SMALLINT NOT NULL DEFAULT 0,      -- 0=FULL_REFUND, 1=PARTIAL_REFUND, 2=SERVICE_CANCEL, 3=CHARGEBACK
    requested_by_user_id INTEGER NOT NULL REFERENCES users(id),
    claimed_amount NUMERIC(18, 8) NOT NULL CHECK (claimed_amount > 0),
    approved_amount NUMERIC(18, 8) DEFAULT 0.00 CHECK (approved_amount >= 0),
    currency SMALLINT NOT NULL,
    reason_code VARCHAR(50) NOT NULL,-- 'DEFECTIVE_SERVICE', 'NON_DELIVERY', 'FRAUD_SUSPECT'
    reason_description TEXT,
    transaction_dispute_and_refund_status SMALLINT DEFAULT 0,-- 0=PENDING, 1=UNDER_REVIEW, 2=APPROVED, 3=REJECTED, 4=MEDIATION
    evidence_media_ids UUID[] DEFAULT '{}',          -- References to media_assets
    resolved_by_admin_id INTEGER REFERENCES admins(id),
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_approved_lte_claimed CHECK (approved_amount <= claimed_amount),
    CONSTRAINT fk_dispute_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_disputes_transaction ON transaction_disputes_and_refunds (transaction_id);
CREATE INDEX IF NOT EXISTS idx_disputes_user ON transaction_disputes_and_refunds (requested_by_user_id);
CREATE INDEX IF NOT EXISTS idx_disputes_status ON transaction_disputes_and_refunds (transaction_dispute_and_refund_status);

COMMENT ON TABLE transaction_disputes_and_refunds IS 'Tracks user/institution payment disputes, claims, and escrow release holds.';

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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_complaints_ai_analysis_gin ON complaints USING gin (ai_analysis);

-- Sistem icerisindeki tum bildirim bilgilerini tutar
CREATE TABLE IF NOT EXISTS notification_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_type SMALLINT NOT NULL,
    sender_admin_id INTEGER REFERENCES admins(id),
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_notification_campaigns_metadata_gin ON notification_campaigns USING gin (metadata);

-- Bildirimlerin okunma bilgilerini tutar 
CREATE TABLE IF NOT EXISTS notification_deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES notification_campaigns(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_notif_delivery UNIQUE (campaign_id, user_id)
);

-- Sistem parcalarinin bir birini karsilikli puanlama bilgilerini tutar
CREATE TABLE IF NOT EXISTS ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_code SMALLINT NOT NULL, -- lisans kategorisi (örn: 1603=Eğitim, 1702=Tıbbi Araştırma)
    reference_transaction_id UUID,
    reference_transaction_created_at TIMESTAMP WITH TIME ZONE, -- Yapılan işleme/siparişe ait referans
    evaluator_type SMALLINT NOT NULL, -- enum_evaluator_type
    evaluator_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    evaluator_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    evaluator_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    evaluator_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    target_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    target_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    target_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    target_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    score DECIMAL(3, 2) NOT NULL CHECK (score >= 1.00 AND score <= 5.00), -- 1.00 - 5.00 arası standart skor
    trust_score DECIMAL(5, 2) CHECK (trust_score >= 0.00 AND trust_score <= 100.00), -- Finans/Kredi/Güvenilirlik için %0-%100 arası özel skor (opsiyonel)
    review_title VARCHAR(150),
    review_comment TEXT,
    proof_media_ids UUID[], -- Kanıt/Görsel materyaller (media_assets)
    rating_status SMALLINT DEFAULT 1, -- enum_rating_status
    is_anonymous BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_evaluator_ref CHECK (
        (evaluator_user_id IS NOT NULL AND evaluator_institution_id IS NULL AND evaluator_worker_id IS NULL AND evaluator_admin_id IS NULL) OR
        (evaluator_institution_id IS NOT NULL AND evaluator_user_id IS NULL AND evaluator_worker_id IS NULL AND evaluator_admin_id IS NULL) OR
        (evaluator_worker_id IS NOT NULL AND evaluator_user_id IS NULL AND evaluator_institution_id IS NULL AND evaluator_admin_id IS NULL) OR
        (evaluator_admin_id IS NOT NULL AND evaluator_user_id IS NULL AND evaluator_worker_id IS NULL AND evaluator_institution_id IS NULL)
    ),
    CONSTRAINT chk_target_ref CHECK (
        (target_user_id IS NOT NULL AND target_institution_id IS NULL AND target_worker_id IS NULL AND target_admin_id IS NULL) OR
        (target_institution_id IS NOT NULL AND target_user_id IS NULL AND target_worker_id IS NULL AND target_admin_id IS NULL) OR
        (target_worker_id IS NOT NULL AND target_user_id IS NULL AND target_institution_id IS NULL AND target_admin_id IS NULL) OR
        (target_admin_id IS NOT NULL AND target_user_id IS NULL AND target_worker_id IS NULL AND target_institution_id IS NULL)
    ),
    CONSTRAINT fk_ratings_transaction FOREIGN KEY (reference_transaction_id, reference_transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_ratings_category ON ratings(category_code);
CREATE INDEX IF NOT EXISTS idx_ratings_target_user ON ratings(target_user_id) WHERE target_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_ratings_target_worker ON ratings(target_worker_id) WHERE target_worker_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_ratings_target_inst ON ratings(target_institution_id) WHERE target_institution_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_ratings_target_admin ON ratings(target_admin_id) WHERE target_admin_id IF NOT NULL;

-- Ana kullanici degerlendirme risk bilgilerini tutar
CREATE TABLE IF NOT EXISTS user_domain_reputations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    category_code SMALLINT NOT NULL, -- Örn: Seyahat, Kredi Uyum, Alışveriş vb.
    total_rating_count INTEGER DEFAULT 0 CHECK (total_rating_count >= 0),
    average_score DECIMAL(3, 2) DEFAULT 5.00 CHECK (average_score BETWEEN 1.00 AND 5.00),
    credit_trust_score DECIMAL(5, 2) DEFAULT 100.00 CHECK (credit_trust_score BETWEEN 0.00 AND 100.00), -- Banka/Finans odaklı güven puanı
    badge_level VARCHAR(50) DEFAULT 'STANDARD', -- 'VIP_TRAVELER', 'HIGH_RISK_BORROWER', 'TOP_CUSTOMER' vb.
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_user_category_reputation UNIQUE (user_id, category_code)
);

-- Alt sirket calisanlarinin ve yoneticilerinin degerlendirme bilgilerini tutar
CREATE TABLE IF NOT EXISTS worker_domain_reputations (
    id SERIAL PRIMARY KEY,
    worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    category_code SMALLINT NOT NULL, -- Örn: Seyahat, Kredi Uyum, Alışveriş vb.
    total_rating_count INTEGER DEFAULT 0 CHECK (total_rating_count >= 0),
    average_score DECIMAL(3, 2) DEFAULT 5.00 CHECK (average_score BETWEEN 1.00 AND 5.00),
    credit_trust_score DECIMAL(5, 2) DEFAULT 100.00 CHECK (credit_trust_score BETWEEN 0.00 AND 100.00), -- Banka/Finans odaklı güven puanı
    badge_level VARCHAR(50) DEFAULT 'STANDARD', -- 'VIP_TRAVELER', 'HIGH_RISK_BORROWER', 'TOP_CUSTOMER' vb.
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_worker_category_reputation UNIQUE (worker_id, category_code)
);

-- Sistemin denetleyici adminlerinin degerlendirme bilgilerini tutar
CREATE TABLE IF NOT EXISTS admin_domain_reputations (
    id SERIAL PRIMARY KEY,
    admin_id INTEGER NOT NULL REFERENCES admins(id) ON DELETE RESTRICT,
    category_code SMALLINT NOT NULL, -- Örn: Seyahat, Kredi Uyum, Alışveriş vb.
    total_rating_count INTEGER DEFAULT 0 CHECK (total_rating_count >= 0),
    average_score DECIMAL(3, 2) DEFAULT 5.00 CHECK (average_score BETWEEN 1.00 AND 5.00),
    credit_trust_score DECIMAL(5, 2) DEFAULT 100.00 CHECK (credit_trust_score BETWEEN 0.00 AND 100.00), -- Banka/Finans odaklı güven puanı
    badge_level VARCHAR(50) DEFAULT 'STANDARD', -- 'VIP_TRAVELER', 'HIGH_RISK_BORROWER', 'TOP_CUSTOMER' vb.
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_admin_category_reputation UNIQUE (admin_id, category_code)
);

-- Sistemin Alt sirketlerinin puanlama bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_domain_reputations (
    id SERIAL PRIMARY KEY,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    category_code SMALLINT NOT NULL, -- Örn: 1603=Eğitim Akademi, 1702=Tıbbi Laboratuvar
    total_rating_count INTEGER DEFAULT 0 CHECK (total_rating_count >= 0),
    average_score DECIMAL(3, 2) DEFAULT 5.00 CHECK (average_score BETWEEN 1.00 AND 5.00),
    compliance_score DECIMAL(5, 2) DEFAULT 100.00 CHECK (compliance_score BETWEEN 0.00 AND 100.00), -- Yasal/Medikal Uyum Skoru
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_inst_app_category_reputation UNIQUE (institution_id, category_code)
);

-- Sistemin tum onaylama islemleri bilgilerini tutar
CREATE TABLE IF NOT EXISTS approvals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_root_id INTEGER NOT NULL REFERENCES users(id),
    requester_role VARCHAR(20) NOT NULL,
    approval_type VARCHAR(50) NOT NULL,
    approval_status SMALLINT DEFAULT 0, -- 0=PENDING, 1=APPROVED, 2=REJECTED
    priority_score INTEGER DEFAULT 0,
    required_approvals_count INTEGER DEFAULT 1, -- Gereken oy/onay sayısı
    current_approvals_count INTEGER DEFAULT 0,  -- Mevcut verilen onay sayısı
    request_data JSONB NOT NULL, 
    ai_analysis_report JSONB, 
    reviewer_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_approvals_request_data_gin ON approvals USING gin (request_data);
CREATE INDEX IF NOT EXISTS idx_approvals_ai_analysis_report_gin ON approvals USING gin (ai_analysis_report);

-- Onaylama icin verilen oy bilgilerini tutar
CREATE TABLE IF NOT EXISTS approval_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    approval_id UUID NOT NULL REFERENCES approvals(id) ON DELETE RESTRICT,
    shareholder_id INTEGER REFERENCES system_shareholders(id),
    admin_id INTEGER REFERENCES admins(id),
    vote BOOLEAN NOT NULL, -- true=APPROVED, false=REJECTED
    comment TEXT,
    voted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_shareholder_approval_vote UNIQUE(approval_id, shareholder_id)
);

-- Sisteme maasli admin olma adaylik basvuru bilgilerini tutar
CREATE TABLE IF NOT EXISTS admin_candidacy_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    applicant_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    requested_admin_level INTEGER NOT NULL DEFAULT 1 CHECK (requested_admin_level BETWEEN 1 AND 10),
    requested_permissions SMALLINT[] NOT NULL DEFAULT '{}',
    motivation_text TEXT,
    admin_candidacy_application_status SMALLINT NOT NULL DEFAULT 0, -- enum_application_status
    approval_id UUID REFERENCES approvals(id) ON DELETE RESTRICT,
    resulting_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_admin_candidacy_applicant ON admin_candidacy_applications(applicant_user_id);
CREATE INDEX IF NOT EXISTS idx_admin_candidacy_status ON admin_candidacy_applications(admin_candidacy_application_status);

-- Admin Gorevini sonlandirma pasive cekme basvuru kayitlarini tutar
CREATE TABLE IF NOT EXISTS admin_deactivation_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_admin_id INTEGER NOT NULL REFERENCES admins(id) ON DELETE RESTRICT,
    initiated_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    initiation_type SMALLINT NOT NULL DEFAULT 1,        -- enum_initiation_type (bilgi amaçlı; SÜREÇ ikisinde de aynı)
    deactivation_mode SMALLINT NOT NULL,                -- enum_deactivation_mode
    reason TEXT NOT NULL,
    admin_deactivation_application_status SMALLINT NOT NULL DEFAULT 0,-- enum_application_status (01core ile ortak)
    approval_id UUID REFERENCES approvals(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_deactivation_mode CHECK (deactivation_mode IN (0, 1)),
    CONSTRAINT chk_initiation_type CHECK (initiation_type IN (0, 1)),
    CONSTRAINT chk_app_removal_not_empty CHECK (deactivation_mode = 0 OR array_length(app_ids_to_remove, 1) > 0)
);

CREATE INDEX IF NOT EXISTS idx_admin_deact_target ON admin_deactivation_applications(target_admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_deact_status ON admin_deactivation_applications(admin_deactivation_application_status);
CREATE UNIQUE INDEX IF NOT EXISTS uq_admin_deact_pending
    ON admin_deactivation_applications (target_admin_id) WHERE admin_deactivation_application_status = 0;

-- Admin gorevden alma isleminde cuzdan sifirlama kayitlarini tutar
CREATE TABLE IF NOT EXISTS admin_wallet_sweep_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id INTEGER NOT NULL REFERENCES admins(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    currency SMALLINT NOT NULL,
    swept_amount DECIMAL(18, 8) NOT NULL CHECK (swept_amount <> 0),
    sweep_reason VARCHAR(50) NOT NULL DEFAULT 'ADMIN_DEACTIVATION',.
    settlement_status SMALLINT NOT NULL DEFAULT 0,   -- enum_settlement_status
    adjustment_amount DECIMAL(18, 8) DEFAULT 0.00,   -- pozitif=ek ödeme, negatif=geri talep
    settlement_notes TEXT,
    reviewed_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_admin_sweep_admin ON admin_wallet_sweep_log(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_sweep_pending ON admin_wallet_sweep_log(settlement_status) WHERE settlement_status = 0;

-- Sisteme ortak olma basvuru adaylik bilgilerini tutar
CREATE TABLE IF NOT EXISTS shareholder_candidacy_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    applicant_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    requested_share_percentage DECIMAL(5, 4) NOT NULL CHECK (requested_share_percentage > 0 AND requested_share_percentage <= 1.0000),
    requested_partner_type SMALLINT NOT NULL DEFAULT 2, -- enum_partner_type (01core.sql)
    requested_board_member BOOLEAN NOT NULL DEFAULT false,
    motivation_text TEXT,
    shareholder_candidacy_application_status SMALLINT NOT NULL DEFAULT 0, -- enum_application_status
    approval_id UUID REFERENCES approvals(id) ON DELETE RESTRICT,
    resulting_shareholder_id INTEGER REFERENCES system_shareholders(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_shareholder_candidacy_applicant ON shareholder_candidacy_applications(applicant_user_id);
CREATE INDEX IF NOT EXISTS idx_shareholder_candidacy_status ON shareholder_candidacy_applications(shareholder_candidacy_application_status);

-- Sistem ortaklarini gorevini sonlandirma basvuru kayitlarini tutar
CREATE TABLE IF NOT EXISTS shareholder_exit_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shareholder_id INTEGER NOT NULL REFERENCES system_shareholders(id) ON DELETE RESTRICT,
    initiated_by_shareholder_id INTEGER NOT NULL REFERENCES system_shareholders(id) ON DELETE RESTRICT,
    exit_type SMALLINT NOT NULL DEFAULT 1,
    redistribution_mode SMALLINT NOT NULL,
    reason TEXT NOT NULL,
    shareholder_exit_application_status SMALLINT NOT NULL DEFAULT 0,
    required_approvals_count INTEGER NOT NULL DEFAULT 1,
    current_approvals_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_sea_exit_type CHECK (exit_type IN (0, 1)),
    CONSTRAINT chk_sea_redistribution_mode CHECK (redistribution_mode IN (0, 1))
);

CREATE INDEX IF NOT EXISTS idx_shareholder_exit_status ON shareholder_exit_applications(shareholder_exit_application_status);
CREATE UNIQUE INDEX IF NOT EXISTS uq_shareholder_exit_pending
    ON shareholder_exit_applications (shareholder_id) WHERE shareholder_exit_application_status = 0;

-- Sistem ortagi gorev sonlandirma oylama bilgilerini tutar
CREATE TABLE IF NOT EXISTS shareholder_exit_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES shareholder_exit_applications(id) ON DELETE RESTRICT,
    voter_shareholder_id INTEGER NOT NULL REFERENCES system_shareholders(id) ON DELETE RESTRICT,
    vote BOOLEAN NOT NULL,
    comment TEXT,
    voted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_shareholder_exit_voter UNIQUE (application_id, voter_shareholder_id)
);

CREATE INDEX IF NOT EXISTS idx_shareholder_exit_votes_app ON shareholder_exit_votes(application_id);

-- Sistem ortaklari gorev sonlandirmasinda cuzdan sifirlama kayitlarini tutar
CREATE TABLE IF NOT EXISTS founder_wallet_sweep_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shareholder_id INTEGER NOT NULL REFERENCES system_shareholders(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    currency SMALLINT NOT NULL,
    swept_amount DECIMAL(18, 8) NOT NULL CHECK (swept_amount <> 0),
    sweep_reason VARCHAR(50) NOT NULL DEFAULT 'SHAREHOLDER_EXIT',
    settlement_status SMALLINT NOT NULL DEFAULT 0,
    adjustment_amount DECIMAL(18, 8) DEFAULT 0.00,
    settlement_notes TEXT,
    reviewed_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_founder_sweep_shareholder ON founder_wallet_sweep_log(shareholder_id);
CREATE INDEX IF NOT EXISTS idx_founder_sweep_pending ON founder_wallet_sweep_log(settlement_status) WHERE settlement_status = 0;

-- Alt sirketlere ortak olma basvuru adaylik bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_partner_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    applicant_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    position_type SMALLINT NOT NULL DEFAULT 2, -- 2=EQUITY_PARTNER, 3=MANAGING_PARTNER
    requested_equity_percentage DECIMAL(5, 4) NOT NULL CHECK (requested_equity_percentage > 0 AND requested_equity_percentage <= 1.0000),
    motivation_text TEXT,
    institution_partner_application_status SMALLINT NOT NULL DEFAULT 0, -- enum_application_status
    required_approvals_count INTEGER NOT NULL DEFAULT 1,
    current_approvals_count INTEGER NOT NULL DEFAULT 0,
    resulting_position_id INTEGER REFERENCES worker_institution_positions(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_partner_position_type CHECK (position_type IN (2, 3))
);

CREATE INDEX IF NOT EXISTS idx_partner_apps_institution ON institution_partner_applications(institution_id, institution_partner_application_status);
CREATE INDEX IF NOT EXISTS idx_partner_apps_applicant ON institution_partner_applications(applicant_user_id);

-- Alt sirketlerin yonetim kurulu oy bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_partner_application_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES institution_partner_applications(id) ON DELETE RESTRICT,
    voter_worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    vote BOOLEAN NOT NULL,
    comment TEXT,
    voted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_partner_app_voter UNIQUE (application_id, voter_worker_id)
);

CREATE INDEX IF NOT EXISTS idx_partner_votes_application ON institution_partner_application_votes(application_id);

-- Alt sirketlerde calisma basvurusu aday bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_employment_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    applicant_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    position_type SMALLINT NOT NULL DEFAULT 0, -- 0=SALARIED_EMPLOYEE, 1=COMMISSION_WORKER
    proposed_monthly_salary DECIMAL(18, 8) DEFAULT 0.00 CHECK (proposed_monthly_salary >= 0),
    proposed_commission_rate DECIMAL(5, 4) DEFAULT 0.0000 CHECK (proposed_commission_rate >= 0 AND proposed_commission_rate <= 1.0000),
    currency SMALLINT DEFAULT 0,
    cover_note TEXT,
    institution_employment_application_status SMALLINT NOT NULL DEFAULT 0, -- enum_application_status
    reviewed_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    review_note TEXT,
    resulting_position_id INTEGER REFERENCES worker_institution_positions(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_employment_position_type CHECK (position_type IN (0, 1))
);

CREATE INDEX IF NOT EXISTS idx_employment_apps_institution ON institution_employment_applications(institution_id, institution_employment_application_status);
CREATE INDEX IF NOT EXISTS idx_employment_apps_applicant ON institution_employment_applications(applicant_user_id);

-- Alt sirket ortaklarini gorevden alma islem kayitlarini tutar 
CREATE TABLE IF NOT EXISTS institution_partner_exit_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    position_id INTEGER NOT NULL REFERENCES worker_institution_positions(id) ON DELETE RESTRICT,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    initiated_by_worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    exit_type SMALLINT NOT NULL DEFAULT 1,             -- enum_exit_type — trigger otomatik belirler
    redistribution_mode SMALLINT NOT NULL,             -- enum_redistribution_mode — başvuruda seçilir
    reason TEXT NOT NULL,
    institution_partner_exit_application_status SMALLINT NOT NULL DEFAULT 0,                -- enum_application_status
    required_approvals_count INTEGER NOT NULL DEFAULT 1,
    current_approvals_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_pea_exit_type CHECK (exit_type IN (0, 1)),
    CONSTRAINT chk_pea_redistribution_mode CHECK (redistribution_mode IN (0, 1))
);

CREATE INDEX IF NOT EXISTS idx_partner_exit_institution ON institution_partner_exit_applications(institution_id, institution_partner_exit_application_status);
CREATE INDEX IF NOT EXISTS idx_partner_exit_position ON institution_partner_exit_applications(position_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_partner_exit_pending
    ON institution_partner_exit_applications (position_id) WHERE institution_partner_exit_application_status = 0;

-- Alt sirket yoneticilerini gorevden alma oylama bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_partner_exit_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES institution_partner_exit_applications(id) ON DELETE RESTRICT,
    voter_worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    vote BOOLEAN NOT NULL,
    comment TEXT,
    voted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_partner_exit_voter UNIQUE (application_id, voter_worker_id)
);

CREATE INDEX IF NOT EXISTS idx_partner_exit_votes_app ON institution_partner_exit_votes(application_id);

-- Alt sirket calisani veya ortagi gorevden alinirken cuzdan sifirlama kayitlarini tutar
CREATE TABLE IF NOT EXISTS worker_wallet_sweep_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    triggering_position_id INTEGER REFERENCES worker_institution_positions(id) ON DELETE RESTRICT,
    currency SMALLINT NOT NULL,
    swept_amount DECIMAL(18, 8) NOT NULL CHECK (swept_amount <> 0),
    sweep_reason VARCHAR(50) NOT NULL DEFAULT 'WORKER_ACCOUNT_DEACTIVATION',
    settlement_status SMALLINT NOT NULL DEFAULT 0,   -- enum_settlement_status
    adjustment_amount DECIMAL(18, 8) DEFAULT 0.00,
    settlement_notes TEXT,
    reviewed_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_worker_sweep_worker ON worker_wallet_sweep_log(worker_id);
CREATE INDEX IF NOT EXISTS idx_worker_sweep_pending ON worker_wallet_sweep_log(settlement_status) WHERE settlement_status = 0;

-- Alt sirket kapatma basvuru kayitlarini tutar
CREATE TABLE IF NOT EXISTS institution_closure_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    closure_path SMALLINT NOT NULL,     -- enum_closure_path
    initiated_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,          -- path=0 için ZORUNLU
    initiated_by_shareholder_id INTEGER REFERENCES system_shareholders(id) ON DELETE RESTRICT, -- path=1 için ZORUNLU
    reason TEXT NOT NULL,
    institution_closure_application_status SMALLINT NOT NULL DEFAULT 0, -- enum_institution_closure_status
    required_approvals_count INTEGER NOT NULL DEFAULT 1,
    current_approvals_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_ica_path CHECK (closure_path IN (0, 1)),
    CONSTRAINT chk_ica_initiator_matches_path CHECK (
        (closure_path = 0 AND initiated_by_worker_id IS NOT NULL AND initiated_by_shareholder_id IS NULL) OR
        (closure_path = 1 AND initiated_by_shareholder_id IS NOT NULL AND initiated_by_worker_id IS NULL)
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_institution_closure_open
    ON institution_closure_applications (institution_id) WHERE institution_closure_application_status IN (0, 1);
CREATE INDEX IF NOT EXISTS idx_institution_closure_institution ON institution_closure_applications(institution_id);

-- Alt sirket kapatma isleminde kendi yonetim kurulu oylarini tutar
CREATE TABLE IF NOT EXISTS institution_closure_votes_board (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES institution_closure_applications(id) ON DELETE RESTRICT,
    voter_worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    vote BOOLEAN NOT NULL,
    comment TEXT,
    voted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_ic_board_voter UNIQUE (application_id, voter_worker_id)
);

-- Alt sirket kapatma isleminde sistem ortaklarinin oylarini tutar
CREATE TABLE IF NOT EXISTS institution_closure_votes_holding (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES institution_closure_applications(id) ON DELETE RESTRICT,
    voter_shareholder_id INTEGER NOT NULL REFERENCES system_shareholders(id) ON DELETE RESTRICT,
    vote BOOLEAN NOT NULL,
    comment TEXT,
    voted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_ic_holding_voter UNIQUE (application_id, voter_shareholder_id)
);

-- Alt sirket kapatma isleminde denetim loglari tutar
CREATE TABLE IF NOT EXISTS institution_closure_distribution_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    application_id UUID NOT NULL REFERENCES institution_closure_applications(id) ON DELETE RESTRICT,
    worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,          -- NULL ise unclaimed (BÖLÜM 6 notuna bakın)
    user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    currency SMALLINT NOT NULL,
    distributed_amount DECIMAL(18, 8) NOT NULL CHECK (distributed_amount > 0),
    equity_percentage_at_closure DECIMAL(5, 4),
    is_unclaimed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_closure_dist_institution ON institution_closure_distribution_log(institution_id);
CREATE INDEX IF NOT EXISTS idx_closure_dist_unclaimed ON institution_closure_distribution_log(is_unclaimed) WHERE is_unclaimed = true;

-- Alt sirket sube kapatma basvuru kayitlarini tutar
CREATE TABLE IF NOT EXISTS institution_branch_closure_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES institution_branches(id) ON DELETE RESTRICT,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    initiated_by_worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    reason TEXT NOT NULL,
    institution_branch_closure_application_status SMALLINT NOT NULL DEFAULT 0,             -- enum_branch_closure_status
    required_approvals_count INTEGER NOT NULL DEFAULT 1,  -- = kurumun TÜM aktif board üye sayısı (oy birliği)
    current_approvals_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP WITH TIME ZONE,           -- oy birliği ne zaman sağlandı
    closed_at TIMESTAMP WITH TIME ZONE,              -- gerçek kapanış ne zaman gerçekleşti
    CONSTRAINT chk_ibca_status CHECK (institution_branch_closure_application_status IN (0, 1, 2, 3))
);

CREATE INDEX IF NOT EXISTS idx_branch_closure_institution ON institution_branch_closure_applications(institution_id, institution_branch_closure_application_status);
CREATE INDEX IF NOT EXISTS idx_branch_closure_branch ON institution_branch_closure_applications(branch_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_branch_closure_open
    ON institution_branch_closure_applications (branch_id) WHERE institution_branch_closure_application_status IN (0, 1);

-- Alt sirket sube kapatma isleminde oy bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_branch_closure_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES institution_branch_closure_applications(id) ON DELETE RESTRICT,
    voter_worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    vote BOOLEAN NOT NULL,
    comment TEXT,
    voted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_branch_closure_voter UNIQUE (application_id, voter_worker_id)
);

CREATE INDEX IF NOT EXISTS idx_branch_closure_votes_app ON institution_branch_closure_votes(application_id);

-- Sistemin finansal islem bilgilerini tutar
CREATE TABLE IF NOT EXISTS financial_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(id),
    request_type VARCHAR(30) NOT NULL,
    request_details JSONB NOT NULL,
    financial_request_status SMALLINT DEFAULT 0,
    processed_by_admin_id INTEGER REFERENCES admins(id),
    admin_comment TEXT,
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Cikis fisi makbuzlarini tutar voucher ile nakit girisinin muhasebe cikis denkligi
CREATE TABLE IF NOT EXISTS cash_outflow_slips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slip_number VARCHAR(50) UNIQUE NOT NULL,
    withdrawal_request_id UUID REFERENCES withdrawal_requests(id) ON DELETE RESTRICT,
    real_world_account_id INTEGER NOT NULL REFERENCES real_world_accounts(id) ON DELETE RESTRICT,
    source_chart_account_id INTEGER NOT NULL REFERENCES chart_of_accounts(id) ON DELETE RESTRICT,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    fee_deducted DECIMAL(18, 8) DEFAULT 0.00 CHECK (fee_deducted >= 0),
    net_paid_amount DECIMAL(18, 8) NOT NULL CHECK (net_paid_amount > 0),
    currency SMALLINT NOT NULL,
    issued_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    issued_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    recipient_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    journal_entry_id UUID REFERENCES journal_entries(id) ON DELETE RESTRICT,
    cash_outflow_slip_status SMALLINT DEFAULT 1,
    cash_outflow_slip_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_cash_outflow_per_request 
ON cash_outflow_slips (withdrawal_request_id) 
WHERE status <> 0; -- iptal edilmemiş/geçerli fişler için tekil olsun

-- Sistemin genel urun bilgilerini tutar herhangi bir urun veya hizmet turu
CREATE TABLE IF NOT EXISTS listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_code SMALLINT NOT NULL,-- İlgili App altındaki modül/lisans kategorisi
    institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,   -- bireysel worker satıcıysa
    listing_title VARCHAR(200) NOT NULL,
    listing_description TEXT,
    price DECIMAL(18, 8) NOT NULL CHECK (price >= 0),
    currency SMALLINT NOT NULL,
    stock_quantity INTEGER CHECK (stock_quantity IS NULL OR stock_quantity >= 0), -- fiziksel ürün değilse NULL
    is_service BOOLEAN NOT NULL DEFAULT false,
    attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
    media_ids UUID[] DEFAULT '{}',
    listing_status SMALLINT NOT NULL DEFAULT 0,           -- enum_listing_status
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_listing_owner CHECK (
        (institution_id IS NOT NULL AND worker_id IS NULL) OR
        (worker_id IS NOT NULL AND institution_id IS NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_listings_category ON listings(category_code);
CREATE INDEX IF NOT EXISTS idx_listings_institution ON listings(institution_id);
CREATE INDEX IF NOT EXISTS idx_listings_worker ON listings(worker_id);
CREATE INDEX IF NOT EXISTS idx_listings_attributes_gin ON listings USING GIN (attributes);
CREATE INDEX IF NOT EXISTS idx_listings_status ON listings(listing_status) WHERE is_active = true;

-- Medikal & Eczane — reçete/ruhsat gerektiren ürün/hizmetler
CREATE TABLE IF NOT EXISTS medical_listing_details (
    listing_id UUID PRIMARY KEY REFERENCES listings(id) ON DELETE RESTRICT,
    requires_prescription BOOLEAN NOT NULL DEFAULT false,
    license_id UUID REFERENCES institution_licenses(id) ON DELETE RESTRICT,
    batch_or_lot_no VARCHAR(50),
    expiry_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Gayrimenkul — konum/metrekare bazlı arama performansı gerektiren alanlar
CREATE TABLE IF NOT EXISTS real_estate_listing_details (
    listing_id UUID PRIMARY KEY REFERENCES listings(id) ON DELETE RESTRICT,
    property_type SMALLINT NOT NULL,           -- 0=APARTMENT, 1=VILLA, 2=LAND, 3=COMMERCIAL
    square_meters DECIMAL(10, 2) CHECK (square_meters > 0),
    room_count SMALLINT,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    title_deed_status SMALLINT DEFAULT 0,      -- 0=CLEAR, 1=MORTGAGED, 2=DISPUTED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_real_estate_location ON real_estate_listing_details(latitude, longitude);

-- Finansal Enstrümanlar — vade/faiz/risk gibi regülasyon gerektiren alanlar
CREATE TABLE IF NOT EXISTS financial_instrument_details (
    listing_id UUID PRIMARY KEY REFERENCES listings(id) ON DELETE RESTRICT,
    instrument_type SMALLINT NOT NULL,          -- 0=DEPOSIT, 1=FUND, 2=BOND, 3=CREDIT_PRODUCT
    maturity_months INTEGER CHECK (maturity_months IS NULL OR maturity_months > 0),
    interest_rate DECIMAL(7, 4) CHECK (interest_rate >= 0),
    risk_score SMALLINT CHECK (risk_score BETWEEN 1 AND 10),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Bahis/Kumar — sık güncellenen oran verisi 
CREATE TABLE IF NOT EXISTS betting_market_details (
    listing_id UUID PRIMARY KEY REFERENCES listings(id) ON DELETE RESTRICT,
    event_reference VARCHAR(100) NOT NULL,
    market_type VARCHAR(50) NOT NULL,           -- 'MATCH_WINNER', 'OVER_UNDER', vb.
    current_odds DECIMAL(8, 4) NOT NULL CHECK (current_odds > 1.00),
    odds_locked BOOLEAN NOT NULL DEFAULT false,
    settles_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Sube bazli stok durumlarini tutar
CREATE TABLE IF NOT EXISTS listing_branch_stock (
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    branch_id UUID NOT NULL REFERENCES institution_branches(id) ON DELETE RESTRICT,
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reserved_quantity INTEGER NOT NULL DEFAULT 0 CHECK (reserved_quantity >= 0),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (listing_id, branch_id),
    CONSTRAINT chk_reserved_lte_stock CHECK (reserved_quantity <= stock_quantity)
);

CREATE INDEX IF NOT EXISTS idx_lbs_branch ON listing_branch_stock(branch_id);

-- Cift tarafli stok hareketlerini tutar
CREATE TABLE IF NOT EXISTS stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    branch_id UUID NOT NULL REFERENCES institution_branches(id) ON DELETE RESTRICT,
    movement_type SMALLINT NOT NULL,             -- enum_stock_movement_type
    quantity_delta INTEGER NOT NULL,              -- pozitif=artış (restock/iade), negatif=azalış (satış)
    reference_type VARCHAR(30),                   -- 'MARKETPLACE_ORDER', 'MANUAL_ADJUSTMENT'
    reference_id UUID,
    performed_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_movement_delta_sign CHECK (
        (movement_type IN (0, 3) AND quantity_delta > 0) OR   -- RESTOCK, RETURN: pozitif
        (movement_type IN (1, 2) AND quantity_delta < 0) OR   -- ONLINE_SALE, POS_SALE: negatif
        (movement_type = 4)                                    -- ADJUSTMENT: her iki yönde olabilir
    )
);

CREATE INDEX IF NOT EXISTS idx_stock_movements_listing_branch ON stock_movements(listing_id, branch_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_reference ON stock_movements(reference_type, reference_id);

-- Sube bazli kasa oturumlarini tutar
CREATE TABLE IF NOT EXISTS pos_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID NOT NULL REFERENCES institution_branches(id) ON DELETE RESTRICT,
    opened_by_worker_id INTEGER NOT NULL REFERENCES workers(id) ON DELETE RESTRICT,
    currency SMALLINT NOT NULL,
    opening_cash_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (opening_cash_amount >= 0),
    closing_cash_amount DECIMAL(18, 8) CHECK (closing_cash_amount IS NULL OR closing_cash_amount >= 0),
    pos_session_status SMALLINT NOT NULL DEFAULT 0,           -- enum_pos_session_status
    opened_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_pos_sessions_branch ON pos_sessions(branch_id, pos_session_status);

-- Sözleşme Şablonları ve Versiyon Yönetimi bilgilerini tutar
CREATE TABLE IF NOT EXISTS digital_contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_type SMALLINT NOT NULL, -- 0=SHAREHOLDER_AGREEMENT, 1=WORKER_EMPLOYMENT, 2=CUSTOMER_TERMS, 3=INSTITUTION_LICENSE
    title VARCHAR(200) NOT NULL,
    digital_contract_version VARCHAR(20) NOT NULL,
    content_text TEXT NOT NULL,
    media_asset_id UUID REFERENCES media_assets(id),
    is_active BOOLEAN DEFAULT true,
    effective_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_contract_type_version UNIQUE(contract_type, digital_contract_version)
);

-- Onay Logları (KVKK / Hukuki Geçerlilik) Tablosu
CREATE TABLE IF NOT EXISTS contract_acceptances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES digital_contracts(id) ON DELETE RESTRICT,
    signer_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    signer_role VARCHAR(20) NOT NULL, -- 'USER', 'WORKER', 'INSTITUTION_OWNER', 'SHAREHOLDER'
    signer_ip VARCHAR(64) NOT NULL,
    signed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_user_contract UNIQUE(contract_id, signer_user_id)
);

-- Pazaryeri Sipariş Yaşam Döngüsü Tablosu
CREATE TABLE IF NOT EXISTS marketplace_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    seller_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    assigned_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    listing_id UUID REFERENCES listings(id) ON DELETE RESTRICT,
    branch_id UUID REFERENCES institution_branches(id) ON DELETE RESTRICT,          -- Şube
    sales_channel SMALLINT NOT NULL DEFAULT 0,                          -- 0=ONLINE, 1=POS
    pos_session_id UUID REFERENCES pos_sessions(id) ON DELETE RESTRICT,    -- POS Kasa Oturumu
    cash_tendered DECIMAL(18, 8),                                       -- POS nakit ödemesi
    change_given DECIMAL(18, 8),                                        -- Para üstü
    transaction_id UUID,                                                -- Cüzdan ödeme referansı
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    order_status SMALLINT NOT NULL DEFAULT 0, -- 0=CREATED, 1=PAYMENT_HOLD, 2=PROCESSING, 3=IN_TRANSIT, 4=COMPLETED, 5=CANCELLED
    total_amount NUMERIC(18, 8) NOT NULL CHECK (total_amount > 0),
    currency SMALLINT NOT NULL, -- SMALLINT enum para birimi
    order_details JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_orders_branch ON marketplace_orders(branch_id);
CREATE INDEX IF NOT EXISTS idx_orders_pos_session ON marketplace_orders(pos_session_id) WHERE pos_session_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_orders_customer ON marketplace_orders(customer_user_id);
CREATE INDEX IF NOT EXISTS idx_orders_institution ON marketplace_orders(seller_institution_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON marketplace_orders(order_status);

-- Kiralama bazli islemleri tutar
CREATE TABLE IF NOT EXISTS booking_availability_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    branch_id UUID NOT NULL REFERENCES institution_branches(id) ON DELETE RESTRICT,
    slot_start TIMESTAMP WITH TIME ZONE NOT NULL,
    slot_end TIMESTAMP WITH TIME ZONE NOT NULL,
    total_capacity INTEGER NOT NULL CHECK (total_capacity > 0),
    booked_capacity INTEGER NOT NULL DEFAULT 0 CHECK (booked_capacity >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_slot_dates CHECK (slot_end > slot_start),
    CONSTRAINT chk_slot_capacity CHECK (booked_capacity <= total_capacity)
);

CREATE INDEX IF NOT EXISTS idx_booking_slots_listing_time ON booking_availability_slots(listing_id, slot_start, slot_end);
CREATE INDEX IF NOT EXISTS idx_booking_slots_branch ON booking_availability_slots(branch_id);

-- 2. REZERVASYON DETAYI (marketplace_orders'ın 1-1 uzantısı)
CREATE TABLE IF NOT EXISTS booking_details (
    order_id UUID PRIMARY KEY REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    availability_slot_id UUID NOT NULL REFERENCES booking_availability_slots(id) ON DELETE RESTRICT,
    guest_or_party_count INTEGER CHECK (guest_or_party_count IS NULL OR guest_or_party_count > 0),
    check_in_at TIMESTAMP WITH TIME ZONE,
    check_out_at TIMESTAMP WITH TIME ZONE,
    cancellation_policy SMALLINT NOT NULL DEFAULT 0, -- 0=FLEXIBLE,1=MODERATE,2=STRICT,3=NON_REFUNDABLE
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    no_show BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Digital icerik urunlerinin detaylarini tutar
CREATE TABLE IF NOT EXISTS content_listing_details (
    listing_id UUID PRIMARY KEY REFERENCES listings(id) ON DELETE RESTRICT,
    content_type SMALLINT NOT NULL,
    duration_seconds INTEGER CHECK (duration_seconds IS NULL OR duration_seconds > 0),
    release_date DATE,
    license_type SMALLINT NOT NULL DEFAULT 0,
    rights_territory VARCHAR(100) NOT NULL DEFAULT 'GLOBAL',
    rights_expires_at TIMESTAMP WITH TIME ZONE,
    primary_media_asset_id UUID REFERENCES media_assets(id),   -- asıl içerik dosyası (MinIO üzerinden)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Kullanıcının satın aldığı görüntüleme/erişim hakkı bilgilerini tutar
CREATE TABLE IF NOT EXISTS content_view_licenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    order_id UUID NOT NULL REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,   -- NULL = süresiz (PERPETUAL)
    CONSTRAINT unq_content_license UNIQUE (listing_id, user_id, order_id)
);

CREATE INDEX IF NOT EXISTS idx_content_licenses_user ON content_view_licenses(user_id);

-- Profesyonel hizmet urunlerinin detaylarini tutar
CREATE TABLE IF NOT EXISTS service_engagement_details (
    order_id UUID PRIMARY KEY REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    engagement_type SMALLINT NOT NULL,           -- 0=HOURLY, 1=FIXED_PROJECT, 2=RETAINER
    scope_description TEXT NOT NULL,
    estimated_hours DECIMAL(8, 2) CHECK (estimated_hours IS NULL OR estimated_hours > 0),
    hourly_rate DECIMAL(18, 8) CHECK (hourly_rate IS NULL OR hourly_rate >= 0),
    start_date DATE,
    target_end_date DATE,
    actual_end_date DATE,
    service_engagement_detail_status SMALLINT NOT NULL DEFAULT 0,-- 0=SCOPING, 1=IN_PROGRESS, 2=DELIVERED, 3=CLOSED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_engagement_dates CHECK (target_end_date IS NULL OR start_date IS NULL OR target_end_date >= start_date)
);

-- Profesyonel hizmet urunlerinin kullanim bilgilerini tutar
CREATE TABLE IF NOT EXISTS service_engagement_milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    milestone_title VARCHAR(150) NOT NULL,
    due_date DATE,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount >= 0),
    currency SMALLINT NOT NULL,
    service_engagement_milestone_status SMALLINT NOT NULL DEFAULT 0,           -- 0=PENDING, 1=SUBMITTED, 2=APPROVED, 3=PAID
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_milestones_order ON service_engagement_milestones(order_id);

-- Egitim hizmetleri detaylarini tutar
CREATE TABLE IF NOT EXISTS education_program_details (
    listing_id UUID PRIMARY KEY REFERENCES listings(id) ON DELETE RESTRICT,
    program_type SMALLINT NOT NULL,               -- 0=COURSE, 1=DEGREE, 2=CERTIFICATE, 3=WORKSHOP
    duration_weeks INTEGER CHECK (duration_weeks IS NULL OR duration_weeks > 0),
    credit_hours DECIMAL(6, 2) CHECK (credit_hours IS NULL OR credit_hours >= 0),
    max_enrollment INTEGER CHECK (max_enrollment IS NULL OR max_enrollment > 0),
    current_enrollment INTEGER NOT NULL DEFAULT 0 CHECK (current_enrollment >= 0),
    instructor_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_enrollment_capacity CHECK (max_enrollment IS NULL OR current_enrollment <= max_enrollment)
);

-- Egitim hizmetlerinin kullanim bilgilerini tutar
CREATE TABLE IF NOT EXISTS education_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    order_id UUID NOT NULL REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    enrollment_status SMALLINT NOT NULL DEFAULT 0, -- 0=ENROLLED, 1=IN_PROGRESS, 2=COMPLETED, 3=WITHDRAWN
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    certificate_media_id UUID REFERENCES media_assets(id),
    CONSTRAINT unq_enrollment UNIQUE (listing_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_enrollments_user ON education_enrollments(user_id);

-- Lojistik hizmetlerin detay bilgilerini tutar
CREATE TABLE IF NOT EXISTS logistics_shipment_details (
    order_id UUID PRIMARY KEY REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    origin_branch_id UUID REFERENCES institution_branches(id) ON DELETE RESTRICT,
    destination_address TEXT NOT NULL,
    destination_lat DECIMAL(9, 6),
    destination_lng DECIMAL(9, 6),
    weight_kg DECIMAL(10, 3) CHECK (weight_kg IS NULL OR weight_kg > 0),
    volume_m3 DECIMAL(10, 3) CHECK (volume_m3 IS NULL OR volume_m3 > 0),
    carrier_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    sla_target_hours INTEGER CHECK (sla_target_hours IS NULL OR sla_target_hours > 0),
    logistics_shipment_detail_status SMALLINT NOT NULL DEFAULT 0,  -- 0=CREATED,1=PICKED_UP,2=IN_TRANSIT,3=OUT_FOR_DELIVERY,4=DELIVERED,5=FAILED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Lojistik hizmetlerin durum bilgilerini tutar
CREATE TABLE IF NOT EXISTS logistics_status_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    event_type VARCHAR(30) NOT NULL,     -- 'PICKED_UP','ARRIVED_HUB','OUT_FOR_DELIVERY','DELIVERED','FAILED_ATTEMPT'
    event_lat DECIMAL(9, 6),
    event_lng DECIMAL(9, 6),
    notes TEXT,
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_logistics_events_order ON logistics_status_events(order_id, occurred_at);

-- Bulut hizmetlerinin detay bilgilerini tutar
CREATE TABLE IF NOT EXISTS saas_license_details (
    listing_id UUID PRIMARY KEY REFERENCES listings(id) ON DELETE RESTRICT,
    license_model SMALLINT NOT NULL,       -- 0=SUBSCRIPTION, 1=PERPETUAL, 2=USAGE_BASED
    billing_cycle SMALLINT,                -- 0=MONTHLY, 1=YEARLY, 2=ONE_TIME
    seat_limit INTEGER CHECK (seat_limit IS NULL OR seat_limit > 0),
    device_integration_required BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Bulut hizmetlerine abonelik bilgilerini tutar
CREATE TABLE IF NOT EXISTS saas_active_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    subscriber_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    subscriber_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    order_id UUID NOT NULL REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    current_period_end TIMESTAMP WITH TIME ZONE,
    saas_active_subscription_status SMALLINT NOT NULL DEFAULT 0,    -- 0=ACTIVE, 1=PAST_DUE, 2=CANCELLED, 3=EXPIRED
    CONSTRAINT chk_saas_subscriber CHECK (
        (subscriber_user_id IS NOT NULL AND subscriber_institution_id IS NULL) OR
        (subscriber_institution_id IS NOT NULL AND subscriber_user_id IS NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_saas_subs_period_end ON saas_active_subscriptions(current_period_end) WHERE status = 0;

-- Ölçülebilir kaynak abonelikleri 
CREATE TABLE IF NOT EXISTS hosting_resource_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    subscriber_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    subscriber_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    resource_pool_id UUID REFERENCES consortium_resource_pools(id) ON DELETE RESTRICT,
    allocated_capacity DECIMAL(18, 8) NOT NULL CHECK (allocated_capacity > 0),
    unit_symbol VARCHAR(20) NOT NULL,
    billing_cycle SMALLINT NOT NULL DEFAULT 0,
    hosting_resource_subscription_status SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_hosting_subscriber CHECK (
        (subscriber_user_id IS NOT NULL AND subscriber_institution_id IS NULL) OR
        (subscriber_institution_id IS NOT NULL AND subscriber_user_id IS NULL)
    )
);

-- Ozel siparis urunlerinin detay bilgilerini tutar
CREATE TABLE IF NOT EXISTS custom_production_details (
    order_id UUID PRIMARY KEY REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    spec_json JSONB NOT NULL DEFAULT '{}'::jsonb,   -- ölçü, materyal, gravür metni, renk vb.
    proof_required BOOLEAN NOT NULL DEFAULT true,
    proof_media_id UUID REFERENCES media_assets(id),
    proof_approved_at TIMESTAMP WITH TIME ZONE,
    estimated_completion_date DATE,
    actual_completion_date DATE,
    custom_production_detail_status SMALLINT NOT NULL DEFAULT 0,-- 0=SPEC_PENDING,1=PROOF_SENT,2=APPROVED,3=IN_PRODUCTION,4=COMPLETED
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Hammade tanimlamalarini tutar
CREATE TABLE IF NOT EXISTS raw_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    material_code VARCHAR(50) NOT NULL,
    material_name VARCHAR(150) NOT NULL,
    unit_symbol VARCHAR(20) NOT NULL,              -- 'KG','LT','ADET','M2','M3','TON' vb.
    default_supplier_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT, -- opsiyonel, ana tedarikçi
    min_stock_alert_qty DECIMAL(18, 4) DEFAULT 0.00 CHECK (min_stock_alert_qty >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT unq_institution_material_code UNIQUE (institution_id, material_code)
);

CREATE INDEX IF NOT EXISTS idx_raw_materials_institution ON raw_materials(institution_id);

-- Alt sirketlerin hammade stoklarinin sube bazli bilgilerini tutar
CREATE TABLE IF NOT EXISTS raw_material_branch_stock (
    raw_material_id UUID NOT NULL REFERENCES raw_materials(id) ON DELETE RESTRICT,
    branch_id UUID NOT NULL REFERENCES institution_branches(id) ON DELETE RESTRICT,
    stock_quantity DECIMAL(18, 4) NOT NULL DEFAULT 0.00 CHECK (stock_quantity >= 0),
    reserved_quantity DECIMAL(18, 4) NOT NULL DEFAULT 0.00 CHECK (reserved_quantity >= 0),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (raw_material_id, branch_id),
    CONSTRAINT chk_raw_reserved_lte_stock CHECK (reserved_quantity <= stock_quantity)
);

CREATE INDEX IF NOT EXISTS idx_rmbs_branch ON raw_material_branch_stock(branch_id);

-- Alt sirketlerin hammade hareketlerinin muhasebe defteri
CREATE TABLE IF NOT EXISTS raw_material_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    raw_material_id UUID NOT NULL REFERENCES raw_materials(id) ON DELETE RESTRICT,
    branch_id UUID NOT NULL REFERENCES institution_branches(id) ON DELETE RESTRICT,
    movement_type SMALLINT NOT NULL,               -- enum_raw_material_movement_type
    quantity_delta DECIMAL(18, 4) NOT NULL,        -- pozitif=artış, negatif=azalış
    reference_type VARCHAR(30),                    -- 'SUPPLIER_PURCHASE','PRODUCTION_RUN','MANUAL_ADJUSTMENT'
    reference_id UUID,
    performed_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_raw_movement_delta_sign CHECK (
        (movement_type IN (0, 2) AND quantity_delta > 0) OR  -- PURCHASE_INTAKE / RETURN_TO_SUPPLIER pozitif kayıt
        (movement_type IN (1, 4) AND quantity_delta < 0) OR  -- PRODUCTION_CONSUMPTION, WASTE_SCRAP negatif
        (movement_type = 3)                                    -- ADJUSTMENT her iki yönde olabilir
    )
);

CREATE INDEX IF NOT EXISTS idx_raw_movements_material_branch ON raw_material_movements(raw_material_id, branch_id);
CREATE INDEX IF NOT EXISTS idx_raw_movements_reference ON raw_material_movements(reference_type, reference_id);

-- Alt sirketlerin recete bilgilerini tutar
CREATE TABLE IF NOT EXISTS production_recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,  -- üretilen bitmiş ürün/hizmet
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    recipe_name VARCHAR(150) NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    output_quantity DECIMAL(18, 4) NOT NULL CHECK (output_quantity > 0), -- 1 standart parti kaç adet/birim üretir
    output_unit_symbol VARCHAR(20) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_recipe_listing_version UNIQUE (listing_id, version)
);

CREATE INDEX IF NOT EXISTS idx_recipes_listing ON production_recipes(listing_id);
CREATE INDEX IF NOT EXISTS idx_recipes_institution ON production_recipes(institution_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_active_recipe_per_listing
    ON production_recipes (listing_id) WHERE is_active = true;

-- Alt sirket recete detaylari
CREATE TABLE IF NOT EXISTS production_recipe_components (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES production_recipes(id) ON DELETE RESTRICT,
    raw_material_id UUID NOT NULL REFERENCES raw_materials(id) ON DELETE RESTRICT,
    quantity_per_batch DECIMAL(18, 4) NOT NULL CHECK (quantity_per_batch > 0), -- output_quantity başına gereken miktar
    notes TEXT,
    CONSTRAINT unq_recipe_component UNIQUE (recipe_id, raw_material_id)
);

CREATE INDEX IF NOT EXISTS idx_recipe_components_recipe ON production_recipe_components(recipe_id);

--Alt sirketlerin uretim planlama bilgilerini tutar
CREATE TABLE IF NOT EXISTS production_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES production_recipes(id) ON DELETE RESTRICT,
    branch_id UUID NOT NULL REFERENCES institution_branches(id) ON DELETE RESTRICT,
    cadence SMALLINT NOT NULL DEFAULT 3,           -- enum_production_cadence
    planned_quantity_per_cycle DECIMAL(18, 4) NOT NULL CHECK (planned_quantity_per_cycle > 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    next_run_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_prod_schedules_recipe ON production_schedules(recipe_id);
CREATE INDEX IF NOT EXISTS idx_prod_schedules_branch ON production_schedules(branch_id);
CREATE INDEX IF NOT EXISTS idx_prod_schedules_due ON production_schedules(next_run_at) WHERE is_active = true;

-- Alt sirketlerin fiili uretim partilerini lotlarini tutar
CREATE TABLE IF NOT EXISTS production_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id UUID REFERENCES production_schedules(id) ON DELETE RESTRICT, -- NULL = ad-hoc/tek parti
    recipe_id UUID NOT NULL REFERENCES production_recipes(id) ON DELETE RESTRICT,
    branch_id UUID NOT NULL REFERENCES institution_branches(id) ON DELETE RESTRICT,
    batch_number VARCHAR(50) NOT NULL,             -- parti/lot no
    cadence SMALLINT NOT NULL DEFAULT 0,           -- enum_production_cadence (plandan kopyalanır ya da 0=SINGLE_BATCH)
    planned_output_quantity DECIMAL(18, 4) NOT NULL CHECK (planned_output_quantity > 0),
    actual_output_quantity DECIMAL(18, 4) CHECK (actual_output_quantity IS NULL OR actual_output_quantity >= 0),
    waste_quantity DECIMAL(18, 4) DEFAULT 0.00 CHECK (waste_quantity >= 0),
    production_run_status SMALLINT NOT NULL DEFAULT 0,            -- enum_production_run_status
    supervised_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    scheduled_start TIMESTAMP WITH TIME ZONE,
    actual_start TIMESTAMP WITH TIME ZONE,
    actual_end TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_recipe_batch_number UNIQUE (recipe_id, batch_number),
    CONSTRAINT chk_production_run_dates CHECK (actual_end IS NULL OR actual_start IS NULL OR actual_end >= actual_start)
);

CREATE INDEX IF NOT EXISTS idx_production_runs_recipe ON production_runs(recipe_id);
CREATE INDEX IF NOT EXISTS idx_production_runs_branch_status ON production_runs(branch_id, status);
CREATE INDEX IF NOT EXISTS idx_production_runs_schedule ON production_runs(schedule_id) WHERE schedule_id IS NOT NULL;

-- Alt sirketlerde uretilen urun ile kullanilan hammade bilgilerini farklarini tutar
CREATE TABLE IF NOT EXISTS production_run_consumptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    production_run_id UUID NOT NULL REFERENCES production_runs(id) ON DELETE RESTRICT,
    raw_material_id UUID NOT NULL REFERENCES raw_materials(id) ON DELETE RESTRICT,
    planned_quantity DECIMAL(18, 4) NOT NULL CHECK (planned_quantity >= 0),
    actual_quantity_consumed DECIMAL(18, 4) NOT NULL CHECK (actual_quantity_consumed >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_run_consumption_material UNIQUE (production_run_id, raw_material_id)
);

CREATE INDEX IF NOT EXISTS idx_run_consumptions_run ON production_run_consumptions(production_run_id);

-- Alt sirketlerin tedarikci bilgilerini tutar
CREATE TABLE IF NOT EXISTS distributor_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    manufacturer_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    distributor_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    b2b_agreement_id UUID REFERENCES b2b_corporate_agreements(id) ON DELETE RESTRICT, -- opsiyonel, fiyat/indirim koşulu oradan miras alınabilir
    minimum_order_quantity DECIMAL(18, 4) CHECK (minimum_order_quantity IS NULL OR minimum_order_quantity > 0),
    price_tier_json JSONB DEFAULT '{}'::jsonb,     -- miktar kademeli özel fiyatlandırma
    payment_terms_days INTEGER DEFAULT 0 CHECK (payment_terms_days >= 0),
    delivery_frequency SMALLINT NOT NULL DEFAULT 3, -- enum_distributor_delivery_frequency
    is_active BOOLEAN NOT NULL DEFAULT true,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_distributor_institutions CHECK (manufacturer_institution_id <> distributor_institution_id),
    CONSTRAINT unq_manufacturer_distributor UNIQUE (manufacturer_institution_id, distributor_institution_id)
);

CREATE INDEX IF NOT EXISTS idx_dist_rel_manufacturer ON distributor_relationships(manufacturer_institution_id);
CREATE INDEX IF NOT EXISTS idx_dist_rel_distributor ON distributor_relationships(distributor_institution_id);

-- Alt sirketlerde hammadde stoklarinin guncellenme bilgilerini tutar
CREATE TABLE IF NOT EXISTS distributor_stock_sync_log (
    id BIGSERIAL PRIMARY KEY,
    distributor_relationship_id UUID NOT NULL REFERENCES distributor_relationships(id) ON DELETE RESTRICT,
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    reported_stock_quantity INTEGER NOT NULL CHECK (reported_stock_quantity >= 0),
    source SMALLINT NOT NULL DEFAULT 0,            -- enum_stock_sync_source
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_dist_stock_sync_relationship ON distributor_stock_sync_log(distributor_relationship_id, listing_id, synced_at DESC);

COMMENT ON TABLE distributor_stock_sync_log IS 'Append-only: hangi distribütöre hangi ürünün stok bilgisi ne zaman iletildi.';

-- Sigortacilik hizmetlerinin detay bilgilerini tutar
CREATE TABLE IF NOT EXISTS insurance_product_details (
    listing_id UUID PRIMARY KEY REFERENCES listings(id) ON DELETE RESTRICT,
    insurance_type SMALLINT NOT NULL,              -- category_code ile aynı aile (110-115), bilgi amaçlı tekrar
    coverage_scope_json JSONB NOT NULL DEFAULT '{}'::jsonb, -- kapsam detayları (teminat kalemleri, istisnalar)
    deductible_amount DECIMAL(18, 8) DEFAULT 0.00 CHECK (deductible_amount >= 0), -- muafiyet tutarı
    max_coverage_amount DECIMAL(18, 8) NOT NULL CHECK (max_coverage_amount > 0),
    currency SMALLINT NOT NULL,
    waiting_period_days INTEGER DEFAULT 0 CHECK (waiting_period_days >= 0), -- poliçe başlangıcından itibaren bekleme süresi
    default_related_app_id SMALLINT,               -- örn. 17=sağlık, 29=araç, 20=gayrimenkul, NULL=genel/hayat
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Sigortacilik hizmetlerinin police bilgilerini tutar
CREATE TABLE IF NOT EXISTS insurance_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    order_id UUID NOT NULL REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    issuing_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT, -- sigortacı kurum (App1, lisans 104)
    policyholder_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT, -- primi ödeyen/poliçeyi satın alan
    insured_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,               -- sigortalanan kişi (poliçe sahibinden farklı olabilir, örn. aile ferdi)
    insured_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT, -- kurumsal poliçe ise (örn. filo/işyeri sigortası)
    policy_number VARCHAR(50) UNIQUE NOT NULL,
    premium_amount DECIMAL(18, 8) NOT NULL CHECK (premium_amount > 0),
    premium_currency SMALLINT NOT NULL,
    billing_cycle SMALLINT NOT NULL DEFAULT 0,      -- enum_insurance_billing_cycle
    coverage_start_at TIMESTAMP WITH TIME ZONE NOT NULL,
    coverage_end_at TIMESTAMP WITH TIME ZONE NOT NULL,
    insurance_polici_status SMALLINT NOT NULL DEFAULT 0,             -- enum_insurance_policy_status
    related_app_id SMALLINT,
    related_entity_type VARCHAR(30),
    related_entity_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_policy_dates CHECK (coverage_end_at > coverage_start_at),
    CONSTRAINT chk_policy_insured_ref CHECK (
        (insured_user_id IS NOT NULL AND insured_institution_id IS NULL) OR
        (insured_institution_id IS NOT NULL AND insured_user_id IS NULL) OR
        (insured_user_id IS NULL AND insured_institution_id IS NULL) -- ikisi de boşsa policyholder = sigortalı kabul edilir
    ),
    CONSTRAINT chk_related_entity_pair CHECK (
        (related_entity_type IS NULL AND related_entity_id IS NULL) OR
        (related_entity_type IS NOT NULL AND related_entity_id IS NOT NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_policies_policyholder ON insurance_policies(policyholder_user_id);
CREATE INDEX IF NOT EXISTS idx_policies_insured_user ON insurance_policies(insured_user_id) WHERE insured_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_policies_issuer ON insurance_policies(issuing_institution_id);
CREATE INDEX IF NOT EXISTS idx_policies_related ON insurance_policies(related_app_id, related_entity_type, related_entity_id) WHERE related_entity_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_policies_status ON insurance_policies(insurance_polici_status);

-- Sigorta urunlerinin prim odeme bilgilerini tutar
CREATE TABLE IF NOT EXISTS insurance_premium_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_id UUID NOT NULL REFERENCES insurance_policies(id) ON DELETE RESTRICT,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    currency SMALLINT NOT NULL,
    due_date DATE NOT NULL,
    paid_at TIMESTAMP WITH TIME ZONE,
    transaction_id UUID,
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    journal_entry_id UUID REFERENCES journal_entries(id) ON DELETE RESTRICT,
    insurance_premium_payment_status SMALLINT NOT NULL DEFAULT 0,             -- enum_insurance_premium_status
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_premium_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_premium_payments_policy ON insurance_premium_payments(policy_id, due_date);
CREATE INDEX IF NOT EXISTS idx_premium_payments_status ON insurance_premium_payments(insurance_premium_payment_status) WHERE insurance_premium_payment_status IN (0, 2);

-- Sigorta urunlerinde hasar kayitlarini tutar
CREATE TABLE IF NOT EXISTS insurance_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_id UUID NOT NULL REFERENCES insurance_policies(id) ON DELETE RESTRICT,
    claimant_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    claim_number VARCHAR(50) UNIQUE NOT NULL,
    incident_date DATE NOT NULL,
    reported_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    claimed_amount DECIMAL(18, 8) NOT NULL CHECK (claimed_amount > 0),
    approved_amount DECIMAL(18, 8) DEFAULT 0.00 CHECK (approved_amount >= 0),
    currency SMALLINT NOT NULL,
    description TEXT NOT NULL,
    evidence_media_ids UUID[] DEFAULT '{}',
    related_order_id UUID REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    insurance_claim_status SMALLINT NOT NULL DEFAULT 0,             -- enum_insurance_claim_status
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_claim_approved_lte_claimed CHECK (approved_amount <= claimed_amount)
);

CREATE INDEX IF NOT EXISTS idx_claims_policy ON insurance_claims(policy_id);
CREATE INDEX IF NOT EXISTS idx_claims_claimant ON insurance_claims(claimant_user_id);
CREATE INDEX IF NOT EXISTS idx_claims_status ON insurance_claims(insurance_claim_status);

-- Sigorta urunlerinde hasar kayitlarinin geriye donuk bilgilerini tutar
CREATE TABLE IF NOT EXISTS insurance_claim_adjudications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID NOT NULL REFERENCES insurance_claims(id) ON DELETE RESTRICT,
    reviewed_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,  -- sigortacının hasar eksperi
    decision SMALLINT NOT NULL,                     -- enum_insurance_adjudication_decision
    decided_amount DECIMAL(18, 8) CHECK (decided_amount IS NULL OR decided_amount >= 0),
    notes TEXT,
    decided_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_adjudications_claim ON insurance_claim_adjudications(claim_id, decided_at DESC);

-- Sigorta urunlerinde zarar karsilama bilgilerini tutar
CREATE TABLE IF NOT EXISTS insurance_claim_payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id UUID NOT NULL REFERENCES insurance_claims(id) ON DELETE RESTRICT,
    real_world_account_id INTEGER NOT NULL REFERENCES real_world_accounts(id) ON DELETE RESTRICT,
    payout_amount DECIMAL(18, 8) NOT NULL CHECK (payout_amount > 0),
    currency SMALLINT NOT NULL,
    journal_entry_id UUID REFERENCES journal_entries(id) ON DELETE RESTRICT,
    issued_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    issued_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    insurance_claim_payout_status SMALLINT NOT NULL DEFAULT 1,
    paid_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_claim_payouts_claim ON insurance_claim_payouts(claim_id);

-- Kombine sistemlerin dis kaynak senkronizasyon bilgilerini tutar
CREATE TABLE IF NOT EXISTS sync_routing_rules (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) UNIQUE NOT NULL,
    target_systems TEXT[] NOT NULL DEFAULT '{}',   -- ör: {'MONGODB','REDIS'} veya {'NEO4J'} veya {'INFLUXDB'}
    is_active BOOLEAN NOT NULL DEFAULT true,
    notes TEXT
);

-- Başlangıç yönlendirme kuralları (örnek — ihtiyaca göre genişletilir):
INSERT INTO sync_routing_rules (table_name, target_systems, notes) VALUES
    ('listings', ARRAY['MONGODB','REDIS'], 'Hızlı okuma + önbellek'),
    ('marketplace_orders', ARRAY['MONGODB','REDIS'], 'Sipariş durumu hızlı okuma'),
    ('ratings', ARRAY['MONGODB','NEO4J'], 'Detay okuma + öneri grafiği ilişkisi'),
    ('user_domain_reputations', ARRAY['NEO4J','REDIS'], 'Öneri motoru + hızlı skor önbelleği'),
    ('institution_domain_reputations', ARRAY['NEO4J','REDIS'], 'Öneri motoru + hızlı skor önbelleği'),
    ('institution_sla_metrics', ARRAY['INFLUXDB'], 'Zaman-serisi operasyonel analiz'),
    ('logistics_status_events', ARRAY['INFLUXDB','MONGODB'], 'Zaman-serisi + detay okuma'),
    ('collaboration_agreements', ARRAY['NEO4J'], 'B2B ilişki grafiği'),
    ('consortium_members', ARRAY['NEO4J'], 'Konsorsiyum ilişki grafiği')
ON CONFLICT (table_name) DO NOTHING;

-- 2. OUTBOX TABLOSU — tüm değişiklikler önce buraya, sonra RabbitMQ'ya
CREATE TABLE IF NOT EXISTS sync_outbox (
    id BIGSERIAL PRIMARY KEY,
    aggregate_type VARCHAR(100) NOT NULL,          -- tablo adı
    aggregate_id TEXT NOT NULL,                    -- kaydın PK'si (UUID/SERIAL fark etmeksizin TEXT)
    operation VARCHAR(10) NOT NULL,                -- INSERT / UPDATE / DELETE
    payload JSONB NOT NULL,
    target_systems TEXT[] NOT NULL,
    sync_outbox_status SMALLINT NOT NULL DEFAULT 0,            -- enum_outbox_status
    attempt_count INTEGER NOT NULL DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_outbox_pending ON sync_outbox (sync_outbox_status, created_at) WHERE sync_outbox_status = 0;
CREATE INDEX IF NOT EXISTS idx_outbox_aggregate ON sync_outbox (aggregate_type, aggregate_id);

-- Not: sync_routing_rules'a yeni bir satır eklediğinizde (yeni tablo), 
-- o tabloya da aynı desenle CREATE TRIGGER ... EXECUTE FUNCTION fn_emit_sync_event(); eklemeniz yeterli.
-- 4. IoT / TELEMETRİ HAM VERİ STAGING (MQTT -> buraya kısa süreli yazılır -> Python worker InfluxDB'ye taşır)
-- (akıllı bina/IoT),(akıllı araç) için.
CREATE TABLE IF NOT EXISTS iot_telemetry_staging (
    id BIGSERIAL PRIMARY KEY,
    device_reference VARCHAR(100) NOT NULL,        -- MQTT topic/cihaz kimliği
    listing_id UUID REFERENCES listings(id) ON DELETE RESTRICT,
    metric_name VARCHAR(50) NOT NULL,               -- 'TEMPERATURE','FUEL_LEVEL','LOCATION', vb.
    metric_value DOUBLE PRECISION,
    metric_payload JSONB,                            -- karmaşık ölçümler için (örn. {"lat":..,"lng":..})
    received_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    exported_to_influx BOOLEAN NOT NULL DEFAULT false,
    exported_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_iot_staging_pending ON iot_telemetry_staging (exported_to_influx, received_at) WHERE exported_to_influx = false;
CREATE INDEX IF NOT EXISTS idx_iot_staging_device ON iot_telemetry_staging (device_reference, received_at);

-- NOT: Bu tablo YÜKSEK HACİMLİ ve KISA ÖMÜRLÜ bir staging alanı — hard-delete
-- yasağı burada UYGULANMAZ (append-only muhasebe/log verisi değil, ham telemetri
-- aktarım tamponu). Python worker, exported_to_influx=true olan ve N günden eski
-- satırları düzenli olarak temizler (bu tek istisnai tablo).
-- 5. MinIO DOSYA DEPOLAMA REFERANSLARI (media_assets'i bozmadan, ayrı eşleme tablosu)

CREATE TABLE IF NOT EXISTS media_asset_storage_refs (
    media_asset_id UUID PRIMARY KEY REFERENCES media_assets(id) ON DELETE RESTRICT,
    storage_backend VARCHAR(20) NOT NULL DEFAULT 'MINIO',
    bucket_name VARCHAR(100) NOT NULL,
    object_key VARCHAR(500) NOT NULL,
    content_type VARCHAR(100),
    size_bytes BIGINT CHECK (size_bytes IS NULL OR size_bytes >= 0),
    checksum_sha256 VARCHAR(64),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_bucket_object UNIQUE (bucket_name, object_key)
);

-- HARİCİ SİSTEM KİMLİK EŞLEMESİ (Postgres id <-> Mongo _id / Neo4j node id — hata ayıklama/geri izleme için)
CREATE TABLE IF NOT EXISTS external_read_model_refs (
    id BIGSERIAL PRIMARY KEY,
    aggregate_type VARCHAR(100) NOT NULL,
    aggregate_id TEXT NOT NULL,
    target_system VARCHAR(20) NOT NULL,             -- 'MONGODB','NEO4J'
    external_ref TEXT NOT NULL,                      -- mongo ObjectId / neo4j node id, string olarak
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_external_ref UNIQUE (aggregate_type, aggregate_id, target_system)
);

CREATE INDEX IF NOT EXISTS idx_external_refs_lookup ON external_read_model_refs (aggregate_type, aggregate_id);

-- Sistem ortaklarinin ve alt sirket sahiplerinin maddi mal varlik kayitlarini tutar
CREATE TABLE IF NOT EXISTS fixed_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    branch_id UUID REFERENCES institution_branches(id) ON DELETE RESTRICT, -- opsiyonel: belirli bir şubede kullanılıyorsa
    asset_type SMALLINT NOT NULL,          -- enum_fixed_asset_type
    asset_name VARCHAR(200) NOT NULL,      -- "Merkez Ofis Binası", "34 ABC 123 plakalı kamyon"
    description TEXT,
    title_deed_no VARCHAR(100),            -- gayrimenkul/fabrika/arsa tapu no
    plate_number VARCHAR(20),               -- taşıt plakası
    serial_number VARCHAR(100),             -- demirbaş/makine seri no
    address TEXT,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    acquisition_value DECIMAL(18, 8) NOT NULL CHECK (acquisition_value > 0),
    acquisition_currency VARCHAR(10) NOT NULL,
    acquisition_date DATE NOT NULL,
    current_book_value DECIMAL(18, 8) NOT NULL CHECK (current_book_value >= 0), -- en son değerlemeyle senkron (BÖLÜM 3)
    contributed_as_capital BOOLEAN NOT NULL DEFAULT false,
    contributing_position_id INTEGER REFERENCES worker_institution_positions(id) ON DELETE RESTRICT, -- kurum ortağıysa
    contributing_shareholder_id INTEGER REFERENCES system_shareholders(id) ON DELETE RESTRICT,        -- holding hissedarıysa
    fixed_asset_status SMALLINT NOT NULL DEFAULT 0,     -- enum_fixed_asset_status
    disposal_reason TEXT,
    disposed_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    registered_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_fa_contribution_ref CHECK (
        NOT contributed_as_capital OR (contributing_position_id IS NOT NULL OR contributing_shareholder_id IS NOT NULL)
    ),
    CONSTRAINT chk_fa_single_contributor CHECK (
        NOT (contributing_position_id IS NOT NULL AND contributing_shareholder_id IS NOT NULL)
    ),
    CONSTRAINT chk_fa_disposal_reason_required CHECK (
        fixed_asset_status NOT IN (2, 3, 4) OR disposal_reason IS NOT NULL
    )
);

CREATE INDEX IF NOT EXISTS idx_fixed_assets_institution ON fixed_assets(institution_id) WHERE institution_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fixed_assets_branch ON fixed_assets(branch_id) WHERE branch_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fixed_assets_type ON fixed_assets(asset_type);
CREATE INDEX IF NOT EXISTS idx_fixed_assets_contributor_position ON fixed_assets(contributing_position_id) WHERE contributing_position_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fixed_assets_contributor_shareholder ON fixed_assets(contributing_shareholder_id) WHERE contributing_shareholder_id IS NOT NULL;

COMMENT ON TABLE fixed_assets IS 'Holding veya alt kurumların maddi duran varlıkları (ofis binası, fabrika, demirbaş, taşıt). institution_id NULL = doğrudan holding malı. Sermaye katkısı olarak sunulan varlıklar contributed_as_capital=true ile işaretlenir.';
COMMENT ON COLUMN fixed_assets.current_book_value IS 'Fiziksel olarak burada tutulur ama gerçek kaynak fixed_asset_valuations tablosudur — trigger ile otomatik senkron edilir, elle güncellenmemelidir.';

-- Mal varliklarin evrak kayitlarini tutar
CREATE TABLE IF NOT EXISTS fixed_asset_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fixed_asset_id UUID NOT NULL REFERENCES fixed_assets(id) ON DELETE RESTRICT,
    media_asset_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT, -- MinIO fiziksel dosyaya media_asset_storage_refs (19) üzerinden bağlanır
    document_type SMALLINT NOT NULL,        -- enum_fixed_asset_document_type
    document_title VARCHAR(200),
    uploaded_by_worker_id INTEGER REFERENCES workers(id) ON DELETE RESTRICT,
    uploaded_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_fad_uploader CHECK (
        (uploaded_by_worker_id IS NOT NULL AND uploaded_by_admin_id IS NULL) OR
        (uploaded_by_admin_id IS NOT NULL AND uploaded_by_worker_id IS NULL)
    )
);

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
    appraisal_document_id UUID REFERENCES fixed_asset_documents(id) ON DELETE RESTRICT,
    notes TEXT,
    recorded_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_fa_valuations_asset ON fixed_asset_valuations(fixed_asset_id, valuation_date DESC);

-- Sistem ortagi veya Alt sirket ortaklarinin varlik katki defteri
CREATE TABLE IF NOT EXISTS institution_capital_contributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    position_id INTEGER REFERENCES worker_institution_positions(id) ON DELETE RESTRICT,   -- kurum ortağıysa
    shareholder_id INTEGER REFERENCES system_shareholders(id) ON DELETE RESTRICT,          -- holding hissedarıysa
    institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,                 -- position_id varsa denormalize kopya
    contribution_type SMALLINT NOT NULL,        -- enum_contribution_type
    cash_amount DECIMAL(18, 8),
    cash_currency SMALLINT,
    fixed_asset_id UUID REFERENCES fixed_assets(id) ON DELETE RESTRICT,
    contribution_value DECIMAL(18, 8) NOT NULL CHECK (contribution_value > 0), -- ortak para biriminde (valuation_currency) normalize DEĞER
    valuation_currency SMALLINT NOT NULL,
    institution_capital_contribution_status SMALLINT NOT NULL DEFAULT 0,          -- enum_contribution_status
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolution_notes TEXT,
    contributed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    recorded_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT,
    CONSTRAINT chk_icc_owner CHECK (
        (position_id IS NOT NULL AND shareholder_id IS NULL) OR
        (shareholder_id IS NOT NULL AND position_id IS NULL)
    ),
    CONSTRAINT chk_icc_type_fields CHECK (
        (contribution_type = 0 AND cash_amount IS NOT NULL AND cash_currency IS NOT NULL AND fixed_asset_id IS NULL) OR
        (contribution_type = 1 AND fixed_asset_id IS NOT NULL AND cash_amount IS NULL AND cash_currency IS NULL)
    )
);

CREATE INDEX IF NOT EXISTS idx_icc_position ON institution_capital_contributions(position_id) WHERE position_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_icc_shareholder ON institution_capital_contributions(shareholder_id) WHERE shareholder_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_icc_institution_active ON institution_capital_contributions(institution_id, institution_capital_contribution_status) WHERE institution_id IS NOT NULL;

COMMENT ON TABLE institution_capital_contributions IS
 'Ortak/hissedar başına nakit + fiziksel varlık katkı defteri. equity_percentage/share_percentage BU TABLODAN türetilir (bkz. fn_recalculate_institution_equity / fn_recalculate_holding_equity). Ledger boşsa eski manuel yüzde ataması geçerliliğini korur.';

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
    revoked_by_admin_id INTEGER REFERENCES admins(id) ON DELETE RESTRICT  -- FORCED_BY_ADMIN ise dolu
);

CREATE INDEX IF NOT EXISTS idx_auth_sessions_user ON auth_sessions(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_jti ON auth_sessions(token_jti) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_auth_sessions_active_window ON auth_sessions(user_id, issued_at, last_seen_at) WHERE is_active = true;

COMMENT ON TABLE auth_sessions IS
 'Her login ile bir satır açılır. Middleware her istekte token_jti''nin is_active=true olduğunu doğrulamalı (JWT tek başına yeterli kimlik kanıtı DEĞİLDİR — DB/Redis''teki oturum durumu esastır).';

COMMIT;