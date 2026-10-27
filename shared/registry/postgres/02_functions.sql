BEGIN;

CREATE OR REPLACE FUNCTION prevent_hard_delete() RETURNS TRIGGER AS $$ BEGIN
    RAISE EXCEPTION 'Mimaride fiziki silme (DELETE) yasaktır! Soft-delete uygulayınız.';
    RETURN NULL; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_updated_at_column() RETURNS TRIGGER AS $$ BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP; RETURN NEW; END; $$ LANGUAGE plpgsql;

-- Satırın kimliği: 'id' kolonu varsa o, yoksa PK kolonlarının ':' ile birleşimi.
CREATE OR REPLACE FUNCTION fn_row_pk(p_relid oid, p_row jsonb) RETURNS text
LANGUAGE sql STABLE AS $$ SELECT COALESCE( p_row ->> 'id',
    (SELECT string_agg(p_row ->> a.attname, ':' ORDER BY k.ord)
        FROM pg_index ix CROSS JOIN LATERAL unnest(ix.indkey) WITH ORDINALITY AS k(attnum, ord)
        JOIN pg_attribute a ON a.attrelid = ix.indrelid AND a.attnum = k.attnum
        WHERE ix.indrelid = p_relid AND ix.indisprimary) ); $$;

-- NUMERIC kolonları JSON sayısından JSON string'e çevirir (ondalık basamaklar korunur).
CREATE OR REPLACE FUNCTION fn_sync_stringify_numerics(p_relid oid, p_row jsonb) RETURNS jsonb
LANGUAGE sql STABLE AS $$ SELECT COALESCE(
    p_row || (SELECT jsonb_object_agg(a.attname, to_jsonb(p_row ->> a.attname)) FROM pg_attribute a
     WHERE a.attrelid = p_relid AND a.attnum > 0 AND NOT a.attisdropped AND a.atttypid = 'numeric'::regtype
     AND jsonb_typeof(p_row -> a.attname) = 'number'), p_row); $$;

CREATE OR REPLACE FUNCTION fn_emit_sync_event() RETURNS trigger
LANGUAGE plpgsql AS $$ DECLARE
    v_targets   TEXT[]; v_excluded  TEXT[] := COALESCE(TG_ARGV, '{}'::text[]);
    v_old       JSONB; v_new JSONB; v_row JSONB; v_pk TEXT; v_outbox_id BIGINT; BEGIN
    SELECT target_systems INTO v_targets
    FROM sync_routing_rules
    WHERE table_name = TG_TABLE_NAME AND is_active;
    IF NOT FOUND OR cardinality(v_targets) = 0 THEN RETURN NULL; END IF;
    IF TG_OP = 'DELETE' THEN v_row := to_jsonb(OLD) - v_excluded;
    ELSE v_new := to_jsonb(NEW) - v_excluded; v_row := v_new;
        IF TG_OP = 'UPDATE' THEN v_old := to_jsonb(OLD) - v_excluded;
            IF v_old = v_new THEN RETURN NULL;   -- senkronize edilen alanlarda değişiklik yok
            END IF; END IF; END IF;
    IF TG_OP = 'DELETE' THEN v_pk := to_jsonb(OLD) ->> 'id';
    ELSE v_pk := to_jsonb(NEW) ->> 'id'; END IF;
    IF v_pk IS NULL THEN SELECT string_agg(
                   (CASE WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD) ELSE to_jsonb(NEW) END) ->> a.attname,
                   ':' ORDER BY k.ord) INTO v_pk FROM pg_index ix
        CROSS JOIN LATERAL unnest(ix.indkey) WITH ORDINALITY AS k(attnum, ord)
        JOIN pg_attribute a ON a.attrelid = ix.indrelid AND a.attnum = k.attnum
        WHERE ix.indrelid = TG_RELID AND ix.indisprimary; END IF;
    INSERT INTO sync_outbox (aggregate_type, aggregate_id, operation, payload, target_systems)
    VALUES (TG_TABLE_NAME, v_pk, TG_OP, v_row, v_targets)
    RETURNING id INTO v_outbox_id;
    PERFORM pg_notify('sync_outbox', v_outbox_id::text); RETURN NULL; END; $$;

CREATE OR REPLACE FUNCTION fn_audit_log() RETURNS trigger
    LANGUAGE plpgsql AS $$ DECLARE v_old JSONB; v_new JSONB; v_id  TEXT;
    v_secrets JSONB; BEGIN IF TG_OP = 'INSERT' THEN
        v_new := to_jsonb(NEW) - 'password_hash' - 'digital_pin';
        v_id  := to_jsonb(NEW) ->> 'id'; ELSIF TG_OP = 'UPDATE' THEN
        v_old := to_jsonb(OLD) - 'password_hash' - 'digital_pin';
        v_new := to_jsonb(NEW) - 'password_hash' - 'digital_pin';
        v_id  := to_jsonb(NEW) ->> 'id';
        SELECT COALESCE(jsonb_agg(k), '[]'::jsonb) INTO v_secrets
        FROM unnest(ARRAY['password_hash', 'digital_pin']) AS k
        WHERE (to_jsonb(OLD) -> k) IS DISTINCT FROM (to_jsonb(NEW) -> k);
        IF v_old = v_new AND jsonb_array_length(v_secrets) = 0 THEN
            RETURN NULL; END IF; IF jsonb_array_length(v_secrets) > 0 THEN
            v_new := v_new || jsonb_build_object('_secrets_changed', v_secrets);
        END IF; ELSE v_old := to_jsonb(OLD) - 'password_hash' - 'digital_pin';
        v_id  := to_jsonb(OLD) ->> 'id'; END IF;
    INSERT INTO audit_logs (table_name, record_id, action, old_data, new_data)
    VALUES (TG_TABLE_NAME, v_id, TG_OP, v_old, v_new);
    RETURN NULL; END; $$; 

--  Defter satırları değiştirilemez (düzeltme = ters kayıt).
CREATE OR REPLACE FUNCTION fn_journal_line_immutable() RETURNS trigger
LANGUAGE plpgsql AS $$ BEGIN
    RAISE EXCEPTION 'Defter satırları değiştirilemez; ters kayıt (reversal) fişi oluşturunuz.';
    RETURN NULL; END; $$;

--  COMMIT anında denetlenir (DEFERRED) — fiş ve satırları aynı transaction'da eklenebilir.
CREATE OR REPLACE FUNCTION fn_journal_entry_check_balanced() RETURNS trigger
LANGUAGE plpgsql AS $$ DECLARE v_cur SMALLINT; v_d   NUMERIC; v_c   NUMERIC; BEGIN
    SELECT currency, SUM(COALESCE(debit_amount, 0)), SUM(COALESCE(credit_amount, 0))
      INTO v_cur, v_d, v_c FROM journal_entry_lines
    WHERE journal_entry_id = NEW.journal_entry_id GROUP BY currency
    HAVING SUM(COALESCE(debit_amount, 0)) <> SUM(COALESCE(credit_amount, 0))
    LIMIT 1; IF FOUND THEN RAISE EXCEPTION 'Fiş dengesiz (fiş: %, para birimi: %, borç: %, alacak: %)',
        NEW.journal_entry_id, v_cur, v_d, v_c; END IF; RETURN NULL; END; $$;
    
--  (chk_debit_credit_mutually_exclusive, iki tutar da NULL olduğunda geçer; burada kapatılır.)
CREATE OR REPLACE FUNCTION fn_journal_line_validate() RETURNS trigger
LANGUAGE plpgsql AS $$ DECLARE
    v_acc_currency SMALLINT; v_acc_active   BOOLEAN; v_cur_active   BOOLEAN; BEGIN
    IF COALESCE(NEW.debit_amount, 0) + COALESCE(NEW.credit_amount, 0) <= 0 THEN
        RAISE EXCEPTION 'Defter satırında borç veya alacak tutarı pozitif olmalıdır (satır: %)', NEW.id; END IF;
    SELECT currency, is_active INTO v_acc_currency, v_acc_active
    FROM chart_of_accounts WHERE id = NEW.account_id;
    IF v_acc_currency IS DISTINCT FROM NEW.currency THEN
        RAISE EXCEPTION 'Satır para birimi (%) hesap para biriminden (%) farklı (hesap id: %)',
            NEW.currency, v_acc_currency, NEW.account_id;
    END IF; IF NOT COALESCE(v_acc_active, false) THEN
        RAISE EXCEPTION 'Pasif hesaba kayıt atılamaz (hesap id: %)', NEW.account_id; END IF;
    SELECT is_active INTO v_cur_active FROM supported_currencies WHERE currency_code = NEW.currency;
    IF NOT COALESCE(v_cur_active, false) THEN
        RAISE EXCEPTION 'Para birimi (%) desteklenmiyor veya işleme kapalı', NEW.currency;
    END IF; RETURN NEW; END; $$;

-- Genel: salt-eklemeli tablo koruması
CREATE OR REPLACE FUNCTION fn_append_only() RETURNS trigger
LANGUAGE plpgsql AS $$ BEGIN
    RAISE EXCEPTION '% tablosu salt-eklemelidir (append-only): kayıt güncellenemez', TG_TABLE_NAME;
    RETURN NULL; END; $$;

CREATE OR REPLACE FUNCTION fn_approval_guard() RETURNS trigger
LANGUAGE plpgsql AS $$ DECLARE
    c_pending CONSTANT SMALLINT := 0; BEGIN IF TG_OP = 'INSERT' THEN
        IF NEW.approval_threshold <= 0 OR NEW.approval_threshold > 1 THEN
            RAISE EXCEPTION 'approval_threshold (0, 1] aralığında olmalıdır (gelen: %)', NEW.approval_threshold;
        END IF; NEW.approval_status := c_pending; NEW.total_weight    := 0;
        NEW.approve_weight  := 0; NEW.reject_weight   := 0;
        RETURN NEW; END IF; IF pg_trigger_depth() = 1 AND (
           NEW.approval_status IS DISTINCT FROM OLD.approval_status
        OR NEW.total_weight    IS DISTINCT FROM OLD.total_weight
        OR NEW.approve_weight  IS DISTINCT FROM OLD.approve_weight
        OR NEW.reject_weight   IS DISTINCT FROM OLD.reject_weight) THEN
        RAISE EXCEPTION 'Onay durumu ve oy ağırlıkları elle değiştirilemez; yalnızca oylama ile değişir (onay: %)', OLD.id; END IF;
    IF NEW.requester_root_id IS DISTINCT FROM OLD.requester_root_id
       OR NEW.requester_role    IS DISTINCT FROM OLD.requester_role
       OR NEW.approval_type     IS DISTINCT FROM OLD.approval_type THEN
        RAISE EXCEPTION 'Onayı isteyen ve onay türü değiştirilemez (onay: %)', OLD.id; END IF;
    IF (NEW.request_data IS DISTINCT FROM OLD.request_data
        OR NEW.approval_threshold IS DISTINCT FROM OLD.approval_threshold)
       AND (OLD.approval_status IS DISTINCT FROM c_pending
            OR EXISTS (SELECT 1 FROM approval_votes WHERE approval_id = OLD.id)) THEN
        RAISE EXCEPTION 'Oylama başladıktan sonra istek içeriği ve eşik değiştirilemez (onay: %)', OLD.id;
    END IF; RETURN NEW; END; $$;
-- Seçmen listesi (approval_eligible_voters): dondurulmuş oy ağırlıkları
--    Yalnızca PENDING ve oylama başlamamış onaya eklenebilir; total_weight burada birikir.
CREATE OR REPLACE FUNCTION fn_eligible_voter_before() RETURNS trigger
LANGUAGE plpgsql AS $$ DECLARE
    c_pending CONSTANT SMALLINT := 0; v_status  SMALLINT; BEGIN
    SELECT approval_status INTO v_status FROM approvals WHERE id = NEW.approval_id;
    IF v_status IS DISTINCT FROM c_pending THEN
        RAISE EXCEPTION 'Sonuçlanmış onaya seçmen eklenemez (onay: %)', NEW.approval_id;
    END IF; IF EXISTS (SELECT 1 FROM approval_votes WHERE approval_id = NEW.approval_id) THEN
        RAISE EXCEPTION 'Oylama başladıktan sonra seçmen eklenemez (onay: %)', NEW.approval_id;
    END IF; RETURN NEW; END; $$;

CREATE OR REPLACE FUNCTION fn_eligible_voter_after() RETURNS trigger
LANGUAGE plpgsql AS $$ BEGIN
    UPDATE approvals SET total_weight = total_weight + NEW.vote_weight WHERE id = NEW.approval_id;
    RETURN NULL; END; $$;

CREATE OR REPLACE FUNCTION fn_vote_before() RETURNS trigger
LANGUAGE plpgsql AS $$ DECLARE
    c_pending CONSTANT SMALLINT := 0; v_status SMALLINT;
    v_expires TIMESTAMPTZ; v_type SMALLINT; v_weight NUMERIC(10,4); BEGIN
    SELECT approval_status, expires_at INTO v_status, v_expires
    FROM approvals WHERE id = NEW.approval_id;
    IF v_status IS DISTINCT FROM c_pending THEN
        RAISE EXCEPTION 'Onay sonuçlanmış, oy kabul edilmez (onay: %)', NEW.approval_id; END IF;
    IF v_expires IS NOT NULL AND v_expires <= clock_timestamp() THEN
        RAISE EXCEPTION 'Onayın süresi dolmuş, oy kabul edilmez (onay: %)', NEW.approval_id; END IF;
    SELECT voter_type, vote_weight INTO v_type, v_weight FROM approval_eligible_voters
    WHERE approval_id = NEW.approval_id AND voter_id = NEW.voter_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Kullanıcı (%) bu onayın seçmen listesinde değil', NEW.voter_id;
    END IF; IF NEW.voter_type IS DISTINCT FROM v_type THEN
        RAISE EXCEPTION 'Seçmen türü uyuşmuyor (kayıtlı: %, gelen: %)', v_type, NEW.voter_type;
    END IF; NEW.vote_weight := v_weight; RETURN NEW; END; $$;

CREATE OR REPLACE FUNCTION fn_vote_after() RETURNS trigger
LANGUAGE plpgsql AS $$ DECLARE
    c_pending  CONSTANT SMALLINT := 0; c_approved CONSTANT SMALLINT := 1; c_rejected CONSTANT SMALLINT := 2;
    v_status SMALLINT; v_app NUMERIC(10,4); v_rej NUMERIC(10,4); v_tot NUMERIC(10,4); v_thr NUMERIC(5,4); v_new SMALLINT; BEGIN
    SELECT approval_status, approve_weight, reject_weight, total_weight, approval_threshold
      INTO v_status, v_app, v_rej, v_tot, v_thr FROM approvals WHERE id = NEW.approval_id FOR UPDATE;
    IF v_status IS DISTINCT FROM c_pending THEN 
    RAISE EXCEPTION 'Onay bu sırada sonuçlandı, oy kabul edilmedi (onay: %)', NEW.approval_id; END IF;
    IF NEW.vote THEN v_app := v_app + NEW.vote_weight; ELSE v_rej := v_rej + NEW.vote_weight; END IF;
    IF v_app >= v_thr * v_tot THEN v_new := c_approved;
    ELSIF v_rej > (1 - v_thr) * v_tot THEN v_new := c_rejected; ELSE v_new := c_pending; END IF;
    UPDATE approvals SET approve_weight = v_app, reject_weight = v_rej, approval_status = v_new
     WHERE id = NEW.approval_id; RETURN NULL; END; $$;

COMMIT;