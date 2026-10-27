BEGIN;

DROP TRIGGER IF EXISTS trg_users_audit ON users;
CREATE TRIGGER trg_users_audit
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION fn_audit_log();

DROP TRIGGER IF EXISTS trg_users_sync ON users;
CREATE TRIGGER trg_users_sync
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION fn_emit_sync_event(
        'password_hash', 'digital_pin',
        'local_doc_no', 'local_doc_expiry_date', 'global_doc_no', 'global_doc_expiry_date',
        'phone_no', 'birth_date',
        'identity_verified_by_worker_id', 'identity_verification_method',
        'provisioning_status', 'provisioning_error' );

DROP TRIGGER IF EXISTS trg_users_no_delete ON users;
CREATE TRIGGER trg_users_no_delete BEFORE DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION prevent_hard_delete();

DROP TRIGGER IF EXISTS trg_audit_logs_no_delete ON audit_logs;
CREATE TRIGGER trg_audit_logs_no_delete BEFORE DELETE ON audit_logs
    FOR EACH ROW EXECUTE FUNCTION prevent_hard_delete();

DROP TRIGGER IF EXISTS trg_approvals_guard ON approvals;
CREATE TRIGGER trg_approvals_guard
    BEFORE INSERT OR UPDATE ON approvals
    FOR EACH ROW EXECUTE FUNCTION fn_approval_guard();

DROP TRIGGER IF EXISTS trg_approvals_updated_at ON approvals;
CREATE TRIGGER trg_approvals_updated_at
    BEFORE UPDATE ON approvals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trg_journal_lines_validate ON journal_entry_lines;
CREATE TRIGGER trg_journal_lines_validate
    BEFORE INSERT ON journal_entry_lines
    FOR EACH ROW EXECUTE FUNCTION fn_journal_line_validate();

DROP TRIGGER IF EXISTS trg_journal_lines_balanced ON journal_entry_lines;
CREATE CONSTRAINT TRIGGER trg_journal_lines_balanced
    AFTER INSERT ON journal_entry_lines
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fn_journal_entry_check_balanced();

DROP TRIGGER IF EXISTS trg_journal_lines_immutable ON journal_entry_lines;
CREATE TRIGGER trg_journal_lines_immutable
    BEFORE UPDATE ON journal_entry_lines
    FOR EACH ROW EXECUTE FUNCTION fn_journal_line_immutable();

DROP TRIGGER IF EXISTS trg_supported_currencies_sync ON supported_currencies;
CREATE TRIGGER trg_supported_currencies_sync
    AFTER INSERT OR UPDATE ON supported_currencies
    FOR EACH ROW EXECUTE FUNCTION fn_emit_sync_event();

DROP TRIGGER IF EXISTS trg_government_tax_authorities_sync ON government_tax_authorities;
CREATE TRIGGER trg_government_tax_authorities_sync
    AFTER INSERT OR UPDATE ON government_tax_authorities
    FOR EACH ROW EXECUTE FUNCTION fn_emit_sync_event('official_iban_or_account_no');

DROP TRIGGER IF EXISTS trg_tax_rates_and_rules_sync ON tax_rates_and_rules;
CREATE TRIGGER trg_tax_rates_and_rules_sync
    AFTER INSERT OR UPDATE ON tax_rates_and_rules
    FOR EACH ROW EXECUTE FUNCTION fn_emit_sync_event();

DROP TRIGGER IF EXISTS trg_chart_of_accounts_sync ON chart_of_accounts;
CREATE TRIGGER trg_chart_of_accounts_sync
    AFTER INSERT OR UPDATE ON chart_of_accounts
    FOR EACH ROW EXECUTE FUNCTION fn_emit_sync_event('real_world_account_id');

DROP TRIGGER IF EXISTS trg_journal_entries_sync ON journal_entries;
CREATE TRIGGER trg_journal_entries_sync
    AFTER INSERT OR UPDATE ON journal_entries
    FOR EACH ROW EXECUTE FUNCTION fn_emit_sync_event();

DROP TRIGGER IF EXISTS trg_journal_entry_lines_sync ON journal_entry_lines;
CREATE TRIGGER trg_journal_entry_lines_sync
    AFTER INSERT ON journal_entry_lines
    FOR EACH ROW EXECUTE FUNCTION fn_emit_sync_event();

DROP TRIGGER IF EXISTS trg_approvals_sync ON approvals;
CREATE TRIGGER trg_approvals_sync
    AFTER INSERT OR UPDATE ON approvals
    FOR EACH ROW EXECUTE FUNCTION fn_emit_sync_event();

DROP TRIGGER IF EXISTS trg_approval_eligible_voters_sync ON approval_eligible_voters;
CREATE TRIGGER trg_approval_eligible_voters_sync
    AFTER INSERT ON approval_eligible_voters
    FOR EACH ROW EXECUTE FUNCTION fn_emit_sync_event();

DROP TRIGGER IF EXISTS trg_approval_votes_sync ON approval_votes;
CREATE TRIGGER trg_approval_votes_sync
    AFTER INSERT ON approval_votes
    FOR EACH ROW EXECUTE FUNCTION fn_emit_sync_event();

DROP TRIGGER IF EXISTS trg_approval_eligible_voters_before ON approval_eligible_voters;
CREATE TRIGGER trg_approval_eligible_voters_before
    BEFORE INSERT ON approval_eligible_voters
    FOR EACH ROW EXECUTE FUNCTION fn_eligible_voter_before();

DROP TRIGGER IF EXISTS trg_approval_eligible_voters_after ON approval_eligible_voters;
CREATE TRIGGER trg_approval_eligible_voters_after
    AFTER INSERT ON approval_eligible_voters
    FOR EACH ROW EXECUTE FUNCTION fn_eligible_voter_after();

DROP TRIGGER IF EXISTS trg_approval_votes_append_only ON approval_votes;
CREATE TRIGGER trg_approval_votes_append_only
    BEFORE UPDATE ON approval_votes
    FOR EACH ROW EXECUTE FUNCTION fn_append_only();

DROP TRIGGER IF EXISTS trg_approval_eligible_voters_append_only ON approval_eligible_voters;
CREATE TRIGGER trg_approval_eligible_voters_append_only
    BEFORE UPDATE ON approval_eligible_voters
    FOR EACH ROW EXECUTE FUNCTION fn_append_only();

DROP TRIGGER IF EXISTS trg_genesis_audit_log_append_only ON genesis_audit_log;
CREATE TRIGGER trg_genesis_audit_log_append_only
    BEFORE UPDATE ON genesis_audit_log
    FOR EACH ROW EXECUTE FUNCTION fn_append_only();

COMMIT;