BEGIN;

CREATE SCHEMA IF NOT EXISTS nolbir_flutter;
SET search_path TO nolbir_flutter;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA nolbir_flutter;
CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA nolbir_flutter;

-- Kombine sistemlerin dis kaynak senkronizasyon bilgilerini tutar 
CREATE TABLE IF NOT EXISTS sync_routing_rules (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) UNIQUE NOT NULL,
    target_systems SMALLINT[] NOT NULL DEFAULT '{}',  
    is_active BOOLEAN NOT NULL DEFAULT true,
    notes TEXT );

-- Başlangıç yönlendirme kuralları (örnek — ihtiyaca göre genişletilir):
INSERT INTO sync_routing_rules (table_name, target_systems, notes) VALUES
    ('supported_currencies', ARRAY[0,3], 'Sıcak referans verisi: doğrulama/format'),   -- MONGODB,REDIS
    ('government_tax_authorities', ARRAY[0], 'Referans verisi okuma kopyası'),             -- MONGODB
    ('tax_rates_and_rules', ARRAY[0,3], 'Vergi hesabı: Mongo okuma + Redis geçersiz kılma'), -- MONGODB,REDIS
    ('users', ARRAY[0,1,3], 'Profil okuma kopyası + ilişki grafiği + oturum/önbellek'), -- MONGODB,NEO4J,REDIS
    ('approvals', ARRAY[0,5], 'Okuma kopyası + yeni onayın AI analizi (yalnızca INSERT kuyruğa bağlı)'),   -- MONGODB,AI_ANALYSIS
    ('approval_eligible_voters', ARRAY[0], 'Seçmen atamaları okuma kopyası'),
    ('approval_votes', ARRAY[0], 'Oy dökümü okuma kopyası'),
    ('workers',  ARRAY[0], 'Çalışan profili okuma kopyası'),
    ('media_assets', ARRAY[0,6,7], 'Okuma kopyası + insert''te güvenlik taraması ve transcode işi (yalnızca INSERT kuyruğa bağlı)'),  -- MONGODB,MEDIA_SCAN,MEDIA_TRANSCODE
    ('institutions', ARRAY[0,1,3], 'Okuma kopyası + kurum düğümü (graf) + önbellek geçersiz kılma'),   -- MONGODB,NEO4J,REDIS
    ('license_types', ARRAY[0], 'Lisans türü referansı okuma kopyası'),
    ('institution_licenses', ARRAY[0,3], 'Okuma kopyası + lisans önbelleği geçersiz kılma'),                  -- MONGODB,REDIS
    ('partner_banks', ARRAY[0], 'Banka anlaşmaları okuma kopyası'),
    ('real_world_accounts', ARRAY[0], 'Okuma kopyası; IBAN senkronize edilmez, bakiye karar için kullanılmaz'),
    ('chart_of_accounts', ARRAY[0], 'Hesap planı rapor okuma kopyası; bakiye kararı için kullanılmaz'),
    ('journal_entries', ARRAY[0], 'Fiş başlığı okuma kopyası'),
    ('journal_entry_lines', ARRAY[0,2], 'Hesap ekstresi + tutar/hacim zaman serisi'),     -- MONGODB,INFLUXDB
    ('user_country_documents', ARRAY[0], 'Belge durumu okuma kopyası; belge numarası senkronize edilmez'),
    ('wallets', ARRAY[0], 'Cüzdan listesi/durum okuma kopyası; bakiye senkronize edilmez'),
    ('transactions', ARRAY[0], 'Cüzdan hareket geçmişi okuma kopyası'),
    ('jurisdiction_rule_types', ARRAY[0], 'Hakemlik/fesih kural türü referansı'),
    ('jurisdiction_rules', ARRAY[0,3], 'Hakemlik/fesih kuralları: Mongo okuma + Redis geçersiz kılma'),   -- MONGODB,REDIS
    ('institution_shareholders', ARRAY[0,1], 'Ortak okuma kopyası + ortaklık ilişkisi (graf)'),                 -- MONGODB,NEO4J
    ('institution_sla_metrics', ARRAY[2], 'Zaman-serisi operasyonel analiz'),                                 -- INFLUXDB
    ('institution_branches', ARRAY[0], 'Şube okuma kopyası + coğrafi arama'),
    ('worker_institution_positions', ARRAY[0,1], 'Pozisyon okuma kopyası + çalışma ilişkisi (graf)'),                   -- MONGODB,NEO4J
    ('identity_verification_sessions', ARRAY[0], 'Görüşme durumu/randevu okuma kopyası'),
    ('user_verification_levels', ARRAY[0,3], 'Doğrulama seviyesi okuma kopyası + önbellek geçersiz kılma'),         -- MONGODB,REDIS
    ('verification_requirements', ARRAY[0,3], 'Seviye gereksinim referansı: Mongo okuma + Redis geçersiz kılma'),
    ('promotions', ARRAY[0], 'Kampanya okuma kopyası'),
    ('promotion_redemptions', ARRAY[0], 'Promosyon kullanım geçmişi okuma kopyası'),
    ('consortiums', ARRAY[0,1], 'Konsorsiyum okuma kopyası + ilişki grafiği'),                    -- MONGODB,NEO4J
    ('consortium_members', ARRAY[0,1], 'Üyelik okuma kopyası + üyelik ilişkisi (graf)'),
    ('consortium_resource_pools', ARRAY[0], 'Kaynak havuzu okuma kopyası; kapasite kararı Postgres''ten'),
    ('b2b_corporate_agreements', ARRAY[0,1], 'B2B anlaşma okuma kopyası + kurumlar arası ilişki (graf)'),
    ('consortium_resource_usage', ARRAY[0], 'Kaynak kullanım geçmişi okuma kopyası'),
    ('institution_government_tax_accounts', ARRAY[0], 'Vergi hesabı rapor okuma kopyası; bakiye kararı için kullanılmaz'),
    ('tax_filing_periods', ARRAY[0], 'Vergi dönemi/beyan okuma kopyası'),
    ('tax_accruals', ARRAY[0], 'Vergi tahakkuk kayıtları okuma kopyası (değiştirilemez)'),
    ('institution_privilege_tiers', ARRAY[0], 'İmtiyaz eşiği referansı (gerekçe herkese açık)'),
    ('institution_privilege_grants', ARRAY[0,3], 'Kazanılan imtiyaz okuma kopyası + önbellek geçersiz kılma'),   -- MONGODB,REDIS
    ('institution_formation_applications', ARRAY[0], 'Şirket kurma başvurusu durumu okuma kopyası'),
    ('institution_branch_applications', ARRAY[0], 'Şube açma başvurusu durumu okuma kopyası'),
    ('institution_business_permits', ARRAY[0], 'İzin/ruhsat okuma kopyası'),
    ('payroll_runs', ARRAY[0], 'Bordro dönemi başlığı okuma kopyası; maaş satırları senkronize edilmez'),
    ('profit_distributions', ARRAY[0], 'Kâr dağıtımı başlığı okuma kopyası'),
    ('profit_distribution_lines', ARRAY[0], 'Ortak bazlı dağıtım satırları okuma kopyası'),
    ('real_world_account_movements', ARRAY[0], 'Banka hareketleri okuma kopyası; karşı hesap numarası senkronize edilmez'),
    ('institution_deposit_requests', ARRAY[0], 'Mevduat talebi durumu okuma kopyası'),
    ('reserve_reconciliations', ARRAY[0,2], 'Rezerv mutabakatı okuma kopyası + Grafana zaman serisi'),   -- MONGODB,INFLUXDB
    ('government_tax_remittances', ARRAY[0], 'Vergi ödemesi okuma kopyası'),
    ('voucher_batches', ARRAY[0], 'Kupon partisi okuma kopyası (yönetim)'),
    ('system_commissions', ARRAY[0,3], 'Komisyon oranları: Mongo okuma + Redis geçersiz kılma'),       -- MONGODB,REDIS
    ('escrow_records', ARRAY[0], 'Emanet kaydı durumu okuma kopyası'),
    ('worker_permission_catalog', ARRAY[0], 'Yetki kataloğu referansı'),
    ('worker_position_permissions', ARRAY[0], 'Pozisyon yetkileri okuma kopyası (yetki kararı Postgres''ten)'),
    ('system_feature_flags', ARRAY[0,3], 'Özellik bayrakları: Mongo okuma + Redis geçersiz kılma'),
    ('exchange_rate_sources', ARRAY[0], 'Kur kaynakları referansı'),
    ('currency_exchange_rates', ARRAY[2,3], 'Kur zaman serisi (Grafana) + Redis geçersiz kılma'),           -- INFLUXDB,REDIS
    ('currency_conversions', ARRAY[0], 'Kur dönüşümü geçmişi okuma kopyası'),
    ('commission_rules', ARRAY[0,3], 'Komisyon kuralları: Mongo okuma + Redis geçersiz kılma'),                  -- MONGODB,REDIS
    ('transaction_commissions', ARRAY[0], 'İşlem komisyon kesintileri okuma kopyası'),
    ('institution_operating_rules', ARRAY[0], 'Kurum işletme kuralları referansı'),
    ('institution_compliance_checks', ARRAY[0], 'Uyum kontrolü geçmişi okuma kopyası'),
    ('transaction_disputes_and_refunds', ARRAY[0], 'İtiraz/iade talebi durumu okuma kopyası'),
    ('complaints', ARRAY[0,5], 'Okuma kopyası + yeni şikâyetin AI analizi (yalnızca INSERT kuyruğa bağlı)'),   -- MONGODB,AI_ANALYSIS
    ('notification_campaigns', ARRAY[0], 'Bildirim kampanyası okuma kopyası'),
    ('notification_deliveries', ARRAY[0], 'Kullanıcı bildirim kutusu okuma kopyası')
ON CONFLICT (table_name) DO NOTHING;

-- 2. OUTBOX TABLOSU — tüm değişiklikler önce buraya, sonra RabbitMQ'ya
CREATE TABLE IF NOT EXISTS sync_outbox (
    id BIGSERIAL PRIMARY KEY,
    aggregate_type VARCHAR(100) NOT NULL,          -- tablo adı
    aggregate_id TEXT NOT NULL,                    -- kaydın PK'si (UUID/SERIAL fark etmeksizin TEXT)
    operation SMALLINT NOT NULL,                -- INSERT / UPDATE / DELETE
    payload JSONB NOT NULL,
    target_systems SMALLINT[] NOT NULL,
    sync_outbox_status SMALLINT NOT NULL DEFAULT 0,            -- enum_outbox_status
    attempt_count INTEGER NOT NULL DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE );
CREATE INDEX IF NOT EXISTS idx_outbox_pending ON sync_outbox (sync_outbox_status, created_at) WHERE sync_outbox_status = 0;
CREATE INDEX IF NOT EXISTS idx_outbox_aggregate ON sync_outbox (aggregate_type, aggregate_id);

-- Sistemin Log gecmisini tutar
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id TEXT NOT NULL,
    action SMALLINT NOT NULL,
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
    country_code SMALLINT NOT NULL,                  -- country_code alani her tabloda SMALLINT olmak zorundadir 0=Turkmenistan, 1=Turkiye, 2=Iran, 3=Russiya gibi devam eder enum_maps dosyasindan okunur
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
    id SERIAL PRIMARY KEY,                       
    country_code SMALLINT NOT NULL,                
    tax_authority_id INTEGER REFERENCES government_tax_authorities(id) ON DELETE RESTRICT,
    state_or_region SMALLINT,                     -- For US states or specific tax zones
    tax_type SMALLINT NOT NULL,                   -- 'VAT_KDV', 'WITHHOLDING_STOPAJ', 'STAMP_TAX', 'CORPORATE'
    category_code SMALLINT,                       -- Sub-category tax exemption or rate code
    tax_rate NUMERIC(5, 4) NOT NULL CHECK (tax_rate >= 0.0000 AND tax_rate <= 1.0000),
    is_withholding BOOLEAN DEFAULT FALSE,            -- If true, deducted at source during payouts
    is_active BOOLEAN DEFAULT TRUE,
    effective_from DATE NOT NULL,
    effective_until DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tax_effective_dates CHECK (effective_until IS NULL OR effective_until >= effective_from) );
CREATE INDEX IF NOT EXISTS idx_tax_lookup ON tax_rates_and_rules (country_code, tax_type, is_active);
COMMENT ON TABLE tax_rates_and_rules IS 'Jurisdiction and vertical specific tax calculation rules for automatic ledger splitting.';

--  Ana kullanici bilgilerini tutar
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    user_name VARCHAR(20) UNIQUE,
    birth_date DATE,
    nationality_country_code SMALLINT,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_no VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255),
    digital_pin VARCHAR(255),
    provisioning_status SMALLINT DEFAULT 0,
    provisioning_error TEXT,
    gender SMALLINT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
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
    requester_role SMALLINT NOT NULL,
    approval_type SMALLINT NOT NULL,
    approval_status SMALLINT DEFAULT 0, -- 0=PENDING, 1=APPROVED, 2=REJECTED
    priority_score INTEGER DEFAULT 0,
    total_weight NUMERIC(10,4) NOT NULL DEFAULT 0,
    approve_weight NUMERIC(10,4) NOT NULL DEFAULT 0,
    reject_weight NUMERIC(10,4) NOT NULL DEFAULT 0,
    approval_threshold  NUMERIC(5,4)  NOT NULL DEFAULT 0.5000,
    request_data JSONB NOT NULL, 
    decided_at TIMESTAMP WITH TIME ZONE,
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
    approval_id UUID NOT NULL REFERENCES approvals(id) ON DELETE RESTRICT,
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
    rw SMALLINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_topic UNIQUE (user_id, topic) );

-- MQTT kullanicisini tanimlar 
CREATE TABLE IF NOT EXISTS mqtt_user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );

-- Calisanlar tablosu calisma bilgilerini tutar
CREATE TABLE IF NOT EXISTS workers (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    worker_name VARCHAR(20),
    is_verified BOOLEAN DEFAULT false,
    rating DECIMAL(3, 2) DEFAULT 5.00 CHECK (rating BETWEEN 0 AND 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );

-- Sistemin tum media bilgilerini tutar
CREATE TABLE IF NOT EXISTS media_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    category SMALLINT NOT NULL,
    entity_type SMALLINT,
    entity_id VARCHAR(64),
    visibility SMALLINT NOT NULL DEFAULT 0,
    minio_bucket SMALLINT NOT NULL,
    minio_object_key TEXT NOT NULL,
    transcoding_status SMALLINT DEFAULT 0,
    segment_count INTEGER,
    segment_duration_seconds INTEGER DEFAULT 6,
    thumbnail_object_key TEXT,
    duration_seconds NUMERIC(8,2),
    scan_result SMALLINT,
    scanned_at TIMESTAMP WITH TIME ZONE,
    transcode_error TEXT,
    mime_type SMALLINT NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    media_status SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );

-- ANA KURUM / ŞİRKET TABLOSU bilgilerini tutar 
CREATE TABLE IF NOT EXISTS institutions (
    id SERIAL PRIMARY KEY,
    institution_name VARCHAR(150) NOT NULL,
    tax_number VARCHAR(50) NOT NULL,
    tax_office VARCHAR(100),
    legal_form SMALLINT NOT NULL DEFAULT 0,
    country_code SMALLINT NOT NULL,
    registration_number VARCHAR(50),
    incorporation_contract_media_id UUID REFERENCES media_assets(id),
    trade_registry_gazette_media_id UUID REFERENCES media_assets(id),
    board_approval_threshold DECIMAL(5,4) NOT NULL DEFAULT 0.5000 
        CHECK (board_approval_threshold > 0 AND board_approval_threshold <= 1.0000),
    collateral_stake NUMERIC(18, 8) DEFAULT 0.0000 CHECK (collateral_stake >= 0), -- Kilitli teminat tutarı
    currency SMALLINT NOT NULL DEFAULT 0,
    reputation_score NUMERIC(5, 2) DEFAULT 1.00 CHECK (reputation_score >= 0),    -- Güvenilirlik/Başarı puanı 
    is_verified BOOLEAN DEFAULT false,
    verified_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT, 
    is_active BOOLEAN NOT NULL DEFAULT true,
    compliance_status SMALLINT NOT NULL DEFAULT 0, -- 1: ACTIVE, 2: SUSPENDED_TEMP (Geçici dondurulan), 3: BANNED_PERMANENT (İhraç)
    suspension_reason TEXT,                       -- Şüpheli işlem / yasal inceleme gerekçesi
    suspended_at TIMESTAMP WITH TIME ZONE,        -- Dondurulma tarihi
    suspended_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT, -- Donduran yetkili
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_txnum_country_code UNIQUE (tax_number,country_code),
    CHECK (is_active = (compliance_status = 1)) );
CREATE INDEX IF NOT EXISTS idx_institutions_compliance ON institutions(compliance_status);
CREATE INDEX IF NOT EXISTS idx_institutions_tax ON institutions(tax_number);

CREATE TABLE IF NOT EXISTS license_types (
    license_type SMALLINT PRIMARY KEY,        -- enum_license_type (örn: operasyon/arayüz yönetimi, finans/banka anlaşmaları, doğrulama görüşmeleri)
    is_exclusive BOOLEAN NOT NULL DEFAULT false,   -- true: aynı anda tek şirkette olabilir
    CONSTRAINT uq_license_type_exclusive UNIQUE (license_type, is_exclusive) );

CREATE TABLE IF NOT EXISTS institution_licenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    license_type SMALLINT NOT NULL,
    is_exclusive BOOLEAN NOT NULL DEFAULT false,
    country_code SMALLINT,                     -- NULL = ülkeden bağımsız; dolu ise tekillik ülke bazında
    license_status SMALLINT NOT NULL DEFAULT 0, -- 0=AKTİF, 1=ASKIDA, 2=İPTAL, 3=SÜRESİ DOLDU
    valid_from DATE NOT NULL,
    valid_until DATE,
    granted_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    approval_id UUID REFERENCES approvals(id) ON DELETE RESTRICT,   -- devir/verilme onayı
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_il_type FOREIGN KEY (license_type, is_exclusive)
        REFERENCES license_types (license_type, is_exclusive) ON DELETE RESTRICT,
    CONSTRAINT chk_il_dates CHECK (valid_until IS NULL OR valid_until >= valid_from) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_il_exclusive
    ON institution_licenses (license_type, (COALESCE(country_code, -1)))
    WHERE is_exclusive AND license_status IN (0, 1);
CREATE INDEX IF NOT EXISTS idx_il_institution ON institution_licenses(institution_id, license_status);

-- Platformun bankalarla yaptığı hesap/mevduat anlaşmaları (sözleşmeyi finans şirketi yapar)
CREATE TABLE IF NOT EXISTS partner_banks (
    id SERIAL PRIMARY KEY,
    contracting_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    bank_name VARCHAR(150) NOT NULL,
    country_code SMALLINT NOT NULL,
    bank_license_number VARCHAR(100) NOT NULL,
    bank_license_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    agreement_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    partner_bank_status SMALLINT NOT NULL DEFAULT 0,
    valid_from DATE NOT NULL,
    valid_until DATE,
    created_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_pb_dates CHECK (valid_until IS NULL OR valid_until >= valid_from),
    CONSTRAINT unq_partner_bank UNIQUE (country_code, bank_license_number) );

-- Gercek dunya hesaplarini tutar
CREATE TABLE IF NOT EXISTS real_world_accounts (
    id SERIAL PRIMARY KEY,
    owner_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    owner_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    partner_bank_id INTEGER REFERENCES partner_banks(id) ON DELETE RESTRICT,   -- platform hesaplarında dolu
    account_code VARCHAR(30) UNIQUE NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    account_type SMALLINT NOT NULL,
    account_role SMALLINT NOT NULL DEFAULT 0,   -- 0=KURUM/KULLANICININ KENDİ DIŞ HESABI, 1=PLATFORM REZERV (MÜŞTERİ FONU), 2=PLATFORM İŞLETME
    country_code SMALLINT NOT NULL,
    bank_name VARCHAR(100) NOT NULL,
    iban_or_account_no VARCHAR(64) NOT NULL,
    account_holder_name VARCHAR(150) NOT NULL,
    currency SMALLINT NOT NULL,
    current_balance DECIMAL(18, 8) DEFAULT 0.00,
    ownership_proof_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    verification_status SMALLINT NOT NULL DEFAULT 0,
    verified_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    verified_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_rwa_currency UNIQUE (id, currency),
    CONSTRAINT uq_rwa_iban UNIQUE (country_code, bank_name, iban_or_account_no),
    CONSTRAINT uq_id_owner_inst_id UNIQUE (id, owner_institution_id),
    CONSTRAINT chk_rwa_single_owner CHECK (num_nonnulls(owner_institution_id, owner_user_id) = 1),
    CONSTRAINT chk_rwa_platform_owner CHECK (account_role = 0 OR owner_institution_id IS NOT NULL),
    CONSTRAINT chk_rwa_bank_link CHECK (account_role = 0 OR partner_bank_id IS NOT NULL) );

-- Her kurumun (platform sirketleri dahil) kendi hesap plani
CREATE TABLE IF NOT EXISTS chart_of_accounts (
    id SERIAL PRIMARY KEY,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    account_code VARCHAR(30) NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    account_category SMALLINT NOT NULL,
    currency SMALLINT NOT NULL,
    total_debit DECIMAL(18, 8) DEFAULT 0.00 CHECK (total_debit >= 0),
    total_credit DECIMAL(18, 8) DEFAULT 0.00 CHECK (total_credit >= 0),
    current_balance DECIMAL(18, 8) DEFAULT 0.00,
    real_world_account_id INTEGER REFERENCES real_world_accounts(id) ON DELETE RESTRICT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_coa_institution_code UNIQUE (institution_id, account_code),
    CONSTRAINT uq_coa_institution_currency UNIQUE (id, institution_id, currency),
    CONSTRAINT uq_coa_id_institution UNIQUE (id, institution_id) );

CREATE TABLE IF NOT EXISTS journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    entry_number VARCHAR(50) NOT NULL,
    trace_id UUID NOT NULL DEFAULT gen_random_uuid(),
    journal_entry_description TEXT NOT NULL,
    reference_type SMALLINT,
    reference_id UUID,
    journal_entry_status SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_je_institution_number UNIQUE (institution_id, entry_number),
    CONSTRAINT uq_je_id_institution UNIQUE (id, institution_id) );

CREATE TABLE IF NOT EXISTS journal_entry_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    journal_entry_id UUID NOT NULL,
    account_id INTEGER NOT NULL,
    debit_amount DECIMAL(18, 8) DEFAULT 0.00 CHECK (debit_amount >= 0),
    credit_amount DECIMAL(18, 8) DEFAULT 0.00 CHECK (credit_amount >= 0),
    currency SMALLINT NOT NULL,
    line_description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_jel_entry FOREIGN KEY (journal_entry_id, institution_id)
        REFERENCES journal_entries (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_jel_account FOREIGN KEY (account_id, institution_id, currency)
        REFERENCES chart_of_accounts (id, institution_id, currency) ON DELETE RESTRICT,
    CONSTRAINT chk_debit_credit_mutually_exclusive CHECK (
        (debit_amount > 0 AND credit_amount = 0) OR (credit_amount > 0 AND debit_amount = 0) ) );

-- Kullanicinin ulke bazli belgeleri: vatandaslik/kimlik ve oturma izinleri
CREATE TABLE IF NOT EXISTS user_country_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    country_code SMALLINT NOT NULL,                 -- belgenin geçerli olduğu ülke
    document_type SMALLINT NOT NULL DEFAULT 0,      -- pasaport, kimlik, oturma izni vb.
    document_number VARCHAR(100),
    media_asset_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    valid_from DATE,
    valid_until DATE,                               -- oturma izninde dolu, vatandaşlık belgesinde NULL olabilir
    verification_status SMALLINT NOT NULL DEFAULT 0,
    reviewed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,   -- operasyon şirketi çalışanı
    reviewed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ucd_dates CHECK (valid_until IS NULL OR valid_from IS NULL OR valid_until >= valid_from) );
CREATE INDEX IF NOT EXISTS idx_ucd_user ON user_country_documents(user_id, country_code, verification_status);
CREATE INDEX IF NOT EXISTS idx_ucd_expiry ON user_country_documents(valid_until) WHERE valid_until IS NOT NULL;

-- Kullanici Calisan ve Kurum cuzdanlarini tutar 
CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_type SMALLINT NOT NULL,
    user_id INTEGER REFERENCES users(id),
    institution_id INTEGER REFERENCES institutions(id),
    wallet_number VARCHAR(100) UNIQUE NOT NULL,
    currency SMALLINT NOT NULL DEFAULT 0,
    balance DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    wallet_status SMALLINT NOT NULL DEFAULT 0, 
    eligibility_document_id UUID REFERENCES user_country_documents(id) ON DELETE RESTRICT,
    closure_reason SMALLINT,
    closure_scheduled_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_wallet_id_currency UNIQUE (id, wallet_type, currency),
    CONSTRAINT chk_wallet_owner CHECK (
        (wallet_type IN (0,2) AND user_id IS NOT NULL AND institution_id IS NULL) OR
        (wallet_type = 1 AND institution_id IS NOT NULL AND user_id IS NULL) ),
    CONSTRAINT chk_wallet_eligibility_user_only CHECK (eligibility_document_id IS NULL OR wallet_type = 0),
    CONSTRAINT chk_wallet_closed_empty CHECK (wallet_status <> 2 OR (balance = 0 AND closed_at IS NOT NULL)) );
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_user_currency
   ON wallets (user_id, wallet_type, currency) WHERE user_id IS NOT NULL AND wallet_status <> 2;
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_institution_currency
   ON wallets (institution_id, currency) WHERE institution_id IS NOT NULL AND wallet_status <> 2;

-- Finansal islem kaydinini tutar
CREATE TABLE IF NOT EXISTS transactions (
    id UUID DEFAULT gen_random_uuid(),
    trace_id UUID NOT NULL DEFAULT gen_random_uuid(), -- İşlem izleme/korelasyon ID'si (Idempotency için)
    sender_wallet_id UUID REFERENCES wallets(id) ON DELETE RESTRICT,   -- NULL ise Dış Nakit/Kupon Yükleme işlemidir
    sender_wallet_type SMALLINT NOT NULL,
    receiver_wallet_id UUID REFERENCES wallets(id) ON DELETE RESTRICT, -- NULL ise Dışarıya Para Çıkış/Sistem İptal işlemidir
    receiver_wallet_type SMALLINT NOT NULL,
    initiated_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    amount NUMERIC(18, 8) NOT NULL CHECK (amount > 0),
    fee_amount NUMERIC(18, 8) NOT NULL DEFAULT 0.0000 CHECK (fee_amount >= 0),
    currency SMALLINT NOT NULL DEFAULT 0,
    tx_type SMALLINT NOT NULL, 
    transaction_status SMALLINT NOT NULL DEFAULT 0, 
    transaction_metadata JSONB, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_transactions PRIMARY KEY (id, created_at),
    CONSTRAINT uk_transactions_trace_id UNIQUE (trace_id, created_at),
    CONSTRAINT uk_transactions_currency UNIQUE (id, created_at, currency),
    CONSTRAINT chk_transaction_nonnulls CHECK (num_nonnulls(sender_wallet_id, receiver_wallet_id) >= 1),
    CONSTRAINT chk_tx_different_wallets CHECK (sender_wallet_id IS DISTINCT FROM receiver_wallet_id),
    CONSTRAINT fk_sender_wallet_id_currency FOREIGN KEY (sender_wallet_id, sender_wallet_type, currency) REFERENCES wallets (id, wallet_type, currency),
    CONSTRAINT fk_receiver_wallet_id_currency FOREIGN KEY (receiver_wallet_id, receiver_wallet_type, currency) REFERENCES wallets (id, wallet_type, currency)
     ) PARTITION BY RANGE (created_at);
CREATE TABLE IF NOT EXISTS transactions_default PARTITION OF transactions DEFAULT;
CREATE TABLE IF NOT EXISTS transactions_2026 PARTITION OF transactions 
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
CREATE TABLE IF NOT EXISTS transactions_2026 PARTITION OF transactions 
    FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');
CREATE INDEX IF NOT EXISTS idx_tx_sender ON transactions(sender_wallet_id, created_at);
CREATE INDEX IF NOT EXISTS idx_tx_receiver ON transactions(receiver_wallet_id, created_at);
CREATE INDEX IF NOT EXISTS idx_tx_user ON transactions(initiated_by_user_id, created_at);

-- Hakemlik kurallari turunu tutar
CREATE TABLE IF NOT EXISTS jurisdiction_rule_types (
    rule_code SMALLINT PRIMARY KEY,    -- 'EMPLOYMENT_NOTICE', 'EMPLOYMENT_SEVERANCE', 'LEAVE_PAYOUT', 'PARTNER_EXIT_ENTITLEMENT', 'DISPUTE_PROCESS'
    rule_domain SMALLINT NOT NULL,        -- 0=ÇALIŞAN AYRILIŞI, 1=ORTAK AYRILIŞI, 2=UYUŞMAZLIK/HAKEMLİK
    description TEXT,
    parameter_schema JSONB NOT NULL  );   -- parameters alanının JSON Schema'sı

-- Hakemlik rollerini ulke bazli tutar
CREATE TABLE IF NOT EXISTS jurisdiction_rules (
    id SERIAL PRIMARY KEY,
    country_code SMALLINT NOT NULL,     
    state_or_region SMALLINT,
    rule_code SMALLINT NOT NULL REFERENCES jurisdiction_rule_types(rule_code),
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
    board_member BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    exited_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_is_id_institution_user UNIQUE (id,institution_id,user_id),
    CONSTRAINT chk_shareholder_active_share CHECK ((is_active AND share_percentage > 0 AND exited_at IS NULL) OR
        (NOT is_active AND share_percentage = 0 AND exited_at IS NOT NULL)) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_institution_shareholder_active
    ON institution_shareholders(institution_id, user_id) WHERE is_active;
CREATE INDEX IF NOT EXISTS idx_inst_shareholders ON institution_shareholders(institution_id);

-- Sirketlerin performans bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_sla_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id),
    metric_type SMALLINT NOT NULL,                -- 'DELIVERY_LATENCY', 'UPTIME_PERCENTAGE', 'RESPONSE_TIME'
    target_value NUMERIC(12, 4) NOT NULL,            -- e.g., Target 30 mins
    actual_value NUMERIC(12, 4) NOT NULL,            -- e.g., Actual 55 mins
    unit_of_measure SMALLINT NOT NULL,            -- 'MINUTES', 'PERCENTAGE', 'HOURS'
    is_violated BOOLEAN NOT NULL DEFAULT FALSE,
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
    manager_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    requested_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    institution_branch_address TEXT,
    is_headquarters BOOLEAN NOT NULL DEFAULT false,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    address_proof_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    local_tax_number VARCHAR(50), -- yabancı şubenin bulunduğu ülkedeki mükellef numarası
    local_tax_office VARCHAR(100),
    local_registration_number VARCHAR(50),
    local_registration_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    verified_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_branch_id_institution UNIQUE (id, institution_id),
    CONSTRAINT unq_institution_branch_code UNIQUE (institution_id, branch_code),
    CONSTRAINT uq_branch_local_tax UNIQUE (country_code, local_tax_number) );
CREATE INDEX IF NOT EXISTS idx_branches_institution ON institution_branches(institution_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_branches_one_hq ON institution_branches(institution_id) WHERE is_headquarters;

--  Calisanlarin sirketlerdeki pozisyonlarini tutar 
CREATE TABLE IF NOT EXISTS worker_institution_positions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    branch_id UUID,                                  -- NULL = merkezde çalışır; dolu ise şubenin ülkesi geçerli
    position_type SMALLINT NOT NULL DEFAULT 0,
    monthly_salary DECIMAL(18, 8) DEFAULT 0.00 CHECK (monthly_salary >= 0),
    commission_rate DECIMAL(5, 4) DEFAULT 0.0000 CHECK (commission_rate >= 0 AND commission_rate <= 1.0000),
    currency SMALLINT NOT NULL DEFAULT 0,
    contract_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,   -- imzalı iş sözleşmesi
    is_active BOOLEAN NOT NULL DEFAULT true,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notice_given_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    termination_type SMALLINT,
    terminated_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    termination_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_wip_id_institution UNIQUE (id, institution_id),
    CONSTRAINT fk_wip_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_wip_termination CHECK ((is_active AND ended_at IS NULL AND termination_type IS NULL) OR
        (NOT is_active AND ended_at IS NOT NULL AND termination_type IS NOT NULL)) );
CREATE INDEX IF NOT EXISTS idx_wip_institution ON worker_institution_positions(institution_id, is_active);
CREATE UNIQUE INDEX IF NOT EXISTS uq_wip_user_institution ON worker_institution_positions
 (user_id, institution_id) WHERE is_active = true;

-- KULLANICI/KURUM DOĞRULAMA VE DENETİM OTURUMLARI (Identity & Compliance Audit Sessions)
CREATE TABLE IF NOT EXISTS identity_verification_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    conducted_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    branch_id UUID REFERENCES institution_branches(id) ON DELETE RESTRICT,
    verification_method SMALLINT NOT NULL, 
    target_verification_tier SMALLINT NOT NULL, -- Hangi seviye hedefleniyor? (Örn: 3=B1, 5=C1)
    scheduled_at TIMESTAMP WITH TIME ZONE, -- Planlanan randevu tarihi
    conducted_at TIMESTAMP WITH TIME ZONE, -- Gerçekleştiği tarih
    recording_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    session_status SMALLINT NOT NULL DEFAULT 0,
    worker_notes TEXT, -- Yetkilinin denetim/doğrulama notları
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ivs_live_call_needs_recording CHECK (
        NOT (verification_method = 1 AND session_status = 1 AND recording_media_id IS NULL) ) );
CREATE INDEX IF NOT EXISTS idx_ivs_target_user ON identity_verification_sessions(target_user_id);
CREATE INDEX IF NOT EXISTS idx_ivs_worker ON identity_verification_sessions(conducted_by_user_id);

CREATE TABLE IF NOT EXISTS user_verification_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    verification_level SMALLINT NOT NULL,       -- enum: A1 e-posta, A2 telefon, B1 yerel evrak, B2 global evrak, C1 gelişmiş
    level_status SMALLINT NOT NULL DEFAULT 0,   -- 0=GEÇERLİ, 1=SÜRESİ DOLDU, 2=İPTAL
    document_id UUID REFERENCES user_country_documents(id) ON DELETE RESTRICT,            -- B1/B2 kanıtı
    session_id UUID REFERENCES identity_verification_sessions(id),     -- C1 kanıtı
    verified_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP WITH TIME ZONE,
    revoked_reason TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_uvl_valid CHECK ((verification_level NOT IN (2, 3) OR document_id IS NOT NULL) 
        AND (verification_level <> 4 OR session_id IS NOT NULL)));
CREATE UNIQUE INDEX IF NOT EXISTS uq_uvl_valid ON user_verification_levels(user_id, verification_level) WHERE level_status = 0;

-- Hangi işlem hangi seviyeyi ister (bir işlem için birden fazla satır = hepsi gerekli)
CREATE TABLE IF NOT EXISTS verification_requirements (
    id SERIAL PRIMARY KEY,
    operation_type SMALLINT NOT NULL,           -- enum: cüzdan açma, şirket kurma, ...
    country_code SMALLINT,                      -- NULL = tüm ülkeler
    required_level SMALLINT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    effective_from DATE NOT NULL,
    effective_until DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_vr_dates CHECK (effective_until IS NULL OR effective_until >= effective_from) );
CREATE INDEX IF NOT EXISTS idx_vr_lookup ON verification_requirements(operation_type, country_code, is_active);


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
    discount_value DECIMAL(18, 8) NOT NULL CHECK (discount_type <> 0 OR discount_value <= 1), -- Yüzde (örn: 0.1500 = %15) veya sabit tutar
    currency SMALLINT DEFAULT 0,
    min_order_amount DECIMAL(18, 8) DEFAULT 0.00 CHECK (min_order_amount >= 0),
    max_discount_amount DECIMAL(18, 8), -- Yüzdeli indirimlerde uygulanacak tavan tutar
    min_user_reputation_score DECIMAL(3, 2) DEFAULT 1.00 CHECK (min_user_reputation_score BETWEEN 1.00 AND 5.00),
    required_user_badge_level SMALLINT, -- Örn: 'VIP_TRAVELER', 'TOP_CUSTOMER' vb.
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
    currency SMALLINT NOT NULL DEFAULT 0,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_redemption_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT uq_prom_id_trn_id_created_at UNIQUE (promotion_id, transaction_id, transaction_created_at));
CREATE INDEX IF NOT EXISTS idx_redemptions_promo ON promotion_redemptions(promotion_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_user ON promotion_redemptions(user_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_inst ON promotion_redemptions(redeemed_institution_id);

-- Sirketlerin kendi aralarindaki konsortiumlari tanimlar
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
    role_title SMALLINT DEFAULT 0, 
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
    unit_type SMALLINT NOT NULL DEFAULT 0,
    b2b_unit_price DECIMAL(18, 8) NOT NULL CHECK (b2b_unit_price >= 0), -- Konsorsiyum içi indirimli birim fiyatı
    currency SMALLINT DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_crp_con_id_pi_id FOREIGN KEY (consortium_id, provider_institution_id)
         REFERENCES consortium_members (consortium_id, institution_id),
    CONSTRAINT uq_crp_id_provider UNIQUE (id, provider_institution_id),
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
    agreement_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_b2b_institutions CHECK (buyer_institution_id <> seller_institution_id),
    CONSTRAINT uq_b2b_id_parties UNIQUE (id, buyer_institution_id, seller_institution_id),
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
    requested_amount DECIMAL(18, 8) NOT NULL CHECK (requested_amount > 0),
    total_b2b_cost DECIMAL(18, 8) NOT NULL CHECK (total_b2b_cost >= 0),
    currency SMALLINT DEFAULT 0,
    transaction_id UUID NOT NULL,
    transaction_created_at TIMESTAMP WITH TIME ZONE NOT NULL, -- B2B ödeme/mahsuplaşma kaydı
    consortium_resource_usage_status SMALLINT NOT NULL DEFAULT 0, -- 0=PENDING, 1=APPROVED, 2=REJECTED
    used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_cru_pool_agreement_nonnull CHECK (num_nonnulls(pool_id, agreement_id) >= 1),
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
    CONSTRAINT uq_igta_id_institution UNIQUE (id, institution_id),
    CONSTRAINT uq_igta_id_currency UNIQUE (id, currency),
    CONSTRAINT chk_balance_logic CHECK (accrued_balance = (total_accrued_lifetime - total_remitted_lifetime)),
    CONSTRAINT fk_itga_inst_chart_currency FOREIGN KEY (chart_account_id,institution_id, currency) 
        REFERENCES chart_of_accounts (id, institution_id, currency) ON DELETE RESTRICT, 
    CONSTRAINT unq_institution_tax_authority_currency UNIQUE (institution_id, government_tax_authority_id, currency) );
CREATE INDEX IF NOT EXISTS idx_igta_institution ON institution_government_tax_accounts(institution_id);
CREATE INDEX IF NOT EXISTS idx_igta_authority ON institution_government_tax_accounts(government_tax_authority_id);
COMMENT ON TABLE institution_government_tax_accounts IS 'Kurumun, kendi ülkesindeki devlete karşı tuttuğu vergi tahakkuk/tahsilat hesabı. Gerçek para hareketi değil, muhasebe bakiyesidir.';

-- Vergi donemleri bilgilerini tutar
CREATE TABLE IF NOT EXISTS tax_filing_periods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_government_tax_account_id UUID NOT NULL REFERENCES institution_government_tax_accounts(id) ON DELETE RESTRICT,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    due_date DATE NOT NULL,
    currency SMALLINT NOT NULL,
    total_tax_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (total_tax_amount >= 0),
    filing_status SMALLINT NOT NULL DEFAULT 0,       -- 0=AÇIK, 1=BEYAN EDİLDİ, 2=ÖDENDİ, 3=GECİKMİŞ
    filed_at TIMESTAMP WITH TIME ZONE,
    filing_reference VARCHAR(100),
    filing_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,   -- beyanname belgesi
    filed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_inst_gov_tax_account UNIQUE (id, institution_government_tax_account_id),
    CONSTRAINT fk_igta_currency FOREIGN KEY (institution_government_tax_account_id, currency) 
        REFERENCES institution_government_tax_accounts (id, currency) ON DELETE RESTRICT,
    CONSTRAINT chk_tfp_dates CHECK (period_end >= period_start AND due_date >= period_end),
    CONSTRAINT unq_tfp_period UNIQUE (institution_government_tax_account_id, period_start, period_end) );

-- Vergi hesaplarini tutar
CREATE TABLE IF NOT EXISTS tax_accruals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_government_tax_account_id UUID NOT NULL REFERENCES institution_government_tax_accounts(id) ON DELETE RESTRICT,
    tax_rate_rule_id INTEGER REFERENCES tax_rates_and_rules(id) ON DELETE RESTRICT,
    tax_filing_period_id UUID REFERENCES tax_filing_periods(id) ON DELETE RESTRICT,
    branch_id UUID REFERENCES institution_branches(id) ON DELETE RESTRICT,
    accrual_kind SMALLINT NOT NULL DEFAULT 0,        -- 0=TAHAKKUK, 1=İPTAL/DÜZELTME (ters kayıt), 2=CEZA/GECİKME FAİZİ
    reversal_of_accrual_id UUID REFERENCES tax_accruals(id) ON DELETE RESTRICT,
    transaction_id UUID NOT NULL,
    transaction_created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    base_amount DECIMAL(18, 8) NOT NULL CHECK (base_amount >= 0),
    tax_amount DECIMAL(18, 8) NOT NULL CHECK (tax_amount >= 0),
    currency SMALLINT NOT NULL,
    journal_entry_id UUID REFERENCES journal_entries(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_igta_currency FOREIGN KEY (institution_government_tax_account_id, currency) 
        REFERENCES institution_government_tax_accounts (id, currency) ON DELETE RESTRICT,
    CONSTRAINT fk_tax_accrual_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_ta_reversal CHECK ((accrual_kind = 1) = (reversal_of_accrual_id IS NOT NULL)) );
CREATE INDEX IF NOT EXISTS idx_tax_accruals_account ON tax_accruals(institution_government_tax_account_id);
CREATE INDEX IF NOT EXISTS idx_tax_accruals_transaction ON tax_accruals(transaction_id);
CREATE INDEX IF NOT EXISTS idx_tax_accruals_period ON tax_accruals(tax_filing_period_id);

-- Kurumların hak kazanabileceği imtiyaz ve prestij eşiklerini tutar
CREATE TABLE IF NOT EXISTS institution_privilege_tiers (
    id SERIAL PRIMARY KEY,
    category_code SMALLINT,                      -- NULL = app geneli, 1 = Mobilya, 2 = Gıda vb.
    tier_code SMALLINT NOT NULL,              -- 'FEATURED_ELIGIBLE', 'PRIORITY_SUPPORT', 'RELAXED_REVIEW_WINDOW' vb.
    basis SMALLINT NOT NULL DEFAULT 0,           -- Hangi kritere dayanıyor? (Puan, işlem hacmi, uyum skoru vb.)
    min_threshold DECIMAL(18, 2) NOT NULL,        -- Örn. 4.70 (average_score) ya da 90.00 (compliance_score)
    min_rating_count INTEGER NOT NULL DEFAULT 0 CHECK (min_rating_count >= 0), -- İstatistiksel anlamlılık için taban
    effect_json JSONB NOT NULL DEFAULT '{}'::jsonb,  -- Örn. {"featured_boost": true, "commission_discount_bps": 50}
    description TEXT NOT NULL,                   -- ZORUNLU: Gerekçe her zaman herkese açık okunabilir olmalı
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_privilege_tier UNIQUE NULLS NOT DISTINCT (category_code, tier_code) );
CREATE INDEX IF NOT EXISTS idx_privilege_tiers_lookup ON institution_privilege_tiers(category_code, is_active);
--CREATE UNIQUE INDEX IF NOT EXISTS idx_unq_privilege_tier_coalesce 
--ON institution_privilege_tiers (COALESCE(category_code, -1), tier_code);

-- Kurumların tanımlı eşik bazında kazandığı hak ve skorların geçmişini tutar
CREATE TABLE IF NOT EXISTS institution_privilege_grants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    tier_id INTEGER NOT NULL REFERENCES institution_privilege_tiers(id) ON DELETE RESTRICT,
    achieved_score DECIMAL(18, 2) NOT NULL,       -- Grant anındaki gerçek skor (kanıt)
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
    approval_id UUID REFERENCES approvals(id) ON DELETE RESTRICT,
    institution_name VARCHAR(150) NOT NULL,
    tax_number VARCHAR(50) NOT NULL,
    tax_office VARCHAR(100),
    country_code SMALLINT NOT NULL,
    registration_number VARCHAR(50),
    legal_form SMALLINT NOT NULL DEFAULT 0,
    board_approval_threshold DECIMAL(5,4) NOT NULL DEFAULT 0.5000
        CHECK (board_approval_threshold > 0 AND board_approval_threshold <= 1.0000),
    office_address TEXT NOT NULL,
    office_latitude DECIMAL(9, 6),
    office_longitude DECIMAL(9, 6),
    incorporation_contract_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    trade_registry_gazette_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    institution_formation_application_status SMALLINT NOT NULL DEFAULT 0,
    reviewed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    rejection_reason TEXT,
    created_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_ifa_rejection_reason CHECK (institution_formation_application_status <> 2 OR rejection_reason IS NOT NULL) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_ifa_pending_tax_number
    ON institution_formation_applications (country_code,tax_number) WHERE institution_formation_application_status = 0;
CREATE INDEX IF NOT EXISTS idx_ifa_applicant ON institution_formation_applications(applicant_user_id);
CREATE INDEX IF NOT EXISTS idx_ifa_pending ON institution_formation_applications(institution_formation_application_status) WHERE institution_formation_application_status = 0;

-- Sirkete sube acma bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_branch_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    applicant_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    approval_id UUID REFERENCES approvals(id) ON DELETE RESTRICT,
    branch_code VARCHAR(30) NOT NULL,
    branch_name VARCHAR(150) NOT NULL,
    country_code SMALLINT NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    local_tax_number VARCHAR(50),                    -- yabancı şubenin bulunduğu ülkedeki mükellef numarası
    local_tax_office VARCHAR(100),
    local_registration_number VARCHAR(50),
    local_registration_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    address_proof_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    institution_branch_application_status SMALLINT NOT NULL DEFAULT 0,
    reviewed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    rejection_reason TEXT,
    created_branch_id UUID REFERENCES institution_branches(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_iba_rejection_reason CHECK (institution_branch_application_status <> 2 OR rejection_reason IS NOT NULL) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_iba_pending_branch_code
    ON institution_branch_applications (institution_id, branch_code) WHERE institution_branch_application_status = 0;
CREATE INDEX IF NOT EXISTS idx_iba_institution ON institution_branch_applications(institution_id);
CREATE INDEX IF NOT EXISTS idx_iba_pending ON institution_branch_applications(institution_branch_application_status) WHERE institution_branch_application_status = 0;

-- Sirketlerin elindeki izin ve ruhsat bilgilerini tutar
CREATE TABLE IF NOT EXISTS institution_business_permits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    branch_id UUID,
    country_code SMALLINT NOT NULL,
    permit_type SMALLINT NOT NULL,                   -- faaliyet izni, gıda, sağlık, ticaret sicil vb.
    permit_number VARCHAR(100),
    issuing_authority_name VARCHAR(150) NOT NULL,
    media_asset_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    valid_from DATE,
    valid_until DATE,
    verification_status SMALLINT NOT NULL DEFAULT 0,
    reviewed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_ibp_id_institution UNIQUE (id, institution_id),
    CONSTRAINT fk_ibp_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_ibp_dates CHECK (valid_until IS NULL OR valid_from IS NULL OR valid_until >= valid_from) );
CREATE INDEX IF NOT EXISTS idx_ibp_institution ON institution_business_permits(institution_id, permit_type, verification_status);
CREATE INDEX IF NOT EXISTS idx_ibp_expiry ON institution_business_permits(valid_until) WHERE valid_until IS NOT NULL;

-- Maas odemesi ile ilgili bilgileri tutar
CREATE TABLE IF NOT EXISTS payroll_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    branch_id UUID,                                  -- şube bazlı bordro (özellikle yabancı şube); NULL = merkez
    currency SMALLINT NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    payroll_status SMALLINT NOT NULL DEFAULT 0,      -- 0=TASLAK, 1=ONAYLANDI, 2=ÖDENDİ, 3=İPTAL
    prepared_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    approved_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    approved_at TIMESTAMP WITH TIME ZONE,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_pr_id_institution UNIQUE (id, institution_id),
    CONSTRAINT fk_pr_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_pr_period CHECK (period_end >= period_start),
    CONSTRAINT chk_pr_two_people CHECK (approved_by_user_id IS NULL OR approved_by_user_id <> prepared_by_user_id) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_pr_period
    ON payroll_runs (institution_id, currency, period_start, period_end,
                     (COALESCE(branch_id, '00000000-0000-0000-0000-000000000000'::uuid)))
    WHERE payroll_status <> 3;

-- Odenecek maas bilgilerini tutar
CREATE TABLE IF NOT EXISTS payroll_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    payroll_run_id UUID NOT NULL,
    position_id INTEGER NOT NULL,
    line_type SMALLINT NOT NULL DEFAULT 0,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    tax_rate_rule_id INTEGER REFERENCES tax_rates_and_rules(id) ON DELETE RESTRICT,
    tax_accrual_id UUID REFERENCES tax_accruals(id) ON DELETE RESTRICT,
    transaction_id UUID,                             -- sadece NET ÖDEME satırında
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pl_run FOREIGN KEY (payroll_run_id, institution_id)
        REFERENCES payroll_runs (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_pl_position FOREIGN KEY (position_id, institution_id)
        REFERENCES worker_institution_positions (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_pl_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_pl_tx_pair CHECK ((transaction_id IS NULL) = (transaction_created_at IS NULL)),
    CONSTRAINT chk_pl_tax CHECK (line_type NOT IN (2, 3, 4) OR tax_rate_rule_id IS NOT NULL),
    CONSTRAINT chk_pl_tx_only_net CHECK (transaction_id IS NULL OR line_type = 6) );
CREATE INDEX IF NOT EXISTS idx_pl_run ON payroll_lines(payroll_run_id);
CREATE INDEX IF NOT EXISTS idx_pl_position ON payroll_lines(position_id);

-- Ortaklara kar dagitim kurallarini tutar
CREATE TABLE IF NOT EXISTS profit_distributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    approval_id UUID NOT NULL UNIQUE REFERENCES approvals(id) ON DELETE RESTRICT,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    currency SMALLINT NOT NULL,
    distributable_amount DECIMAL(18, 8) NOT NULL CHECK (distributable_amount > 0),
    distribution_status SMALLINT NOT NULL DEFAULT 0, -- 0=ONAY BEKLİYOR, 1=ONAYLANDI, 2=DAĞITILDI, 3=İPTAL
    journal_entry_id UUID,
    created_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT uq_pd_id_institution UNIQUE (id, institution_id),
    CONSTRAINT chk_pd_period CHECK (period_end >= period_start),
    CONSTRAINT fk_pd_journal FOREIGN KEY (journal_entry_id, institution_id)
        REFERENCES journal_entries (id, institution_id) ON DELETE RESTRICT );

-- Kar dagitimi bilgilerini tutar
CREATE TABLE IF NOT EXISTS profit_distribution_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    distribution_id UUID NOT NULL,
    shareholder_id INTEGER NOT NULL REFERENCES institution_shareholders(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    share_percentage_snapshot NUMERIC(9, 8) NOT NULL CHECK (share_percentage_snapshot > 0 AND share_percentage_snapshot <= 1),
    gross_amount DECIMAL(18, 8) NOT NULL CHECK (gross_amount > 0),
    withheld_tax_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (withheld_tax_amount >= 0),
    net_amount DECIMAL(18, 8) NOT NULL CHECK (net_amount > 0),
    tax_rate_rule_id INTEGER REFERENCES tax_rates_and_rules(id) ON DELETE RESTRICT,
    tax_accrual_id UUID REFERENCES tax_accruals(id) ON DELETE RESTRICT,
    transaction_id UUID,
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pdl_distribution FOREIGN KEY (distribution_id, institution_id)
        REFERENCES profit_distributions (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_pdl_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT fk_pdl_institution_shareholder FOREIGN KEY (shareholder_id, institution_id, user_id)
        REFERENCES institution_shareholders (id, institution_id, user_id) ON DELETE RESTRICT,
    CONSTRAINT chk_pdl_tx_pair CHECK ((transaction_id IS NULL) = (transaction_created_at IS NULL)),
    CONSTRAINT chk_pdl_net CHECK (net_amount = gross_amount - withheld_tax_amount),
    CONSTRAINT chk_pdl_tax CHECK (withheld_tax_amount = 0 OR tax_rate_rule_id IS NOT NULL),
    CONSTRAINT unq_pdl_shareholder UNIQUE (distribution_id, shareholder_id) );

CREATE TABLE IF NOT EXISTS real_world_account_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    real_world_account_id INTEGER NOT NULL REFERENCES real_world_accounts(id) ON DELETE RESTRICT,
    direction SMALLINT NOT NULL DEFAULT 0,           -- 0=GİRİŞ, 1=ÇIKIŞ
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    currency SMALLINT NOT NULL,
    bank_reference VARCHAR(100) NOT NULL,
    value_date DATE NOT NULL,
    counterparty_name VARCHAR(150),
    counterparty_account VARCHAR(64),
    bank_description TEXT,
    movement_status SMALLINT NOT NULL DEFAULT 0,     -- 0=EŞLEŞMEDİ (askıda), 1=EŞLEŞTİ, 2=İADE EDİLDİ, 3=İPTAL
    statement_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    entered_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    journal_entry_id UUID REFERENCES journal_entries(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rwam_currency FOREIGN KEY (real_world_account_id, currency)
         REFERENCES real_world_accounts (id, currency) ON DELETE RESTRICT,
    CONSTRAINT unq_rwam_bank_ref UNIQUE (real_world_account_id, bank_reference) );

-- transactions'tan sonra gelmeli
CREATE TABLE IF NOT EXISTS institution_deposit_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    requested_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    target_real_world_account_id INTEGER NOT NULL REFERENCES real_world_accounts(id) ON DELETE RESTRICT,
    source_real_world_account_id INTEGER NOT NULL,   -- kurumun kendi doğrulanmış hesabı
    reference_code VARCHAR(20) NOT NULL UNIQUE,
    expected_amount DECIMAL(18, 8) NOT NULL CHECK (expected_amount > 0),
    currency SMALLINT NOT NULL,
    receipt_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    declared_sender_name VARCHAR(150),
    declared_bank_reference VARCHAR(100),
    declared_at TIMESTAMP WITH TIME ZONE,
    deposit_request_status SMALLINT NOT NULL DEFAULT 0,   -- 0=TRANSFER BEKLENİYOR, 1=DEKONT YÜKLENDİ, 2=İNCELEMEDE, 3=TAMAMLANDI, 4=REDDEDİLDİ, 5=SÜRESİ DOLDU
    movement_id UUID REFERENCES real_world_account_movements(id) ON DELETE RESTRICT,
    credited_amount DECIMAL(18, 8) CHECK (credited_amount > 0),
    verified_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    approved_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    transaction_id UUID,
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_idr_source FOREIGN KEY (source_real_world_account_id, institution_id)
        REFERENCES real_world_accounts (id, owner_institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_idr_currency FOREIGN KEY (target_real_world_account_id, currency)
         REFERENCES real_world_accounts (id, currency) ON DELETE RESTRICT,
    CONSTRAINT fk_idr_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_idr_mov_cre_amount CHECK (deposit_request_status <> 3
         OR (movement_id IS NOT NULL AND credited_amount IS NOT NULL AND transaction_id IS NOT NULL)),
    CONSTRAINT chk_idr_rej_reason CHECK (deposit_request_status <> 4 OR rejection_reason IS NOT NULL),
    CONSTRAINT chk_idr_tx_pair CHECK ((transaction_id IS NULL) = (transaction_created_at IS NULL)),
    CONSTRAINT chk_idr_two_people CHECK (approved_by_user_id IS NULL OR approved_by_user_id <> verified_by_user_id) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_idr_movement ON institution_deposit_requests(movement_id) WHERE movement_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_idr_institution ON institution_deposit_requests(institution_id, deposit_request_status);

CREATE TABLE IF NOT EXISTS reserve_reconciliations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    real_world_account_id INTEGER NOT NULL REFERENCES real_world_accounts(id) ON DELETE RESTRICT,
    as_of_date DATE NOT NULL,
    bank_reported_balance DECIMAL(18, 8) NOT NULL,
    ledger_balance DECIMAL(18, 8) NOT NULL,
    difference DECIMAL(18, 8) GENERATED ALWAYS AS (bank_reported_balance - ledger_balance) STORED,
    statement_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    reconciliation_status SMALLINT NOT NULL DEFAULT 0,   -- 0=BEKLİYOR, 1=EŞİT, 2=FARK VAR, 3=FARK AÇIKLANDI
    performed_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    approved_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_reconciliation_status CHECK (reconciliation_status <> 1 OR difference = 0),
    CONSTRAINT uq_rr_account_date UNIQUE (real_world_account_id, as_of_date),
    CONSTRAINT chk_rr_two_people CHECK (approved_by_user_id IS NULL OR approved_by_user_id <> performed_by_user_id) );

-- Vergi odeme bilgilerini tutar
CREATE TABLE IF NOT EXISTS government_tax_remittances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    institution_government_tax_account_id UUID NOT NULL,
    tax_filing_period_id UUID REFERENCES tax_filing_periods(id) ON DELETE RESTRICT,
    real_world_account_id INTEGER NOT NULL REFERENCES real_world_accounts(id),          
    movement_id UUID REFERENCES real_world_account_movements(id) ON DELETE RESTRICT,  
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    currency SMALLINT NOT NULL,
    remittance_reference VARCHAR(100),
    remittance_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,   -- dekont
    journal_entry_id UUID,
    issued_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    government_tax_remittance_status SMALLINT NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_gtr_currency FOREIGN KEY (real_world_account_id, currency)
         REFERENCES real_world_accounts (id, currency) ON DELETE RESTRICT,
    CONSTRAINT fk_gtr_inst_gov_tax_filing_period FOREIGN KEY (tax_filing_period_id,institution_government_tax_account_id)
        REFERENCES tax_filing_periods (id, institution_government_tax_account_id) ON DELETE RESTRICT,
    CONSTRAINT fk_gtr_tax_account FOREIGN KEY (institution_government_tax_account_id, institution_id)
        REFERENCES institution_government_tax_accounts (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_gtr_rwa FOREIGN KEY (real_world_account_id, institution_id)
        REFERENCES real_world_accounts (id, owner_institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_gtr_journal FOREIGN KEY (journal_entry_id, institution_id)
        REFERENCES journal_entries (id, institution_id) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_gtr_tax_account ON government_tax_remittances(institution_government_tax_account_id);
CREATE INDEX IF NOT EXISTS idx_gtr_status ON government_tax_remittances(government_tax_remittance_status);

-- Digital kupon uretimi icin gerekli parti bilgileri
CREATE TABLE IF NOT EXISTS voucher_batches (
    id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    issuer_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,   -- finans şirketi
    reserve_real_world_account_id INTEGER NOT NULL REFERENCES real_world_accounts(id) ON DELETE RESTRICT,
    created_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    approved_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    voucher_count INTEGER NOT NULL CHECK (voucher_count > 0),
    total_amount DECIMAL(18, 8) NOT NULL CHECK (total_amount > 0),
    currency SMALLINT NOT NULL,
    journal_entry_id UUID REFERENCES journal_entries(id) ON DELETE RESTRICT,
    batch_status SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_vb_institution_currency UNIQUE (id, issuer_institution_id, currency),
    CONSTRAINT chk_vb_two_people CHECK (approved_by_user_id IS NULL OR approved_by_user_id <> created_by_user_id) );

-- Para girisi icin uretilen digital kuponlar 
CREATE TABLE IF NOT EXISTS vouchers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hash_code VARCHAR(64) UNIQUE NOT NULL,
    batch_id INTEGER NOT NULL REFERENCES voucher_batches(id) ON DELETE RESTRICT,
    issuer_institution_id INTEGER REFERENCES institutions(id),
    created_by_user_id INTEGER REFERENCES users(id),
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    currency SMALLINT NOT NULL,
    is_used BOOLEAN NOT NULL DEFAULT false,
    used_by_user_id INTEGER REFERENCES users(id),
    used_at TIMESTAMP WITH TIME ZONE,
    redeemed_transaction_id UUID,
    redeemed_transaction_created_at TIMESTAMP WITH TIME ZONE,
    is_cancelled BOOLEAN NOT NULL DEFAULT false,
    cancel_reason TEXT,
    expiry_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_voucher_state CHECK (NOT (is_used = true AND is_cancelled = true)),
    CONSTRAINT fk_vouchers_redeem_tx FOREIGN KEY (redeemed_transaction_id, redeemed_transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT fk_v_batch_issure_currency FOREIGN KEY (batch_id, issuer_institution_id, currency)
         REFERENCES voucher_batches (id, issuer_institution_id, currency) ON DELETE RESTRICT,
    CONSTRAINT chk_voucher_used_user CHECK (NOT is_used OR (used_by_user_id IS NOT NULL AND used_at IS NOT NULL)),
    CONSTRAINT chk_voucher_cancelled_reason CHECK (NOT is_cancelled OR cancel_reason IS NOT NULL),
    CONSTRAINT chk_voucher_redeem_pair CHECK ((redeemed_transaction_id IS NULL) = (redeemed_transaction_created_at IS NULL)),
    CONSTRAINT chk_voucher_redeem_tx CHECK (NOT is_used OR redeemed_transaction_id IS NOT NULL) );

-- Sistemin uygulayacagi komisyon sinirlarini tutar
CREATE TABLE IF NOT EXISTS system_commissions (
    id SERIAL PRIMARY KEY,
    currency SMALLINT NOT NULL,
    user_type SMALLINT NOT NULL DEFAULT 0,
    tx_type SMALLINT NOT NULL DEFAULT 0,
    base_rate DECIMAL(5, 4) DEFAULT 0.002 CHECK (base_rate BETWEEN 0 AND 1),
    promo_rate DECIMAL(5, 4) CHECK (promo_rate BETWEEN 0 AND 1),
    promo_expiry TIMESTAMP WITH TIME ZONE,
    updated_by_user_id INTEGER REFERENCES users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_sc_promo_rate_expiry CHECK ((promo_rate IS NULL) = (promo_expiry IS NULL)),
    CONSTRAINT unique_app_rate_per_type UNIQUE (currency, user_type, tx_type) );

-- Cüzdanlarda anlık ön bloke (Hold / Rezervasyon) tutarını tutar
CREATE TABLE IF NOT EXISTS wallet_holds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    initiated_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    amount DECIMAL(18,8) NOT NULL CHECK (amount > 0),
    currency SMALLINT NOT NULL DEFAULT 0, 
    purpose SMALLINT NOT NULL, 
    reference_type SMALLINT NOT NULL, -- İlgili tablo adı (Örn: 'orders', 'auctions')
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
    system_commission_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (system_commission_amount >= 0),
    net_payee_amount DECIMAL(18, 8) NOT NULL CHECK (net_payee_amount >= 0),
    currency SMALLINT NOT NULL DEFAULT 0, -- Transactions tablosuyla uyumlu para birimi
    escrow_status SMALLINT NOT NULL DEFAULT 0,
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
CREATE TABLE IF NOT EXISTS escrow_records_2026 PARTITION OF escrow_records 
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
CREATE TABLE IF NOT EXISTS escrow_records_2026 PARTITION OF escrow_records 
    FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');
CREATE INDEX IF NOT EXISTS idx_escrow_payer ON escrow_records(payer_wallet_id);
CREATE INDEX IF NOT EXISTS idx_escrow_payee ON escrow_records(payee_wallet_id);
CREATE INDEX IF NOT EXISTS idx_escrow_status ON escrow_records(escrow_status);
CREATE INDEX IF NOT EXISTS idx_escrow_metadata_gin ON escrow_records USING gin (metadata);
COMMENT ON TABLE escrow_records IS
 'Güvenli ticaret ve veresiye işlemleri için fonların blokede tutulduğu emanet (Escrow) defteri.';

-- Sirket calisanlari ve yoneticileri icin yetki sinirlarini tutar
CREATE TABLE IF NOT EXISTS worker_permission_catalog (
    id SERIAL PRIMARY KEY,
    permission_key SMALLINT UNIQUE NOT NULL,          -- 'VIEW_FULL_LEDGER','VERIFY_CUSTOMER_QR' vb.
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
    granted_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP WITH TIME ZONE,
    revoked_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT chk_wpp_active_revoke CHECK (is_active = (revoked_at IS NULL)),
    CONSTRAINT unq_position_permission UNIQUE (position_id, permission_id) );
CREATE INDEX IF NOT EXISTS idx_wpp_position_active ON worker_position_permissions(position_id) WHERE is_active = true;


-- KULLANICI VERİ MAHREMİYETİ VE ANONİMLEŞTİRME TALEPLERİ (GDPR / KVKK)
CREATE TABLE IF NOT EXISTS gdpr_anonymization_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    request_type SMALLINT NOT NULL DEFAULT 0, 
    reason TEXT, -- Talep gerekçesi
    request_status SMALLINT NOT NULL DEFAULT 0, 
    approval_id UUID REFERENCES approvals(id) ON DELETE RESTRICT, 
    processed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT, 
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
    feature_key SMALLINT UNIQUE NOT NULL,-- e.g., 'WITHDRAWAL_ENABLED', 'B2B_EXCHANGE_ACTIVE'
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    rules_json JSONB DEFAULT '{}'::jsonb,           -- Granular controls (e.g., {"max_tx_limit": 5000})
    description TEXT,
    updated_by_user_id INTEGER REFERENCES users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_feature_flags_key ON system_feature_flags (feature_key);
COMMENT ON TABLE system_feature_flags IS
 'Dynamic kill-switches and operational feature toggles for high availability.';

CREATE TABLE IF NOT EXISTS exchange_rate_sources (
    id SERIAL PRIMARY KEY,
    country_code SMALLINT NOT NULL,               -- kuru belirleyen bankanın ülkesi
    source_type SMALLINT NOT NULL DEFAULT 0,      -- merkez bankası, ticari banka, piyasa sağlayıcı
    source_name VARCHAR(150) NOT NULL,
    partner_bank_id INTEGER REFERENCES partner_banks(id) ON DELETE RESTRICT,   -- anlaşmalı bankaysa
    priority SMALLINT NOT NULL DEFAULT 0,         -- yedek kaynak sırası
    max_rate_age_seconds INTEGER NOT NULL CHECK (max_rate_age_seconds > 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_ers_country ON exchange_rate_sources(country_code, is_active, priority);

-- Doviz ceviri arbitraj bilgilerini tutar
CREATE TABLE IF NOT EXISTS currency_exchange_rates (
    id BIGSERIAL PRIMARY KEY,
    source_id INTEGER NOT NULL REFERENCES exchange_rate_sources(id) ON DELETE RESTRICT,
    base_currency SMALLINT NOT NULL,
    target_currency SMALLINT NOT NULL,
    buy_rate NUMERIC(18, 8) NOT NULL CHECK (buy_rate > 0),     -- bankanın alış kuru
    sell_rate NUMERIC(18, 8) NOT NULL CHECK (sell_rate > 0),   -- bankanın satış kuru
    metadata JSONB DEFAULT '{}'::jsonb,
    fetched_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_cer_pair CHECK (base_currency <> target_currency),
    CONSTRAINT chk_cer_spread CHECK (sell_rate >= buy_rate),
    CONSTRAINT unq_currency_pair_time UNIQUE (source_id, base_currency, target_currency, fetched_at) );
CREATE INDEX IF NOT EXISTS idx_exchange_rates_lookup
    ON currency_exchange_rates (base_currency, target_currency, fetched_at DESC);

-- Cuzdanlar arasi kur donusumu: teklif + gerceklesen islem
CREATE TABLE IF NOT EXISTS currency_conversions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    from_wallet_type SMALLINT NOT NULL,
    to_wallet_type SMALLINT NOT NULL,
    from_wallet_id UUID NOT NULL,
    to_wallet_id UUID NOT NULL,
    from_currency SMALLINT NOT NULL,
    to_currency SMALLINT NOT NULL,
    from_amount DECIMAL(18, 8) NOT NULL CHECK (from_amount > 0),
    to_amount DECIMAL(18, 8) NOT NULL CHECK (to_amount > 0),
    applied_rate NUMERIC(18, 8) NOT NULL CHECK (applied_rate > 0),
    rate_id BIGINT NOT NULL REFERENCES currency_exchange_rates(id) ON DELETE RESTRICT,
    cross_rate_id BIGINT REFERENCES currency_exchange_rates(id) ON DELETE RESTRICT,   -- çapraz kurda ikinci bacak (örn. USD üzerinden)
    fee_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (fee_amount >= 0),
    conversion_reason SMALLINT NOT NULL DEFAULT 0,   -- 0=KULLANICI TALEBİ, 1=CÜZDAN KAPANIŞI
    conversion_status SMALLINT NOT NULL DEFAULT 0,   -- 0=TEKLİF, 1=TAMAMLANDI, 2=SÜRESİ DOLDU, 3=İPTAL
    quote_expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    debit_transaction_id UUID,
    debit_transaction_created_at TIMESTAMP WITH TIME ZONE,
    credit_transaction_id UUID,
    credit_transaction_created_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_cc_from_wallet FOREIGN KEY (from_wallet_id, from_wallet_type, from_currency)
        REFERENCES wallets (id, wallet_type, currency) ON DELETE RESTRICT,
    CONSTRAINT fk_cc_to_wallet FOREIGN KEY (to_wallet_id, to_wallet_type, to_currency)
        REFERENCES wallets (id, wallet_type, currency) ON DELETE RESTRICT,
    CONSTRAINT fk_cc_debit_tx FOREIGN KEY (debit_transaction_id, debit_transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT fk_cc_credit_tx FOREIGN KEY (credit_transaction_id, credit_transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_cc_currencies CHECK (from_currency <> to_currency),
    CONSTRAINT chk_cc_debit_pair CHECK ((debit_transaction_id IS NULL) = (debit_transaction_created_at IS NULL)),
    CONSTRAINT chk_cc_credit_pair CHECK ((credit_transaction_id IS NULL) = (credit_transaction_created_at IS NULL)),
    CONSTRAINT chk_cc_completed CHECK (conversion_status <> 1 OR (debit_transaction_id IS NOT NULL AND credit_transaction_id IS NOT NULL)) );
CREATE INDEX IF NOT EXISTS idx_cc_user ON currency_conversions(user_id, created_at DESC);

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
    CONSTRAINT chk_cr_type_value CHECK (commission_type <> 0 OR commission_value <= 1),
    CONSTRAINT chk_cr_type_currency CHECK (commission_type <> 1 OR currency IS NOT NULL),
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
    charged_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount >= 0),
    currency SMALLINT NOT NULL,
    system_wallet_id UUID REFERENCES wallets(id) ON DELETE RESTRICT,  -- hangi komisyon havuzuna gitti
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_commission_charged_ref CHECK (
    (charged_actor_type IN (0,1) AND charged_user_id IS NOT NULL AND charged_institution_id IS NULL) OR
    (charged_actor_type = 2      AND charged_institution_id IS NOT NULL AND charged_user_id IS NULL) ),
    CONSTRAINT fk_txcommission_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_txcommission_transaction ON transaction_commissions(transaction_id);

-- Sistemin Sirketler icin kural setini tutar
CREATE TABLE IF NOT EXISTS institution_operating_rules (
    id SERIAL PRIMARY KEY,   
    category_code SMALLINT,                                -- NULL = app geneli
    rule_key SMALLINT NOT NULL,                        -- 'REQUIRES_LICENSE', 'MAX_REFUND_WINDOW_DAYS', 'MIN_STOCK_ALERT'
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
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_icc_inst_branch FOREIGN KEY (branch_id, institution_id)
         REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT );
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
    approved_amount NUMERIC(18, 8) NOT NULL DEFAULT 0.00 CHECK (approved_amount >= 0),
    currency SMALLINT NOT NULL,
    reason_code SMALLINT NOT NULL, -- 'DEFECTIVE_SERVICE', 'NON_DELIVERY', 'FRAUD_SUSPECT'
    reason_description TEXT,
    transaction_dispute_and_refund_status SMALLINT NOT NULL DEFAULT 0,
    evidence_media_ids UUID[] DEFAULT '{}', -- Kanıt dosyaları / medya referansları
    resolved_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT, 
    resolution_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_approved_lte_claimed CHECK (approved_amount <= claimed_amount),
    CONSTRAINT chk_tdar_status CHECK (transaction_dispute_and_refund_status NOT IN (2,3)
         OR (resolved_at IS NOT NULL AND resolved_by_user_id IS NOT NULL)),
    CONSTRAINT fk_dispute_transaction FOREIGN KEY (transaction_id, transaction_created_at, currency)
        REFERENCES transactions (id, created_at, currency) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_disputes_transaction ON transaction_disputes_and_refunds (transaction_id);
CREATE INDEX IF NOT EXISTS idx_disputes_user ON transaction_disputes_and_refunds (requested_by_user_id);
CREATE INDEX IF NOT EXISTS idx_disputes_status ON transaction_disputes_and_refunds (transaction_dispute_and_refund_status);
COMMENT ON TABLE transaction_disputes_and_refunds IS
 'Müşteri ve esnaf arasındaki ödeme itirazları, iade talepleri ve emanet çözüve bağlama defteri.';

-- Sistem icerisindeki tum sikayet bilgilerini tutar
CREATE TABLE IF NOT EXISTS complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_root_id INT NOT NULL REFERENCES users(id),
    target_root_id INTEGER REFERENCES users(id),
    escalated_to_system BOOLEAN DEFAULT false,
    escalated_at TIMESTAMP WITH TIME ZONE,
    evidence_media_ids UUID[],
    reporter_role SMALLINT NOT NULL,
    target_role SMALLINT NOT NULL,
    reason_category SMALLINT NOT NULL,
    description TEXT NOT NULL,
    complaint_status SMALLINT NOT NULL DEFAULT 0,
    ai_analysis JSONB,
    admin_note TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_complaints_ai_analysis_gin ON complaints USING gin (ai_analysis);

-- Sistem icerisindeki tum bildirim bilgilerini tutar
CREATE TABLE IF NOT EXISTS notification_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_type SMALLINT NOT NULL,
    sender_worker_id INTEGER REFERENCES users(id),
    target_scope SMALLINT NOT NULL,
    target_institution_id INTEGER REFERENCES institutions(id),
    target_user_ids INTEGER[],
    target_age_min SMALLINT,
    target_age_max SMALLINT,
    target_nationality_codes SMALLINT[],
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
    is_read BOOLEAN NOT NULL DEFAULT false,
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
    evaluator_worker_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    target_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    target_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    target_worker_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
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

CREATE TABLE IF NOT EXISTS institution_closure_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    approval_id UUID UNIQUE REFERENCES approvals(id) ON DELETE RESTRICT,   -- ortak oylaması; otomatik/zorunlu yolda NULL olabilir
    closure_path SMALLINT NOT NULL DEFAULT 0,     -- 0=ORTAKLAR KARARI, 1=OTOMATİK (SON ORTAK AYRILDI), 2=PLATFORM ZORUNLU KAPATMA
    initiated_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    reason TEXT NOT NULL,
    institution_closure_application_status SMALLINT NOT NULL DEFAULT 0,   -- enum_institution_closure_status
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_ica_path CHECK (closure_path IN (0, 1, 2)),
    CONSTRAINT chk_ica_initiator_matches_path CHECK (
        (closure_path = 0 AND initiated_by_user_id IS NOT NULL AND approval_id IS NOT NULL) OR
        (closure_path = 1 AND initiated_by_user_id IS NULL AND approval_id IS NULL) OR
        (closure_path = 2 AND initiated_by_user_id IS NOT NULL) ) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_institution_closure_open
    ON institution_closure_applications (institution_id) WHERE institution_closure_application_status IN (0, 1);
CREATE INDEX IF NOT EXISTS idx_institution_closure_institution ON institution_closure_applications(institution_id);

-- Kapatmada ortaklara yapilan dagitim kayitlari (nakit veya ayni varlik)
CREATE TABLE IF NOT EXISTS institution_closure_distribution_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    application_id UUID NOT NULL REFERENCES institution_closure_applications(id) ON DELETE RESTRICT,
    shareholder_id INTEGER REFERENCES institution_shareholders(id) ON DELETE RESTRICT,   -- NULL ise unclaimed
    user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    distribution_type SMALLINT NOT NULL DEFAULT 0,   -- 0=NAKİT, 1=AYNİ VARLIK
    currency SMALLINT NOT NULL,
    distributed_amount DECIMAL(18, 8) NOT NULL CHECK (distributed_amount > 0),
    equity_percentage_at_closure NUMERIC(9, 8),
    fixed_asset_id UUID REFERENCES fixed_assets(id) ON DELETE RESTRICT,
    valuation_id UUID REFERENCES fixed_asset_valuations(id) ON DELETE RESTRICT,
    transaction_id UUID,
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    is_unclaimed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_icdl_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_icdl_tx_pair CHECK ((transaction_id IS NULL) = (transaction_created_at IS NULL)),
    CONSTRAINT chk_icdl_asset CHECK (distribution_type = 0 OR (fixed_asset_id IS NOT NULL AND valuation_id IS NOT NULL)),
    CONSTRAINT chk_icdl_recipient CHECK (is_unclaimed OR (shareholder_id IS NOT NULL AND user_id IS NOT NULL)) );
CREATE INDEX IF NOT EXISTS idx_closure_dist_institution ON institution_closure_distribution_log(institution_id);
CREATE INDEX IF NOT EXISTS idx_closure_dist_unclaimed ON institution_closure_distribution_log(is_unclaimed) WHERE is_unclaimed = true;

CREATE TABLE IF NOT EXISTS institution_branch_closure_details (
    approval_id UUID PRIMARY KEY REFERENCES approvals(id) ON DELETE RESTRICT,
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    branch_id UUID NOT NULL,
    reason TEXT NOT NULL,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    closed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_ibcd_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT );
CREATE UNIQUE INDEX IF NOT EXISTS uq_branch_closure_open ON institution_branch_closure_details(branch_id) WHERE is_open;
CREATE INDEX IF NOT EXISTS idx_ibcd_institution ON institution_branch_closure_details(institution_id);

CREATE TABLE IF NOT EXISTS financial_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(id),
    request_type SMALLINT NOT NULL,
    request_details JSONB NOT NULL,
    financial_request_status SMALLINT NOT NULL DEFAULT 0,
    processed_by_user_id INTEGER REFERENCES users(id),
    reviewer_comment TEXT,
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );

--Para cikisi icin uretilecek dogrulama kodu ve islemler (ajan kurumdan nakit teslim)
CREATE TABLE IF NOT EXISTS withdrawal_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    wallet_id UUID NOT NULL,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    fee_deducted DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (fee_deducted >= 0),
    wallet_type SMALLINT NOT NULL,
    currency SMALLINT NOT NULL,
    verification_code_hash VARCHAR(64), 
    failed_attempts SMALLINT NOT NULL DEFAULT 0,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    withdrawal_status SMALLINT NOT NULL DEFAULT 0,  
    assigned_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    assigned_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    qr_data TEXT,
    wallet_hold_id UUID REFERENCES wallet_holds(id) ON DELETE RESTRICT,   -- tutarın bloke edildiği kayıt
    transaction_id UUID,                                                  -- kullanıcı → ajan kurum cüzdan hareketi
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    verified_at TIMESTAMP WITH TIME ZONE,
    paid_declared_at TIMESTAMP WITH TIME ZONE,      -- ajanın "nakit verdim" beyanı
    user_confirmed_at TIMESTAMP WITH TIME ZONE,     -- kullanıcının "aldım" onayı
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL '15 minutes'),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_wr_wallet FOREIGN KEY (wallet_id, wallet_type, currency) REFERENCES wallets (id, wallet_type, currency) ON DELETE RESTRICT,
    CONSTRAINT fk_wr_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_wr_tx_pair CHECK ((transaction_id IS NULL) = (transaction_created_at IS NULL)),
    CONSTRAINT chk_wr_fee CHECK (fee_deducted < amount),
    CONSTRAINT chk_wr_agent CHECK (assigned_user_id IS NULL OR assigned_institution_id IS NOT NULL) );
CREATE INDEX IF NOT EXISTS idx_wr_user ON withdrawal_requests(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wr_agent ON withdrawal_requests(assigned_institution_id, withdrawal_status);
-- Aynı cüzdan için aynı anda tek açık talep (blokaj sömürüsünü önler)
CREATE UNIQUE INDEX IF NOT EXISTS uq_wr_open_per_wallet
    ON withdrawal_requests(user_id, wallet_id) WHERE withdrawal_status IN (0, 1, 2, 6);

-- Cikis fisi makbuzlarini tutar: ajan kurumun kendi defterine yazdigi nakit cikis belgesi
CREATE TABLE IF NOT EXISTS cash_outflow_slips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,   -- nakdi ödeyen kurum, defteri tutan
    slip_number VARCHAR(50) NOT NULL,
    withdrawal_request_id UUID REFERENCES withdrawal_requests(id) ON DELETE RESTRICT,
    real_world_account_id INTEGER NOT NULL,           -- paranın çıktığı kurumun kasa/banka hesabı
    source_chart_account_id INTEGER NOT NULL,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    fee_deducted DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (fee_deducted >= 0),
    net_paid_amount DECIMAL(18, 8) NOT NULL CHECK (net_paid_amount > 0),
    currency SMALLINT NOT NULL,
    issued_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    recipient_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    journal_entry_id UUID,
    cash_outflow_slip_status SMALLINT NOT NULL DEFAULT 0,   -- 0=DÜZENLENDİ, 1=ÖDENDİ, 2=İPTAL
    cash_outflow_slip_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_cos_institution_number UNIQUE (institution_id, slip_number),
    CONSTRAINT fk_cos_rwa FOREIGN KEY (real_world_account_id, institution_id)
        REFERENCES real_world_accounts (id, owner_institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_cos_account FOREIGN KEY (source_chart_account_id, institution_id)
        REFERENCES chart_of_accounts (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_cos_journal FOREIGN KEY (journal_entry_id, institution_id)
        REFERENCES journal_entries (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_cos_net CHECK (net_paid_amount = amount - fee_deducted) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_cash_outflow_per_request
    ON cash_outflow_slips (withdrawal_request_id)
    WHERE withdrawal_request_id IS NOT NULL AND cash_outflow_slip_status <> 2; 

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
    revoked_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT ); -- FORCED_BY_ADMIN ise dolu
CREATE INDEX IF NOT EXISTS idx_auth_sessions_user ON auth_sessions(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_jti ON auth_sessions(token_jti) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_auth_sessions_active_window ON auth_sessions(user_id, issued_at, last_seen_at) WHERE is_active = true;
COMMENT ON TABLE auth_sessions IS
 'Her login ile bir satır açılır. Middleware her istekte token_jti''nin is_active=true olduğunu doğrulamalı (JWT tek başına yeterli kimlik kanıtı DEĞİLDİR — DB/Redis''teki oturum durumu esastır).';

-- Kategori x ulke kurallari: varsayilan KAPALI; acik izin verilmeyen kategori/ulke yayinlanamaz
CREATE TABLE IF NOT EXISTS category_country_rules (
    id SERIAL PRIMARY KEY,
    category_code SMALLINT NOT NULL,
    country_code SMALLINT,-- NULL = tüm ülkeler (varsayılan kural, ülke satırı onu ezer)
    is_allowed BOOLEAN NOT NULL DEFAULT false,
    required_permit_type SMALLINT, -- NULL = izin belgesi gerekmez; dolu ise satıcı bu türde geçerli izne sahip olmalı
    min_seller_verification_level SMALLINT,
    min_buyer_verification_level SMALLINT,
    allow_private_seller BOOLEAN NOT NULL DEFAULT false,
    min_buyer_age SMALLINT CHECK (min_buyer_age IS NULL OR min_buyer_age >= 0),
    requires_contract_type SMALLINT, -- satıştan önce kabul edilmesi gereken sözleşme türü
    effective_from DATE NOT NULL,
    effective_until DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_ccr_dates CHECK (effective_until IS NULL OR effective_until >= effective_from) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_ccr_rule
    ON category_country_rules (category_code, (COALESCE(country_code, -1)), effective_from);
CREATE INDEX IF NOT EXISTS idx_ccr_lookup ON category_country_rules(category_code, country_code);

-- Sistemin genel urun bilgilerini tutar herhangi bir urun veya hizmet turu
CREATE TABLE IF NOT EXISTS listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,      -- kurumsal / şahıs işletmesi satıcı
    seller_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,             -- bireysel (ikinci el) satıcı
    category_code SMALLINT NOT NULL,
    country_code SMALLINT NOT NULL,
    listing_title VARCHAR(200) NOT NULL,
    listing_description TEXT,
    price DECIMAL(18, 8) NOT NULL CHECK (price >= 0),
    currency SMALLINT NOT NULL,
    tax_category_code SMALLINT NOT NULL DEFAULT 0,
    price_includes_tax BOOLEAN NOT NULL DEFAULT true,
    is_service BOOLEAN NOT NULL DEFAULT false,
    item_condition SMALLINT NOT NULL DEFAULT 0,       -- 0=SIFIR, 1=İKİNCİ EL, 2=YENİLENMİŞ
    quantity_available INTEGER CHECK (quantity_available IS NULL OR quantity_available >= 0),   -- sadece bireysel ilan; kurumsal stok şube bazında
    attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
    listing_status SMALLINT NOT NULL DEFAULT 0,       -- enum_listing_status
    reviewed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_listing_seller CHECK (num_nonnulls(institution_id, seller_user_id) = 1),
    CONSTRAINT chk_listing_private_rules CHECK (seller_user_id IS NULL OR (is_service = false AND quantity_available IS NOT NULL)),
    CONSTRAINT chk_listing_institution_stock CHECK (institution_id IS NULL OR quantity_available IS NULL),
    CONSTRAINT uq_listing_id_institution UNIQUE (id, institution_id),
    CONSTRAINT uq_listing_id_seller_user UNIQUE (id, seller_user_id) );
CREATE INDEX IF NOT EXISTS idx_listings_browse ON listings(category_code, country_code, listing_status) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_listings_institution ON listings(institution_id, listing_status) WHERE institution_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_listings_seller_user ON listings(seller_user_id, listing_status) WHERE seller_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_listings_attributes_gin ON listings USING GIN (attributes);

-- Bireysel saticilarin durumu (limit asiminda isletmeye yonlendirme)
CREATE TABLE IF NOT EXISTS private_seller_profiles (
    user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE RESTRICT,
    country_code SMALLINT NOT NULL,
    seller_status SMALLINT NOT NULL DEFAULT 0,        -- 0=AKTİF, 1=SINIRLI, 2=ASKIDA, 3=İŞLETMEYE YÖNLENDİRİLDİ
    converted_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,   -- açılan şahıs işletmesi
    status_reason TEXT,
    activated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_psp_converted CHECK (seller_status <> 3 OR converted_institution_id IS NOT NULL) );

-- Sube bazli stok durumlarini tutar (parti/lot bazinda)
CREATE TABLE IF NOT EXISTS listing_branch_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    listing_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    lot_no VARCHAR(50),                               -- NULL = partisiz ürün
    expiry_date DATE,
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reserved_quantity INTEGER NOT NULL DEFAULT 0 CHECK (reserved_quantity >= 0),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lbs_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_lbs_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_reserved_lte_stock CHECK (reserved_quantity <= stock_quantity) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_lbs_item ON listing_branch_stock (listing_id, branch_id, (COALESCE(lot_no, '')));
CREATE INDEX IF NOT EXISTS idx_lbs_branch ON listing_branch_stock(branch_id);

-- Cift tarafli stok hareketlerini tutar
CREATE TABLE IF NOT EXISTS stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    listing_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    lot_no VARCHAR(50),
    movement_type SMALLINT NOT NULL,                  -- 0=GİRİŞ, 1=ONLINE SATIŞ, 2=POS SATIŞ, 3=İADE, 4=DÜZELTME
    quantity_delta INTEGER NOT NULL CHECK (quantity_delta <> 0),   -- pozitif=artış, negatif=azalış
    reference_type SMALLINT,                          -- sipariş kalemi, manuel düzeltme, şubeler arası transfer vb.
    reference_id UUID,
    performed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sm_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_sm_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_sm_reference_pair CHECK ((reference_type IS NULL) = (reference_id IS NULL)),
    CONSTRAINT chk_movement_delta_sign CHECK (
        (movement_type IN (0, 3) AND quantity_delta > 0) OR
        (movement_type IN (1, 2) AND quantity_delta < 0) OR
        (movement_type = 4) ) );
CREATE INDEX IF NOT EXISTS idx_stock_movements_listing_branch ON stock_movements(listing_id, branch_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_reference ON stock_movements(reference_type, reference_id);

-- Sube bazli kasa oturumlarini tutar
CREATE TABLE IF NOT EXISTS pos_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    branch_id UUID NOT NULL,
    opened_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    closed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    currency SMALLINT NOT NULL,
    opening_cash_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (opening_cash_amount >= 0),
    expected_closing_cash_amount DECIMAL(18, 8),      -- kapanışta pos_cash_movements toplamından hesaplanır
    closing_cash_amount DECIMAL(18, 8) CHECK (closing_cash_amount IS NULL OR closing_cash_amount >= 0),
    cash_difference DECIMAL(18, 8) GENERATED ALWAYS AS (closing_cash_amount - expected_closing_cash_amount) STORED,
    pos_session_status SMALLINT NOT NULL DEFAULT 0,   -- 0=AÇIK, 1=KAPALI, 2=FARKLI KAPANDI (inceleme)
    opened_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT uq_pos_id_institution UNIQUE (id, institution_id),
    CONSTRAINT fk_pos_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_pos_close CHECK (closed_at IS NULL OR (closing_cash_amount IS NOT NULL AND closed_by_user_id IS NOT NULL)) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_pos_open_per_worker
    ON pos_sessions(branch_id, opened_by_user_id, currency) WHERE pos_session_status = 0;
CREATE INDEX IF NOT EXISTS idx_pos_sessions_branch ON pos_sessions(branch_id, pos_session_status);

-- Kasa nakit hareketleri (satis, para ustu, nakit cikis odemesi, kupon satisi)
CREATE TABLE IF NOT EXISTS pos_cash_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    pos_session_id UUID NOT NULL,
    movement_type SMALLINT NOT NULL DEFAULT 0,        -- 0=NAKİT SATIŞ, 1=PARA ÜSTÜ, 2=NAKİT ÇIKIŞ ÖDEMESİ (çekim), 3=KUPON SATIŞI, 4=MANUEL DÜZELTME
    amount DECIMAL(18, 8) NOT NULL CHECK (amount <> 0),   -- (+) kasaya giriş, (−) kasadan çıkış
    currency SMALLINT NOT NULL,
    reference_type SMALLINT,
    reference_id UUID,
    performed_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pcm_session FOREIGN KEY (pos_session_id, institution_id)
        REFERENCES pos_sessions (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_pcm_reference_pair CHECK ((reference_type IS NULL) = (reference_id IS NULL)) );
CREATE INDEX IF NOT EXISTS idx_pcm_session ON pos_cash_movements(pos_session_id);

-- Ilan gorselleri ve belgeleri (UUID[] yerine: media_assets'e gercek FK)
CREATE TABLE IF NOT EXISTS listing_media (
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    media_asset_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    media_role SMALLINT NOT NULL DEFAULT 0,         -- 0=GALERİ, 1=KAPAK, 2=BELGE
    sort_order SMALLINT NOT NULL DEFAULT 0,
    PRIMARY KEY (listing_id, media_asset_id) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_listing_cover ON listing_media(listing_id) WHERE media_role = 1;

-- Medikal & Eczane: recete/ruhsat gerektiren urun ve hizmetler
CREATE TABLE IF NOT EXISTS medical_listing_details (
    listing_id UUID PRIMARY KEY,
    institution_id INTEGER NOT NULL,
    requires_prescription BOOLEAN NOT NULL DEFAULT false,
    permit_id UUID,                                 -- eczane/sağlık faaliyet izni
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mld_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_mld_permit FOREIGN KEY (permit_id, institution_id)
        REFERENCES institution_business_permits (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_mld_permit_required CHECK (NOT requires_prescription OR permit_id IS NOT NULL) );

-- Gayrimenkul: konum/metrekare bazli arama
CREATE TABLE IF NOT EXISTS real_estate_listing_details (
    listing_id UUID PRIMARY KEY,
    institution_id INTEGER NOT NULL,
    property_type SMALLINT NOT NULL DEFAULT 0,      -- 0=APARTMAN, 1=VİLLA, 2=ARSA, 3=TİCARİ
    listing_kind SMALLINT NOT NULL DEFAULT 0,       -- 0=SATILIK, 1=KİRALIK
    square_meters DECIMAL(10, 2) CHECK (square_meters > 0),
    room_count SMALLINT,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    title_deed_status SMALLINT NOT NULL DEFAULT 0,  -- 0=TEMİZ, 1=İPOTEKLİ, 2=İHTİLAFLI
    title_deed_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,   -- tapu belgesi zorunlu
    fixed_asset_id UUID REFERENCES fixed_assets(id) ON DELETE RESTRICT,                -- kurumun kendi varlığıysa
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reld_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_real_estate_location ON real_estate_listing_details(latitude, longitude);

-- Finansal enstrumanlar: vade/faiz/risk
CREATE TABLE IF NOT EXISTS financial_instrument_details (
    listing_id UUID PRIMARY KEY,
    institution_id INTEGER NOT NULL,
    instrument_type SMALLINT NOT NULL DEFAULT 0,    -- 0=MEVDUAT, 1=FON, 2=TAHVİL, 3=KREDİ ÜRÜNÜ
    permit_id UUID NOT NULL,                        -- finansal faaliyet izni zorunlu
    maturity_months INTEGER CHECK (maturity_months IS NULL OR maturity_months > 0),
    interest_rate DECIMAL(7, 4) CHECK (interest_rate >= 0),
    risk_score SMALLINT CHECK (risk_score BETWEEN 1 AND 10),
    disclosure_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,  -- bilgilendirme/izahname belgesi
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fid_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_fid_permit FOREIGN KEY (permit_id, institution_id)
        REFERENCES institution_business_permits (id, institution_id) ON DELETE RESTRICT );

-- Bahis/Kumar: sik guncellenen oran verisi (cogu ulkede yasak veya ozel izne bagli)
CREATE TABLE IF NOT EXISTS betting_market_details (
    listing_id UUID PRIMARY KEY,
    institution_id INTEGER NOT NULL,
    permit_id UUID NOT NULL,                        -- bahis/oyun izni zorunlu
    event_reference VARCHAR(100) NOT NULL,
    market_type SMALLINT NOT NULL DEFAULT 0,        -- MAÇ SONUCU, ALT/ÜST vb.
    current_odds DECIMAL(8, 4) NOT NULL CHECK (current_odds > 1.00),
    odds_locked BOOLEAN NOT NULL DEFAULT false,
    settles_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bmd_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_bmd_permit FOREIGN KEY (permit_id, institution_id)
        REFERENCES institution_business_permits (id, institution_id) ON DELETE RESTRICT );

-- Sozlesme sablonlari ve versiyon yonetimi (ulkeye gore farkli metin)
CREATE TABLE IF NOT EXISTS digital_contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_type SMALLINT NOT NULL,                -- ORTAKLIK, İŞ SÖZLEŞMESİ, MÜŞTERİ KOŞULLARI, PLATFORM KULLANIMI...
    country_code SMALLINT,                          -- NULL = tüm ülkeler
    title VARCHAR(200) NOT NULL,
    digital_contract_version VARCHAR(20) NOT NULL,
    content_text TEXT NOT NULL,
    content_sha256 VARCHAR(64) NOT NULL,            -- imzalanan metnin özeti (hukuki kanıt)
    media_asset_id UUID REFERENCES media_assets(id),
    is_active BOOLEAN NOT NULL DEFAULT true,
    effective_date TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE UNIQUE INDEX IF NOT EXISTS uq_dc_type_country_version
    ON digital_contracts (contract_type, (COALESCE(country_code, -1)), digital_contract_version);

-- Onay loglari (KVKK / hukuki gecerlilik)
CREATE TABLE IF NOT EXISTS contract_acceptances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES digital_contracts(id) ON DELETE RESTRICT,
    signer_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    signer_role SMALLINT NOT NULL DEFAULT 0,        -- KULLANICI, ÇALIŞAN, KURUM SAHİBİ, ORTAK
    institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,   -- sözleşmenin hangi kurum bağlamında imzalandığı
    signer_ip VARCHAR(64) NOT NULL,
    content_sha256 VARCHAR(64) NOT NULL,            -- imza anındaki metin özeti
    signed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE UNIQUE INDEX IF NOT EXISTS uq_contract_acceptance
    ON contract_acceptances (contract_id, signer_user_id, (COALESCE(institution_id, 0)));
CREATE INDEX IF NOT EXISTS idx_ca_signer ON contract_acceptances(signer_user_id);

-- Pazaryeri Siparis Yasam Dongusu (baslik: tek satici, birden fazla kalem)
CREATE TABLE IF NOT EXISTS marketplace_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    seller_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    seller_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,           -- bireysel satıcı
    branch_id UUID,
    assigned_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    sales_channel SMALLINT NOT NULL DEFAULT 0,        -- 0=ONLINE, 1=POS
    payment_method SMALLINT NOT NULL DEFAULT 0,       -- 0=CÜZDAN, 1=NAKİT (POS)
    pos_session_id UUID,
    cash_tendered DECIMAL(18, 8) CHECK (cash_tendered IS NULL OR cash_tendered >= 0),
    change_given DECIMAL(18, 8) CHECK (change_given IS NULL OR change_given >= 0),
    escrow_id UUID,                                   -- emanete alınan ödeme
    escrow_created_at TIMESTAMP WITH TIME ZONE,
    transaction_id UUID,                              -- doğrudan cüzdan ödemesi (escrow'suz)
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    order_status SMALLINT NOT NULL DEFAULT 0,         -- 0=OLUŞTU, 1=ÖDEME BLOKE, 2=HAZIRLANIYOR, 3=YOLDA, 4=TAMAMLANDI, 5=İPTAL
    subtotal_amount DECIMAL(18, 8) NOT NULL CHECK (subtotal_amount >= 0),     -- vergi hariç
    tax_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    total_amount NUMERIC(18, 8) NOT NULL CHECK (total_amount > 0),
    currency SMALLINT NOT NULL,
    order_details JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_order_seller CHECK (num_nonnulls(seller_institution_id, seller_user_id) = 1),
    CONSTRAINT uq_order_id_institution UNIQUE (id, seller_institution_id),
    CONSTRAINT uq_order_id_seller_user UNIQUE (id, seller_user_id),
    CONSTRAINT fk_order_branch FOREIGN KEY (branch_id, seller_institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_pos FOREIGN KEY (pos_session_id, seller_institution_id)
        REFERENCES pos_sessions (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_escrow FOREIGN KEY (escrow_id, escrow_created_at)
        REFERENCES escrow_records (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT fk_order_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_order_escrow_pair CHECK ((escrow_id IS NULL) = (escrow_created_at IS NULL)),
    CONSTRAINT chk_order_tx_pair CHECK ((transaction_id IS NULL) = (transaction_created_at IS NULL)),
    CONSTRAINT chk_order_total CHECK (total_amount = subtotal_amount + tax_amount),
    CONSTRAINT chk_order_pos_cash CHECK (payment_method <> 1 OR
        (sales_channel = 1 AND pos_session_id IS NOT NULL AND cash_tendered IS NOT NULL AND change_given = cash_tendered - total_amount)),
    CONSTRAINT chk_order_private CHECK (seller_user_id IS NULL OR
        (branch_id IS NULL AND pos_session_id IS NULL AND sales_channel = 0 AND payment_method = 0)) );
CREATE INDEX IF NOT EXISTS idx_orders_branch ON marketplace_orders(branch_id);
CREATE INDEX IF NOT EXISTS idx_orders_pos_session ON marketplace_orders(pos_session_id) WHERE pos_session_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_orders_customer ON marketplace_orders(customer_user_id);
CREATE INDEX IF NOT EXISTS idx_orders_institution ON marketplace_orders(seller_institution_id) WHERE seller_institution_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_orders_seller_user ON marketplace_orders(seller_user_id) WHERE seller_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_orders_status ON marketplace_orders(order_status);

-- Siparis kalemleri: miktar, birim fiyat, vergi
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    listing_id UUID NOT NULL,
    seller_institution_id INTEGER,
    seller_user_id INTEGER,
    branch_id UUID,                                   -- hangi şube stoğundan (kurumsal fiziksel ürün)
    lot_no VARCHAR(50),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price_net DECIMAL(18, 8) NOT NULL CHECK (unit_price_net >= 0),
    tax_rate_rule_id INTEGER REFERENCES tax_rates_and_rules(id) ON DELETE RESTRICT,
    tax_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    line_total DECIMAL(18, 8) NOT NULL CHECK (line_total >= 0),
    currency SMALLINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_oi_seller CHECK (num_nonnulls(seller_institution_id, seller_user_id) = 1),
    CONSTRAINT uq_oi_id_listing UNIQUE (id, listing_id),
    CONSTRAINT fk_oi_order_inst FOREIGN KEY (order_id, seller_institution_id)
        REFERENCES marketplace_orders (id, seller_institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_oi_order_user FOREIGN KEY (order_id, seller_user_id)
        REFERENCES marketplace_orders (id, seller_user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_oi_listing_inst FOREIGN KEY (listing_id, seller_institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_oi_listing_user FOREIGN KEY (listing_id, seller_user_id)
        REFERENCES listings (id, seller_user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_oi_branch FOREIGN KEY (branch_id, seller_institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_oi_line_total CHECK (line_total = quantity * unit_price_net + tax_amount) );
CREATE INDEX IF NOT EXISTS idx_oi_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_oi_listing ON order_items(listing_id);

-- Bahis oran gecmisi (anlasmazlik kaniti; sadece ekleme)
CREATE TABLE IF NOT EXISTS betting_odds_history (
    id BIGSERIAL PRIMARY KEY,
    listing_id UUID NOT NULL REFERENCES betting_market_details(listing_id) ON DELETE RESTRICT,
    odds DECIMAL(8, 4) NOT NULL CHECK (odds > 1.00),
    odds_locked BOOLEAN NOT NULL DEFAULT false,
    recorded_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_boh_listing ON betting_odds_history(listing_id, recorded_at DESC);

-- Bahis kaydi: siparis kaleminin 1:1 uzantisi
CREATE TABLE IF NOT EXISTS betting_wagers (
    order_item_id UUID PRIMARY KEY,
    listing_id UUID NOT NULL REFERENCES betting_market_details(listing_id) ON DELETE RESTRICT,
    selection_code SMALLINT NOT NULL,                 -- seçilen sonuç (market türüne göre enum)
    stake_amount DECIMAL(18, 8) NOT NULL CHECK (stake_amount > 0),
    odds_at_placement DECIMAL(8, 4) NOT NULL CHECK (odds_at_placement > 1.00),
    odds_history_id BIGINT NOT NULL REFERENCES betting_odds_history(id) ON DELETE RESTRICT,   -- bahis anındaki oran kaydı
    potential_payout DECIMAL(18, 8) GENERATED ALWAYS AS ((stake_amount * odds_at_placement)::DECIMAL(18, 8)) STORED,
    wager_status SMALLINT NOT NULL DEFAULT 0,         -- 0=AÇIK, 1=KAZANDI, 2=KAYBETTİ, 3=İPTAL/İADE
    payout_transaction_id UUID,
    payout_transaction_created_at TIMESTAMP WITH TIME ZONE,
    settled_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bw_item FOREIGN KEY (order_item_id, listing_id)
        REFERENCES order_items (id, listing_id) ON DELETE RESTRICT,
    CONSTRAINT fk_bw_payout_tx FOREIGN KEY (payout_transaction_id, payout_transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_bw_payout_pair CHECK ((payout_transaction_id IS NULL) = (payout_transaction_created_at IS NULL)),
    CONSTRAINT chk_bw_won_paid CHECK (wager_status <> 1 OR payout_transaction_id IS NOT NULL) );
CREATE INDEX IF NOT EXISTS idx_bw_listing ON betting_wagers(listing_id, wager_status);

-- Kiralama / rezervasyon slotlari
CREATE TABLE IF NOT EXISTS booking_availability_slots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    listing_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    slot_start TIMESTAMP WITH TIME ZONE NOT NULL,
    slot_end TIMESTAMP WITH TIME ZONE NOT NULL,
    total_capacity INTEGER NOT NULL CHECK (total_capacity > 0),
    booked_capacity INTEGER NOT NULL DEFAULT 0 CHECK (booked_capacity >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_bas_id_listing UNIQUE (id, listing_id),
    CONSTRAINT fk_bas_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_bas_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_slot_dates CHECK (slot_end > slot_start),
    CONSTRAINT chk_slot_capacity CHECK (booked_capacity <= total_capacity) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_bas_slot ON booking_availability_slots(listing_id, branch_id, slot_start, slot_end);
CREATE INDEX IF NOT EXISTS idx_booking_slots_listing_time ON booking_availability_slots(listing_id, slot_start, slot_end);
CREATE INDEX IF NOT EXISTS idx_booking_slots_branch ON booking_availability_slots(branch_id);

-- Rezervasyon detayi (siparis kaleminin 1-1 uzantisi)
CREATE TABLE IF NOT EXISTS booking_details (
    order_item_id UUID PRIMARY KEY,
    listing_id UUID NOT NULL,
    availability_slot_id UUID NOT NULL,
    guest_or_party_count INTEGER CHECK (guest_or_party_count IS NULL OR guest_or_party_count > 0),
    check_in_at TIMESTAMP WITH TIME ZONE,
    check_out_at TIMESTAMP WITH TIME ZONE,
    cancellation_policy SMALLINT NOT NULL DEFAULT 0,   -- 0=ESNEK, 1=ORTA, 2=KATI, 3=İADESİZ
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    no_show BOOLEAN NOT NULL DEFAULT false,
    refund_amount DECIMAL(18, 8) CHECK (refund_amount IS NULL OR refund_amount >= 0),
    refund_transaction_id UUID,
    refund_transaction_created_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bd_item FOREIGN KEY (order_item_id, listing_id)
        REFERENCES order_items (id, listing_id) ON DELETE RESTRICT,
    CONSTRAINT fk_bd_slot FOREIGN KEY (availability_slot_id, listing_id)
        REFERENCES booking_availability_slots (id, listing_id) ON DELETE RESTRICT,
    CONSTRAINT fk_bd_refund_tx FOREIGN KEY (refund_transaction_id, refund_transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_bd_refund_pair CHECK ((refund_transaction_id IS NULL) = (refund_transaction_created_at IS NULL)),
    CONSTRAINT chk_bd_times CHECK (check_out_at IS NULL OR check_in_at IS NULL OR check_out_at > check_in_at),
    CONSTRAINT chk_bd_cancel_state CHECK (cancelled_at IS NULL OR no_show = false),
    CONSTRAINT chk_bd_refund_needs_cancel CHECK (refund_amount IS NULL OR cancelled_at IS NOT NULL OR no_show) );
CREATE INDEX IF NOT EXISTS idx_bd_slot ON booking_details(availability_slot_id);

-- Digital icerik urunlerinin detaylarini tutar
CREATE TABLE IF NOT EXISTS content_listing_details (
    listing_id UUID PRIMARY KEY,
    institution_id INTEGER NOT NULL,
    content_type SMALLINT NOT NULL DEFAULT 0,
    duration_seconds INTEGER CHECK (duration_seconds IS NULL OR duration_seconds > 0),
    release_date DATE,
    usage_license_type SMALLINT NOT NULL DEFAULT 0,    -- izleme, indirme, ticari kullanım vb. (eski license_type; platform lisanslarıyla karışmasın diye adı değişti)
    rights_scope SMALLINT NOT NULL DEFAULT 0,          -- 0=GLOBAL, 1=SADECE LİSTELENEN ÜLKELER, 2=LİSTELENENLER HARİÇ
    rights_expires_at TIMESTAMP WITH TIME ZONE,
    rights_proof_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,   -- dağıtım/telif hakkı belgesi
    primary_media_asset_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,           -- asıl içerik dosyası
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cld_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT );

-- Icerik hak bolgeleri (eski rights_territory VARCHAR yerine ulke listesi)
CREATE TABLE IF NOT EXISTS content_listing_territories (
    listing_id UUID NOT NULL REFERENCES content_listing_details(listing_id) ON DELETE RESTRICT,
    country_code SMALLINT NOT NULL,
    PRIMARY KEY (listing_id, country_code) );

-- Kullanicinin satin aldigi goruntuleme/erisim hakki (siparis kalemi basina)
CREATE TABLE IF NOT EXISTS content_view_licenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_item_id UUID NOT NULL UNIQUE,
    listing_id UUID NOT NULL REFERENCES content_listing_details(listing_id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,               -- NULL = süresiz
    revoked_at TIMESTAMP WITH TIME ZONE,
    revoke_reason TEXT,
    CONSTRAINT fk_cvl_item FOREIGN KEY (order_item_id, listing_id)
        REFERENCES order_items (id, listing_id) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_content_licenses_user ON content_view_licenses(user_id, listing_id);

-- Profesyonel hizmet urunlerinin detaylarini tutar
CREATE TABLE IF NOT EXISTS service_engagement_details (
    order_item_id UUID PRIMARY KEY,
    listing_id UUID NOT NULL,
    engagement_type SMALLINT NOT NULL DEFAULT 0,       -- 0=SAATLİK, 1=SABİT PROJE, 2=RETAINER
    scope_description TEXT NOT NULL,
    estimated_hours DECIMAL(8, 2) CHECK (estimated_hours IS NULL OR estimated_hours > 0),
    hourly_rate DECIMAL(18, 8) CHECK (hourly_rate IS NULL OR hourly_rate >= 0),
    start_date DATE,
    target_end_date DATE,
    actual_end_date DATE,
    service_engagement_detail_status SMALLINT NOT NULL DEFAULT 0,   -- 0=KAPSAM, 1=DEVAM EDİYOR, 2=TESLİM EDİLDİ, 3=KAPANDI
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sed_item FOREIGN KEY (order_item_id, listing_id)
        REFERENCES order_items (id, listing_id) ON DELETE RESTRICT,
    CONSTRAINT chk_engagement_dates CHECK (target_end_date IS NULL OR start_date IS NULL OR target_end_date >= start_date),
    CONSTRAINT chk_engagement_actual CHECK (actual_end_date IS NULL OR start_date IS NULL OR actual_end_date >= start_date) );

-- Hizmet asamalari: her asamanin tutari emanete alinir, onayla saticiya serbest birakilir
CREATE TABLE IF NOT EXISTS service_engagement_milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_item_id UUID NOT NULL REFERENCES service_engagement_details(order_item_id) ON DELETE RESTRICT,
    milestone_title VARCHAR(150) NOT NULL,
    due_date DATE,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount >= 0),
    currency SMALLINT NOT NULL,
    service_engagement_milestone_status SMALLINT NOT NULL DEFAULT 0,   -- 0=BEKLİYOR, 1=TESLİM EDİLDİ, 2=ONAYLANDI, 3=ÖDENDİ, 4=İTİRAZLI
    escrow_id UUID,
    escrow_created_at TIMESTAMP WITH TIME ZONE,
    release_transaction_id UUID,
    release_transaction_created_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    approved_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sem_escrow FOREIGN KEY (escrow_id, escrow_created_at)
        REFERENCES escrow_records (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT fk_sem_release_tx FOREIGN KEY (release_transaction_id, release_transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_sem_escrow_pair CHECK ((escrow_id IS NULL) = (escrow_created_at IS NULL)),
    CONSTRAINT chk_sem_release_pair CHECK ((release_transaction_id IS NULL) = (release_transaction_created_at IS NULL)),
    CONSTRAINT chk_sem_paid CHECK (service_engagement_milestone_status <> 3 OR release_transaction_id IS NOT NULL) );
CREATE INDEX IF NOT EXISTS idx_milestones_order_item ON service_engagement_milestones(order_item_id);

-- Egitim hizmetleri detaylarini tutar
CREATE TABLE IF NOT EXISTS education_program_details (
    listing_id UUID PRIMARY KEY,
    institution_id INTEGER NOT NULL,
    program_type SMALLINT NOT NULL DEFAULT 0,          -- 0=KURS, 1=DİPLOMA/DERECE, 2=SERTİFİKA, 3=ATÖLYE
    accreditation_permit_id UUID,                      -- diploma/sertifika veren programlar için eğitim kurumu izni
    duration_weeks INTEGER CHECK (duration_weeks IS NULL OR duration_weeks > 0),
    credit_hours DECIMAL(6, 2) CHECK (credit_hours IS NULL OR credit_hours >= 0),
    max_enrollment INTEGER CHECK (max_enrollment IS NULL OR max_enrollment > 0),
    current_enrollment INTEGER NOT NULL DEFAULT 0 CHECK (current_enrollment >= 0),
    instructor_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_epd_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_epd_permit FOREIGN KEY (accreditation_permit_id, institution_id)
        REFERENCES institution_business_permits (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_epd_accreditation CHECK (program_type NOT IN (1, 2) OR accreditation_permit_id IS NOT NULL),
    CONSTRAINT chk_enrollment_capacity CHECK (max_enrollment IS NULL OR current_enrollment <= max_enrollment) );

-- Egitim kayitlari (siparis kalemi basina; ogrenci alicidan farkli olabilir)
CREATE TABLE IF NOT EXISTS education_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_item_id UUID NOT NULL UNIQUE,
    listing_id UUID NOT NULL REFERENCES education_program_details(listing_id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,     -- öğrenci
    enrollment_status SMALLINT NOT NULL DEFAULT 0,     -- 0=KAYITLI, 1=DEVAM EDİYOR, 2=TAMAMLADI, 3=AYRILDI
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    certificate_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    CONSTRAINT fk_ee_item FOREIGN KEY (order_item_id, listing_id)
        REFERENCES order_items (id, listing_id) ON DELETE RESTRICT,
    CONSTRAINT chk_ee_completed CHECK (enrollment_status <> 2 OR completed_at IS NOT NULL) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_enrollment_active
    ON education_enrollments(listing_id, user_id) WHERE enrollment_status <> 3;
CREATE INDEX IF NOT EXISTS idx_enrollments_user ON education_enrollments(user_id);

-- Gonderi detaylari (siparis duzeyi): lojistik hizmeti veya mal teslimati
CREATE TABLE IF NOT EXISTS logistics_shipment_details (
    order_id UUID PRIMARY KEY REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    seller_institution_id INTEGER,
    origin_branch_id UUID,
    origin_country_code SMALLINT NOT NULL,
    destination_country_code SMALLINT NOT NULL,
    destination_address TEXT NOT NULL,
    destination_lat DECIMAL(9, 6),
    destination_lng DECIMAL(9, 6),
    weight_kg DECIMAL(10, 3) CHECK (weight_kg IS NULL OR weight_kg > 0),
    volume_m3 DECIMAL(10, 3) CHECK (volume_m3 IS NULL OR volume_m3 > 0),
    carrier_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,   -- taşıyıcı lojistik şirketi (satıcının kendisi de olabilir)
    carrier_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    tracking_number VARCHAR(100),
    customs_declaration_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    sla_target_hours INTEGER CHECK (sla_target_hours IS NULL OR sla_target_hours > 0),
    logistics_shipment_detail_status SMALLINT NOT NULL DEFAULT 0,   -- 0=OLUŞTU, 1=TESLİM ALINDI, 2=YOLDA, 3=DAĞITIMDA, 4=TESLİM EDİLDİ, 5=BAŞARISIZ
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lsd_order_inst FOREIGN KEY (order_id, seller_institution_id)
        REFERENCES marketplace_orders (id, seller_institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_lsd_origin_branch FOREIGN KEY (origin_branch_id, seller_institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_lsd_cross_border CHECK (origin_country_code = destination_country_code OR customs_declaration_media_id IS NOT NULL) );
CREATE INDEX IF NOT EXISTS idx_lsd_carrier ON logistics_shipment_details(carrier_institution_id, logistics_shipment_detail_status);

-- Gonderi durum olaylari
CREATE TABLE IF NOT EXISTS logistics_status_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES marketplace_orders(id) ON DELETE RESTRICT,
    event_type SMALLINT NOT NULL DEFAULT 0,            -- TESLİM ALINDI, MERKEZE ULAŞTI, DAĞITIMDA, TESLİM EDİLDİ, BAŞARISIZ DENEME
    event_lat DECIMAL(9, 6),
    event_lng DECIMAL(9, 6),
    proof_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,   -- teslim fotoğrafı/imza
    recorded_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    notes TEXT,
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE INDEX IF NOT EXISTS idx_logistics_events_order ON logistics_status_events(order_id, occurred_at);

-- Bulut hizmetlerinin detay bilgilerini tutar
CREATE TABLE IF NOT EXISTS saas_license_details (
    listing_id UUID PRIMARY KEY,
    institution_id INTEGER NOT NULL,
    license_model SMALLINT NOT NULL DEFAULT 0,        -- 0=ABONELİK, 1=SÜRESİZ, 2=KULLANIM BAZLI
    billing_cycle SMALLINT,                           -- 0=AYLIK, 1=YILLIK, 2=TEK SEFER
    seat_limit INTEGER CHECK (seat_limit IS NULL OR seat_limit > 0),
    device_integration_required BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sld_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT );

-- Bulut hizmetlerine abonelik bilgilerini tutar
CREATE TABLE IF NOT EXISTS saas_active_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_item_id UUID NOT NULL UNIQUE,
    listing_id UUID NOT NULL REFERENCES saas_license_details(listing_id) ON DELETE RESTRICT,
    subscriber_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    subscriber_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    payment_wallet_id UUID,
    payment_wallet_type SMALLINT NOT NULL,
    currency SMALLINT NOT NULL,
    auto_renew BOOLEAN NOT NULL DEFAULT false,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    current_period_end TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    saas_active_subscription_status SMALLINT NOT NULL DEFAULT 0,    -- 0=AKTİF, 1=ÖDEME GECİKTİ, 2=İPTAL, 3=SÜRESİ DOLDU
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sas_item FOREIGN KEY (order_item_id, listing_id)
        REFERENCES order_items (id, listing_id) ON DELETE RESTRICT,
    CONSTRAINT fk_sas_wallet FOREIGN KEY (payment_wallet_id, payment_wallet_type, currency)
        REFERENCES wallets (id, wallet_type, currency) ON DELETE RESTRICT,
    CONSTRAINT chk_saas_subscriber CHECK (num_nonnulls(subscriber_user_id, subscriber_institution_id) = 1),
    CONSTRAINT chk_saas_autorenew CHECK (auto_renew = false OR payment_wallet_id IS NOT NULL),
    CONSTRAINT chk_saas_cancelled CHECK (saas_active_subscription_status <> 2 OR cancelled_at IS NOT NULL) );
CREATE INDEX IF NOT EXISTS idx_saas_subs_period_end
    ON saas_active_subscriptions(current_period_end) WHERE saas_active_subscription_status = 0;
-- Ayni abone ayni ilana ayni anda tek aktif abonelik
CREATE UNIQUE INDEX IF NOT EXISTS uq_saas_active
    ON saas_active_subscriptions (listing_id, (COALESCE(subscriber_user_id, -1)), (COALESCE(subscriber_institution_id, -1)))
    WHERE saas_active_subscription_status IN (0, 1);

-- Kurumsal aboneliklerde koltuk atamalari
CREATE TABLE IF NOT EXISTS saas_subscription_seats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES saas_active_subscriptions(id) ON DELETE RESTRICT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP WITH TIME ZONE );
CREATE UNIQUE INDEX IF NOT EXISTS uq_sss_active_seat
    ON saas_subscription_seats(subscription_id, user_id) WHERE revoked_at IS NULL;

-- Olculebilir kaynak abonelikleri (konsorsiyum kaynak havuzundan)
CREATE TABLE IF NOT EXISTS hosting_resource_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,                  -- sağlayıcı kurum (ilanı yayınlayan)
    order_item_id UUID NOT NULL UNIQUE,
    listing_id UUID NOT NULL,
    subscriber_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    subscriber_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    resource_pool_id UUID NOT NULL,
    allocated_capacity DECIMAL(18, 8) NOT NULL CHECK (allocated_capacity > 0),
    unit_type SMALLINT NOT NULL DEFAULT 0,
    billing_cycle SMALLINT NOT NULL DEFAULT 0,
    payment_wallet_id UUID,
    payment_wallet_type SMALLINT NOT NULL,
    currency SMALLINT NOT NULL,
    auto_renew BOOLEAN NOT NULL DEFAULT false,
    current_period_end TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    hosting_resource_subscription_status SMALLINT NOT NULL DEFAULT 0,   -- 0=AKTİF, 1=ÖDEME GECİKTİ, 2=İPTAL, 3=SÜRESİ DOLDU
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hrs_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_hrs_item FOREIGN KEY (order_item_id, listing_id)
        REFERENCES order_items (id, listing_id) ON DELETE RESTRICT,
    CONSTRAINT fk_hrs_pool FOREIGN KEY (resource_pool_id, institution_id)
        REFERENCES consortium_resource_pools (id, provider_institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_hrs_wallet FOREIGN KEY (payment_wallet_id, payment_wallet_type, currency)
        REFERENCES wallets (id, wallet_type, currency) ON DELETE RESTRICT,
    CONSTRAINT chk_hosting_subscriber CHECK (num_nonnulls(subscriber_user_id, subscriber_institution_id) = 1),
    CONSTRAINT chk_hosting_autorenew CHECK (auto_renew = false OR payment_wallet_id IS NOT NULL),
    CONSTRAINT chk_hosting_cancelled CHECK (hosting_resource_subscription_status <> 2 OR cancelled_at IS NOT NULL) );
CREATE INDEX IF NOT EXISTS idx_hrs_pool ON hosting_resource_subscriptions(resource_pool_id, hosting_resource_subscription_status);

-- Yinelenen abonelik tahsilatlari (SaaS ve hosting icin ortak)
CREATE TABLE IF NOT EXISTS subscription_charges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    saas_subscription_id UUID REFERENCES saas_active_subscriptions(id) ON DELETE RESTRICT,
    hosting_subscription_id UUID REFERENCES hosting_resource_subscriptions(id) ON DELETE RESTRICT,
    period_start TIMESTAMP WITH TIME ZONE NOT NULL,
    period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    tax_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    currency SMALLINT NOT NULL,
    due_at TIMESTAMP WITH TIME ZONE NOT NULL,
    attempt_count SMALLINT NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
    charge_status SMALLINT NOT NULL DEFAULT 0,        -- 0=BEKLİYOR, 1=ÖDENDİ, 2=BAŞARISIZ, 3=İPTAL
    paid_at TIMESTAMP WITH TIME ZONE,
    transaction_id UUID,
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sc_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_sc_subscription CHECK (num_nonnulls(saas_subscription_id, hosting_subscription_id) = 1),
    CONSTRAINT chk_sc_period CHECK (period_end > period_start),
    CONSTRAINT chk_sc_tx_pair CHECK ((transaction_id IS NULL) = (transaction_created_at IS NULL)),
    CONSTRAINT chk_sc_paid CHECK (charge_status <> 1 OR transaction_id IS NOT NULL) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_sc_saas_period
    ON subscription_charges(saas_subscription_id, period_start) WHERE saas_subscription_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_sc_hosting_period
    ON subscription_charges(hosting_subscription_id, period_start) WHERE hosting_subscription_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_sc_due ON subscription_charges(due_at) WHERE charge_status = 0;

-- Hammade tanimlamalarini tutar
CREATE TABLE IF NOT EXISTS raw_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    material_code VARCHAR(50) NOT NULL,
    material_name VARCHAR(150) NOT NULL,
    unit_type SMALLINT NOT NULL DEFAULT 0,             -- KG, LT, ADET, M2, M3, TON vb. (eski unit_symbol)
    default_supplier_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    min_stock_alert_qty DECIMAL(18, 4) NOT NULL DEFAULT 0.00 CHECK (min_stock_alert_qty >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_institution_material_code UNIQUE (institution_id, material_code),
    CONSTRAINT uq_rawmat_id_institution UNIQUE (id, institution_id) );
CREATE INDEX IF NOT EXISTS idx_raw_materials_institution ON raw_materials(institution_id);

-- Hammade stoklarinin sube/lot bazli bilgilerini tutar
CREATE TABLE IF NOT EXISTS raw_material_branch_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    raw_material_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    lot_no VARCHAR(50),
    expiry_date DATE,
    stock_quantity DECIMAL(18, 4) NOT NULL DEFAULT 0.00 CHECK (stock_quantity >= 0),
    reserved_quantity DECIMAL(18, 4) NOT NULL DEFAULT 0.00 CHECK (reserved_quantity >= 0),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rmbs_material FOREIGN KEY (raw_material_id, institution_id)
        REFERENCES raw_materials (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_rmbs_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_raw_reserved_lte_stock CHECK (reserved_quantity <= stock_quantity) );
CREATE UNIQUE INDEX IF NOT EXISTS uq_rmbs ON raw_material_branch_stock (raw_material_id, branch_id, (COALESCE(lot_no, '')));
CREATE INDEX IF NOT EXISTS idx_rmbs_branch ON raw_material_branch_stock(branch_id);

-- Hammade hareketlerinin muhasebe defteri
CREATE TABLE IF NOT EXISTS raw_material_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    raw_material_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    lot_no VARCHAR(50),
    movement_type SMALLINT NOT NULL,                   -- 0=SATIN ALMA GİRİŞİ, 1=ÜRETİM TÜKETİMİ, 2=ÜRETİMDEN İADE, 3=DÜZELTME, 4=FİRE, 5=TEDARİKÇİYE İADE
    quantity_delta DECIMAL(18, 4) NOT NULL CHECK (quantity_delta <> 0),
    reference_type SMALLINT,                           -- tedarik siparişi kalemi, üretim partisi, manuel düzeltme
    reference_id UUID,
    performed_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rmm_material FOREIGN KEY (raw_material_id, institution_id)
        REFERENCES raw_materials (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_rmm_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_rmm_reference_pair CHECK ((reference_type IS NULL) = (reference_id IS NULL)),
    CONSTRAINT chk_raw_movement_delta_sign CHECK (
        (movement_type IN (0, 2) AND quantity_delta > 0) OR
        (movement_type IN (1, 4, 5) AND quantity_delta < 0) OR
        (movement_type = 3) ) );
CREATE INDEX IF NOT EXISTS idx_raw_movements_material_branch ON raw_material_movements(raw_material_id, branch_id);
CREATE INDEX IF NOT EXISTS idx_raw_movements_reference ON raw_material_movements(reference_type, reference_id);

-- Recete bilgilerini tutar
CREATE TABLE IF NOT EXISTS production_recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    listing_id UUID NOT NULL,                          -- üretilen bitmiş ürün
    recipe_name VARCHAR(150) NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    output_quantity DECIMAL(18, 4) NOT NULL CHECK (output_quantity > 0),
    output_unit_type SMALLINT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_recipe_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT unq_recipe_listing_version UNIQUE (listing_id, version),
    CONSTRAINT uq_recipe_id_institution UNIQUE (id, institution_id) );
CREATE INDEX IF NOT EXISTS idx_recipes_institution ON production_recipes(institution_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_active_recipe_per_listing ON production_recipes (listing_id) WHERE is_active = true;

CREATE TABLE IF NOT EXISTS production_recipe_components (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    recipe_id UUID NOT NULL,
    raw_material_id UUID NOT NULL,
    quantity_per_batch DECIMAL(18, 4) NOT NULL CHECK (quantity_per_batch > 0),   -- output_quantity başına gereken miktar
    notes TEXT,
    CONSTRAINT fk_prc_recipe FOREIGN KEY (recipe_id, institution_id)
        REFERENCES production_recipes (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_prc_material FOREIGN KEY (raw_material_id, institution_id)
        REFERENCES raw_materials (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT unq_recipe_component UNIQUE (recipe_id, raw_material_id) );

-- Uretim planlama bilgilerini tutar
CREATE TABLE IF NOT EXISTS production_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    recipe_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    cadence SMALLINT NOT NULL DEFAULT 0,               -- enum_production_cadence
    planned_quantity_per_cycle DECIMAL(18, 4) NOT NULL CHECK (planned_quantity_per_cycle > 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    next_run_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_psched_recipe FOREIGN KEY (recipe_id, institution_id)
        REFERENCES production_recipes (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_psched_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT uq_psched_id_institution UNIQUE (id, institution_id) );
CREATE INDEX IF NOT EXISTS idx_prod_schedules_recipe ON production_schedules(recipe_id);
CREATE INDEX IF NOT EXISTS idx_prod_schedules_branch ON production_schedules(branch_id);
CREATE INDEX IF NOT EXISTS idx_prod_schedules_due ON production_schedules(next_run_at) WHERE is_active = true;

-- Fiili uretim partilerini (lotlari) tutar
CREATE TABLE IF NOT EXISTS production_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    schedule_id UUID,                                  -- NULL = ad-hoc / tek parti / özel sipariş
    recipe_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    batch_number VARCHAR(50) NOT NULL,                 -- parti/lot no (bitmiş ürün stoğunda lot_no olur)
    cadence SMALLINT NOT NULL DEFAULT 0,
    planned_output_quantity DECIMAL(18, 4) NOT NULL CHECK (planned_output_quantity > 0),
    actual_output_quantity DECIMAL(18, 4) CHECK (actual_output_quantity IS NULL OR actual_output_quantity >= 0),
    waste_quantity DECIMAL(18, 4) NOT NULL DEFAULT 0.00 CHECK (waste_quantity >= 0),
    production_run_status SMALLINT NOT NULL DEFAULT 0,   -- enum_production_run_status
    supervised_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    scheduled_start TIMESTAMP WITH TIME ZONE,
    actual_start TIMESTAMP WITH TIME ZONE,
    actual_end TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prun_schedule FOREIGN KEY (schedule_id, institution_id)
        REFERENCES production_schedules (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_prun_recipe FOREIGN KEY (recipe_id, institution_id)
        REFERENCES production_recipes (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_prun_branch FOREIGN KEY (branch_id, institution_id)
        REFERENCES institution_branches (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT unq_recipe_batch_number UNIQUE (recipe_id, batch_number),
    CONSTRAINT uq_prun_id_institution UNIQUE (id, institution_id),
    CONSTRAINT chk_production_run_dates CHECK (actual_end IS NULL OR actual_start IS NULL OR actual_end >= actual_start) );
CREATE INDEX IF NOT EXISTS idx_production_runs_recipe ON production_runs(recipe_id);
CREATE INDEX IF NOT EXISTS idx_production_runs_branch_status ON production_runs(branch_id, production_run_status);
CREATE INDEX IF NOT EXISTS idx_production_runs_schedule ON production_runs(schedule_id) WHERE schedule_id IS NOT NULL;

-- Uretilen urun ile kullanilan hammade farklarini tutar
CREATE TABLE IF NOT EXISTS production_run_consumptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    production_run_id UUID NOT NULL,
    raw_material_id UUID NOT NULL,
    planned_quantity DECIMAL(18, 4) NOT NULL CHECK (planned_quantity >= 0),
    actual_quantity_consumed DECIMAL(18, 4) NOT NULL CHECK (actual_quantity_consumed >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prcons_run FOREIGN KEY (production_run_id, institution_id)
        REFERENCES production_runs (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_prcons_material FOREIGN KEY (raw_material_id, institution_id)
        REFERENCES raw_materials (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT unq_run_consumption_material UNIQUE (production_run_id, raw_material_id) );
CREATE INDEX IF NOT EXISTS idx_run_consumptions_run ON production_run_consumptions(production_run_id);

-- Ozel siparis urunlerinin detay bilgilerini tutar (siparis kaleminin 1-1 uzantisi)
CREATE TABLE IF NOT EXISTS custom_production_details (
    order_item_id UUID PRIMARY KEY,
    institution_id INTEGER NOT NULL,
    listing_id UUID NOT NULL,
    production_run_id UUID,                            -- siparişin üretim partisi
    spec_json JSONB NOT NULL DEFAULT '{}'::jsonb,      -- ölçü, materyal, gravür metni, renk vb.
    proof_required BOOLEAN NOT NULL DEFAULT true,
    proof_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    proof_approved_at TIMESTAMP WITH TIME ZONE,
    estimated_completion_date DATE,
    actual_completion_date DATE,
    custom_production_detail_status SMALLINT NOT NULL DEFAULT 0,   -- 0=ÖZELLİK BEKLİYOR, 1=ÖRNEK GÖNDERİLDİ, 2=ONAYLANDI, 3=ÜRETİMDE, 4=TAMAMLANDI
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cpd_item FOREIGN KEY (order_item_id, listing_id)
        REFERENCES order_items (id, listing_id) ON DELETE RESTRICT,
    CONSTRAINT fk_cpd_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_cpd_run FOREIGN KEY (production_run_id, institution_id)
        REFERENCES production_runs (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_cpd_proof CHECK (proof_approved_at IS NULL OR proof_media_id IS NOT NULL) );

    -- Uretici - distributor iliskilerini tutar
CREATE TABLE IF NOT EXISTS distributor_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    manufacturer_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    distributor_institution_id INTEGER NOT NULL REFERENCES institutions(id) ON DELETE RESTRICT,
    b2b_agreement_id UUID,
    minimum_order_quantity DECIMAL(18, 4) CHECK (minimum_order_quantity IS NULL OR minimum_order_quantity > 0),
    price_tier_json JSONB NOT NULL DEFAULT '{}'::jsonb,      -- miktar kademeli özel fiyatlandırma
    payment_terms_days INTEGER NOT NULL DEFAULT 0 CHECK (payment_terms_days >= 0),
    delivery_frequency SMALLINT NOT NULL DEFAULT 0,          -- enum_distributor_delivery_frequency
    is_active BOOLEAN NOT NULL DEFAULT true,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_distributor_institutions CHECK (manufacturer_institution_id <> distributor_institution_id),
    CONSTRAINT chk_distrel_dates CHECK (ended_at IS NULL OR ended_at >= started_at),
    CONSTRAINT uq_distrel_id_manufacturer UNIQUE (id, manufacturer_institution_id),
    CONSTRAINT fk_distrel_agreement FOREIGN KEY (b2b_agreement_id, distributor_institution_id, manufacturer_institution_id)
        REFERENCES b2b_corporate_agreements (id, buyer_institution_id, seller_institution_id) ON DELETE RESTRICT );
CREATE UNIQUE INDEX IF NOT EXISTS uq_distrel_active
    ON distributor_relationships(manufacturer_institution_id, distributor_institution_id) WHERE is_active;
CREATE INDEX IF NOT EXISTS idx_dist_rel_distributor ON distributor_relationships(distributor_institution_id);

-- Distributorun bildirdigi stok bilgileri (sadece ekleme)
CREATE TABLE IF NOT EXISTS distributor_stock_sync_log (
    id BIGSERIAL PRIMARY KEY,
    manufacturer_institution_id INTEGER NOT NULL,
    distributor_relationship_id UUID NOT NULL,
    listing_id UUID NOT NULL,
    reported_stock_quantity INTEGER NOT NULL CHECK (reported_stock_quantity >= 0),
    sync_source SMALLINT NOT NULL DEFAULT 0,           -- enum_stock_sync_source
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_dssl_relationship FOREIGN KEY (distributor_relationship_id, manufacturer_institution_id)
        REFERENCES distributor_relationships (id, manufacturer_institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_dssl_listing FOREIGN KEY (listing_id, manufacturer_institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT );
CREATE INDEX IF NOT EXISTS idx_dist_stock_sync_relationship
    ON distributor_stock_sync_log(distributor_relationship_id, listing_id, synced_at DESC);

-- Sigortacilik urunlerinin detay bilgilerini tutar
CREATE TABLE IF NOT EXISTS insurance_product_details (
    listing_id UUID PRIMARY KEY,
    institution_id INTEGER NOT NULL,                  -- sigortacı kurum
    permit_id UUID NOT NULL,                          -- sigortacılık faaliyet izni (ülkeye özel)
    insured_subject_type SMALLINT NOT NULL DEFAULT 0, -- 0=KİŞİ, 1=VARLIK (araç/gayrimenkul), 2=SİPARİŞ KALEMİ (alışveriş/rezervasyon koruması), 3=KURUM
    coverage_scope_json JSONB NOT NULL DEFAULT '{}'::jsonb,   -- teminat kalemleri, istisnalar
    deductible_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (deductible_amount >= 0),
    max_coverage_amount DECIMAL(18, 8) NOT NULL CHECK (max_coverage_amount > 0),
    currency SMALLINT NOT NULL,
    waiting_period_days INTEGER NOT NULL DEFAULT 0 CHECK (waiting_period_days >= 0),
    terms_media_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,   -- genel şartlar / poliçe koşulları
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ipd_listing FOREIGN KEY (listing_id, institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_ipd_permit FOREIGN KEY (permit_id, institution_id)
        REFERENCES institution_business_permits (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT uq_ipd_listing_subject UNIQUE (listing_id, insured_subject_type) );

-- Sigortacilik hizmetlerinin police bilgilerini tutar (siparis kaleminin 1-1 uzantisi)
CREATE TABLE IF NOT EXISTS insurance_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issuing_institution_id INTEGER NOT NULL,
    listing_id UUID NOT NULL,
    order_item_id UUID NOT NULL UNIQUE,
    policyholder_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,   -- primi ödeyen / poliçeyi satın alan
    insured_subject_type SMALLINT NOT NULL DEFAULT 0,
    insured_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,                 -- tür=KİŞİ iken boşsa sigortalı = poliçe sahibi
    insured_fixed_asset_id UUID REFERENCES fixed_assets(id) ON DELETE RESTRICT,
    insured_order_item_id UUID REFERENCES order_items(id) ON DELETE RESTRICT,
    insured_institution_id INTEGER REFERENCES institutions(id) ON DELETE RESTRICT,
    policy_number VARCHAR(50) NOT NULL,
    sum_insured_amount DECIMAL(18, 8) NOT NULL CHECK (sum_insured_amount > 0),
    premium_amount DECIMAL(18, 8) NOT NULL CHECK (premium_amount > 0),
    premium_currency SMALLINT NOT NULL,
    billing_cycle SMALLINT NOT NULL DEFAULT 0,        -- enum_insurance_billing_cycle
    payment_wallet_id UUID,
    payment_wallet_type SMALLINT NOT NULL,
    auto_pay BOOLEAN NOT NULL DEFAULT false,
    coverage_start_at TIMESTAMP WITH TIME ZONE NOT NULL,
    coverage_end_at TIMESTAMP WITH TIME ZONE NOT NULL,
    insurance_policy_status SMALLINT NOT NULL DEFAULT 0,   -- 0=İLK PRİM BEKLİYOR, 1=AKTİF, 2=ÖDEME GECİKTİ, 3=İPTAL, 4=SÜRESİ DOLDU
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    refund_amount DECIMAL(18, 8) CHECK (refund_amount IS NULL OR refund_amount >= 0),
    refund_transaction_id UUID,
    refund_transaction_created_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_ip_issuer_number UNIQUE (issuing_institution_id, policy_number),
    CONSTRAINT uq_ip_id_issuer UNIQUE (id, issuing_institution_id),
    CONSTRAINT fk_ip_listing FOREIGN KEY (listing_id, issuing_institution_id)
        REFERENCES listings (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_ip_product FOREIGN KEY (listing_id, insured_subject_type)
        REFERENCES insurance_product_details (listing_id, insured_subject_type) ON DELETE RESTRICT,
    CONSTRAINT fk_ip_item FOREIGN KEY (order_item_id, listing_id)
        REFERENCES order_items (id, listing_id) ON DELETE RESTRICT,
    CONSTRAINT fk_ip_wallet FOREIGN KEY (payment_wallet_id, payment_wallet_type, premium_currency)
        REFERENCES wallets (id, wallet_type, currency) ON DELETE RESTRICT,
    CONSTRAINT fk_ip_refund_tx FOREIGN KEY (refund_transaction_id, refund_transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT chk_ip_refund_pair CHECK ((refund_transaction_id IS NULL) = (refund_transaction_created_at IS NULL)),
    CONSTRAINT chk_ip_refund_needs_cancel CHECK (refund_amount IS NULL OR cancelled_at IS NOT NULL),
    CONSTRAINT chk_ip_autopay CHECK (auto_pay = false OR payment_wallet_id IS NOT NULL),
    CONSTRAINT chk_policy_dates CHECK (coverage_end_at > coverage_start_at),
    CONSTRAINT chk_ip_subject CHECK (
        (insured_subject_type = 0 AND insured_fixed_asset_id IS NULL AND insured_order_item_id IS NULL AND insured_institution_id IS NULL) OR
        (insured_subject_type = 1 AND insured_fixed_asset_id IS NOT NULL AND insured_user_id IS NULL AND insured_order_item_id IS NULL AND insured_institution_id IS NULL) OR
        (insured_subject_type = 2 AND insured_order_item_id IS NOT NULL AND insured_user_id IS NULL AND insured_fixed_asset_id IS NULL AND insured_institution_id IS NULL) OR
        (insured_subject_type = 3 AND insured_institution_id IS NOT NULL AND insured_user_id IS NULL AND insured_fixed_asset_id IS NULL AND insured_order_item_id IS NULL) ) );
CREATE INDEX IF NOT EXISTS idx_policies_policyholder ON insurance_policies(policyholder_user_id);
CREATE INDEX IF NOT EXISTS idx_policies_insured_user ON insurance_policies(insured_user_id) WHERE insured_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_policies_issuer ON insurance_policies(issuing_institution_id, insurance_policy_status);
CREATE INDEX IF NOT EXISTS idx_policies_asset ON insurance_policies(insured_fixed_asset_id) WHERE insured_fixed_asset_id IS NOT NULL;

-- Police lehtarlari (hayat/kaza branslari icin)
CREATE TABLE IF NOT EXISTS insurance_policy_beneficiaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_id UUID NOT NULL REFERENCES insurance_policies(id) ON DELETE RESTRICT,
    beneficiary_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    share_percentage NUMERIC(9, 8) NOT NULL CHECK (share_percentage > 0 AND share_percentage <= 1),
    relationship_type SMALLINT NOT NULL DEFAULT 0,    -- eş, çocuk, ebeveyn, diğer
    designation_media_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,   -- yazılı lehtar belirleme belgesi
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP );
CREATE UNIQUE INDEX IF NOT EXISTS uq_ipb_active ON insurance_policy_beneficiaries(policy_id, beneficiary_user_id) WHERE is_active;

-- Sigorta urunlerinin prim odeme bilgilerini tutar
CREATE TABLE IF NOT EXISTS insurance_premium_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,                  -- sigortacı (defteri tutan)
    policy_id UUID NOT NULL,
    amount DECIMAL(18, 8) NOT NULL CHECK (amount > 0),
    tax_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    currency SMALLINT NOT NULL,
    due_date DATE NOT NULL,
    attempt_count SMALLINT NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
    paid_at TIMESTAMP WITH TIME ZONE,
    transaction_id UUID,
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    journal_entry_id UUID,
    insurance_premium_payment_status SMALLINT NOT NULL DEFAULT 0,   -- 0=BEKLİYOR, 1=ÖDENDİ, 2=GECİKMİŞ, 3=İPTAL
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ipp_policy FOREIGN KEY (policy_id, institution_id)
        REFERENCES insurance_policies (id, issuing_institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_premium_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT fk_ipp_journal FOREIGN KEY (journal_entry_id, institution_id)
        REFERENCES journal_entries (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_ipp_tx_pair CHECK ((transaction_id IS NULL) = (transaction_created_at IS NULL)),
    CONSTRAINT chk_ipp_paid CHECK (insurance_premium_payment_status <> 1 OR (paid_at IS NOT NULL AND transaction_id IS NOT NULL)),
    CONSTRAINT uq_ipp_policy_due UNIQUE (policy_id, due_date) );
CREATE INDEX IF NOT EXISTS idx_premium_payments_status
    ON insurance_premium_payments(insurance_premium_payment_status) WHERE insurance_premium_payment_status IN (0, 2);

-- Sigorta urunlerinde hasar kayitlarini tutar
CREATE TABLE IF NOT EXISTS insurance_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,                  -- sigortacı
    policy_id UUID NOT NULL,
    claimant_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    claim_number VARCHAR(50) NOT NULL,
    incident_date DATE NOT NULL,
    reported_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    claimed_amount DECIMAL(18, 8) NOT NULL CHECK (claimed_amount > 0),
    approved_amount DECIMAL(18, 8) NOT NULL DEFAULT 0.00 CHECK (approved_amount >= 0),
    currency SMALLINT NOT NULL,
    description TEXT NOT NULL,
    related_order_item_id UUID REFERENCES order_items(id) ON DELETE RESTRICT,
    insurance_claim_status SMALLINT NOT NULL DEFAULT 0,   -- 0=BİLDİRİLDİ, 1=İNCELEMEDE, 2=ONAYLANDI, 3=KISMEN ONAYLANDI, 4=REDDEDİLDİ, 5=ÖDENDİ, 6=İTİRAZLI
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ic_policy FOREIGN KEY (policy_id, institution_id)
        REFERENCES insurance_policies (id, issuing_institution_id) ON DELETE RESTRICT,
    CONSTRAINT uq_ic_institution_number UNIQUE (institution_id, claim_number),
    CONSTRAINT uq_ic_id_institution UNIQUE (id, institution_id),
    CONSTRAINT chk_claim_approved_lte_claimed CHECK (approved_amount <= claimed_amount) );
CREATE INDEX IF NOT EXISTS idx_claims_policy ON insurance_claims(policy_id);
CREATE INDEX IF NOT EXISTS idx_claims_claimant ON insurance_claims(claimant_user_id);
CREATE INDEX IF NOT EXISTS idx_claims_status ON insurance_claims(institution_id, insurance_claim_status);

-- Hasar kanitlari (UUID[] yerine media_assets'e gercek FK)
CREATE TABLE IF NOT EXISTS insurance_claim_evidence (
    claim_id UUID NOT NULL REFERENCES insurance_claims(id) ON DELETE RESTRICT,
    media_asset_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    evidence_type SMALLINT NOT NULL DEFAULT 0,        -- fotoğraf, tutanak, sağlık raporu, fatura, ekspertiz vb.
    is_sensitive BOOLEAN NOT NULL DEFAULT false,      -- sağlık/kişisel veri içeren belge: erişim kısıtlı
    uploaded_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (claim_id, media_asset_id) );

-- Hasar karar gecmisi (sadece ekleme)
CREATE TABLE IF NOT EXISTS insurance_claim_adjudications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    claim_id UUID NOT NULL,
    reviewed_by_worker_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,   -- sigortacının hasar eksperi
    decision SMALLINT NOT NULL DEFAULT 0,             -- 0=İNCELEMEDE, 1=ONAY, 2=KISMİ ONAY, 3=RED, 4=EK BELGE İSTENDİ
    decided_amount DECIMAL(18, 8) CHECK (decided_amount IS NULL OR decided_amount >= 0),
    rejection_reason TEXT,
    notes TEXT,
    decided_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ica_claim FOREIGN KEY (claim_id, institution_id)
        REFERENCES insurance_claims (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_ica_amount CHECK (decision NOT IN (1, 2) OR decided_amount IS NOT NULL),
    CONSTRAINT chk_ica_rejection CHECK (decision <> 3 OR rejection_reason IS NOT NULL) );
CREATE INDEX IF NOT EXISTS idx_adjudications_claim ON insurance_claim_adjudications(claim_id, decided_at DESC);

-- Tazminat odemeleri (sigortacinin cuzdanindan hak sahibine)
CREATE TABLE IF NOT EXISTS insurance_claim_payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id INTEGER NOT NULL,
    claim_id UUID NOT NULL,
    payee_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,   -- hak sahibi (talep eden veya lehtar)
    payout_amount DECIMAL(18, 8) NOT NULL CHECK (payout_amount > 0),
    currency SMALLINT NOT NULL,
    transaction_id UUID,
    transaction_created_at TIMESTAMP WITH TIME ZONE,
    journal_entry_id UUID,
    issued_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    approved_by_user_id INTEGER REFERENCES users(id) ON DELETE RESTRICT,
    insurance_claim_payout_status SMALLINT NOT NULL DEFAULT 0,   -- 0=ONAY BEKLİYOR, 1=ÖDENDİ, 2=İPTAL
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_icp_claim FOREIGN KEY (claim_id, institution_id)
        REFERENCES insurance_claims (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT fk_icp_transaction FOREIGN KEY (transaction_id, transaction_created_at)
        REFERENCES transactions (id, created_at) ON DELETE RESTRICT,
    CONSTRAINT fk_icp_journal FOREIGN KEY (journal_entry_id, institution_id)
        REFERENCES journal_entries (id, institution_id) ON DELETE RESTRICT,
    CONSTRAINT chk_icp_tx_pair CHECK ((transaction_id IS NULL) = (transaction_created_at IS NULL)),
    CONSTRAINT chk_icp_paid CHECK (insurance_claim_payout_status <> 1 OR (transaction_id IS NOT NULL AND paid_at IS NOT NULL)),
    CONSTRAINT chk_icp_two_people CHECK (approved_by_user_id IS NULL OR approved_by_user_id <> issued_by_user_id) );
CREATE INDEX IF NOT EXISTS idx_claim_payouts_claim ON insurance_claim_payouts(claim_id);

-- Not: sync_routing_rules'a yeni bir satır eklediğinizde (yeni tablo), 
-- o tabloya da aynı desenle CREATE TRIGGER ... EXECUTE FUNCTION fn_emit_sync_event(); eklemeniz yeterli.
-- 4. IoT / TELEMETRİ HAM VERİ STAGING (MQTT -> buraya kısa süreli yazılır -> Python worker InfluxDB'ye taşır)
-- (akıllı bina/IoT),(akıllı araç) için.
CREATE TABLE IF NOT EXISTS iot_telemetry_staging (
    id BIGSERIAL PRIMARY KEY,
    device_reference VARCHAR(100) NOT NULL,        -- MQTT topic/cihaz kimliği
    --listing_id UUID REFERENCES listings(id) ON DELETE RESTRICT,
    metric_name VARCHAR(50) NOT NULL,               -- 'TEMPERATURE','FUEL_LEVEL','LOCATION', vb.
    metric_value DOUBLE PRECISION,
    metric_payload JSONB,                            -- karmaşık ölçümler için (örn. {"lat":..,"lng":..})
    received_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    exported_to_influx BOOLEAN NOT NULL DEFAULT false,
    exported_at TIMESTAMP WITH TIME ZONE );
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
    CONSTRAINT unq_bucket_object UNIQUE (bucket_name, object_key));

-- HARİCİ SİSTEM KİMLİK EŞLEMESİ (Postgres id <-> Mongo _id / Neo4j node id — hata ayıklama/geri izleme için)
CREATE TABLE IF NOT EXISTS external_read_model_refs (
    id BIGSERIAL PRIMARY KEY,
    aggregate_type VARCHAR(100) NOT NULL,
    aggregate_id TEXT NOT NULL,
    target_system VARCHAR(20) NOT NULL,             -- 'MONGODB','NEO4J'
    external_ref TEXT NOT NULL,                      -- mongo ObjectId / neo4j node id, string olarak
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unq_external_ref UNIQUE (aggregate_type, aggregate_id, target_system));
CREATE INDEX IF NOT EXISTS idx_external_refs_lookup ON external_read_model_refs (aggregate_type, aggregate_id);

COMMIT;
-- 
-- SADECE TEK BASINA LAZIM OLDUGUNDA KULLANILIR COMMIT ICERISINE ASLA EKLENMEMELI 
-- ACIKLAMA STATUSU DEGISTIRILMEMELI DROP SCHEMA IF EXISTS nolbir_flutter CASCADE;