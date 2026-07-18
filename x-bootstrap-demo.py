import saas_db, saas_accounts as sa, datetime, secrets
c = saas_db.get_conn()
pw = "Demo-" + secrets.token_urlsafe(9)
email = "demo@botlocal.test"
try:
    uid = sa.create_user(c, email, pw, "Demo Owner")
except Exception:
    row = c.execute("SELECT id FROM users WHERE email=?", (email,)).fetchone()
    uid = row[0]
    import hashlib
    # reset password via the same helper used at creation
    c.execute("UPDATE users SET pass_hash=? WHERE id=?", (sa.hash_password(pw) if hasattr(sa,'hash_password') else c.execute("SELECT pass_hash FROM users WHERE id=?", (uid,)).fetchone()[0], uid))
tid = c.execute("SELECT id FROM tenants WHERE slug='demo-co'").fetchone()[0]
c.execute("INSERT OR IGNORE INTO tenant_users(tenant_id,user_id,role,active,created_ts) VALUES(?,?,?,1,?)", (tid, uid, 'owner', datetime.datetime.now(datetime.timezone.utc).isoformat()))
c.commit()
print("EMAIL:", email)
print("PASSWORD:", pw)
print("AUTH_OK:", bool(sa.authenticate(email, pw)))
