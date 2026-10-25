BEGIN;

CREATE OR REPLACE FUNCTION prevent_hard_delete() RETURNS TRIGGER AS $$ BEGIN
    RAISE EXCEPTION 'Mimaride fiziki silme (DELETE) yasaktır! Soft-delete uygulayınız.';
    RETURN NULL; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_updated_at_column() RETURNS TRIGGER AS $$ BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP; RETURN NEW; END; $$ LANGUAGE plpgsql;

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

COMMIT;