
create table kv (
    k varchar not null primary key, /* key */
    v jsonb, /* value */
    t timestamp default current_timestamp
);

create table kk (
    f varchar references kv(k) on delete cascade, /* from */
    t varchar references kv(k) on delete cascade, /* to */
    primary key (f,t)
);

create function touch() returns trigger as '
BEGIN
    NEW.t = NOW();
    return NEW;
END;
'LANGUAGE 'plpgsql' IMMUTABLE CALLED ON NULL INPUT SECURITY INVOKER;

create trigger kv_update before update on kv
  for each row execute procedure touch();

create rule delete_kk as on delete to kk
    do update kv set t=NOW() where k=OLD.f or k=OLD.t;

create rule insert_kk as on insert to kk
    do update kv set t=NOW() where k=NEW.f or k=NEW.t;

create rule update_kk as on update to kk
    do update kv set t=NOW() where k=OLD.f or k=OLD.t;

