
create table kv (
    k varchar not null primary key, /* key */
    v jsonb /* value */
);

create table kk (
    f varchar references kv(k), /* from */
    t varchar references kv(k), /* to */
    primary key (f,t)
);

