#!lua name=nolbir_sessions

-- Oturum yönetimi. Tüm işlemler atomiktir (tek FCALL = tek adım).
--
-- Anahtarlar:
--   sess:{sid}              HASH  oturum alanları (TTL'li)
--   user:sessions:{userId}  ZSET  üye=sid, skor=oluşturulma zamanı (ms)
--
-- Yükleme:  redis-cli -x FUNCTION LOAD REPLACE < sessions.lua
--           (veya istemciden: client.function('LOAD', 'REPLACE', kod))

local SESS_PREFIX = 'sess:'

-- KEYS[1]=sess:{sid}  KEYS[2]=user:sessions:{userId}
-- ARGV[1]=ttlSaniye  ARGV[2]=kullanıcı başı azami oturum  ARGV[3]=şimdi(ms)  ARGV[4]=sid
-- ARGV[5..]=alan,değer,alan,değer...   (en az bir çift olmalı)
-- Dönüş: limit aşımı nedeniyle silinen eski oturum sayısı
local function session_create(keys, args)
  local ttl = tonumber(args[1])
  local max = tonumber(args[2])
  local now = tonumber(args[3])
  local sid = args[4]

  redis.call('HSET', keys[1], unpack(args, 5))
  redis.call('EXPIRE', keys[1], ttl)

  -- süresi dolmuş (TTL ile silinmiş) oturumların izlerini temizle
  redis.call('ZREMRANGEBYSCORE', keys[2], '-inf', now - ttl * 1000)
  redis.call('ZADD', keys[2], now, sid)
  redis.call('EXPIRE', keys[2], ttl)

  local count = redis.call('ZCARD', keys[2])
  local evicted = 0
  if count > max then
    local oldest = redis.call('ZRANGE', keys[2], 0, count - max - 1)
    for _, old_sid in ipairs(oldest) do
      redis.call('DEL', SESS_PREFIX .. old_sid)
      redis.call('ZREM', keys[2], old_sid)
      evicted = evicted + 1
    end
  end
  return evicted
end

-- KEYS[1]=sess:{sid}  KEYS[2]=user:sessions:{userId}  ARGV[1]=sid
-- Dönüş: 1 = oturum vardı ve silindi, 0 = yoktu
local function session_revoke(keys, args)
  local removed = redis.call('DEL', keys[1])
  redis.call('ZREM', keys[2], args[1])
  return removed
end

-- KEYS[1]=user:sessions:{userId}
-- Kullanıcı pasife alındığında / şifre değiştiğinde / "tüm cihazlardan çık" denildiğinde.
-- Dönüş: kapatılan oturum sayısı
local function session_revoke_all(keys, args)
  local sids = redis.call('ZRANGE', keys[1], 0, -1)
  for _, sid in ipairs(sids) do
    redis.call('DEL', SESS_PREFIX .. sid)
  end
  redis.call('DEL', keys[1])
  return #sids
end

redis.register_function('nolbir_session_create', session_create)
redis.register_function('nolbir_session_revoke', session_revoke)
redis.register_function('nolbir_session_revoke_all', session_revoke_all)
