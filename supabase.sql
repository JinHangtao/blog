-- ── 清掉所有舊 policy ──
DROP POLICY IF EXISTS "anyone can read" ON comments;
DROP POLICY IF EXISTS "anyone can insert" ON comments;
DROP POLICY IF EXISTS "anyone can delete" ON comments;

-- ── 確保 RLS 開啟 ──
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- 讀：所有人可讀
CREATE POLICY "anyone can read" ON comments
  FOR SELECT USING (true);

-- 寫：限制名字和留言長度
CREATE POLICY "anyone can insert" ON comments
  FOR INSERT WITH CHECK (
    length(name) > 0 AND length(name) <= 30 AND
    length(message) > 0 AND length(message) <= 300
  );

-- ── Rate limiting 表 ──
CREATE TABLE IF NOT EXISTS public.comment_rate_limits (
  ip TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_rate_limits_ip_time
  ON public.comment_rate_limits (ip, created_at);

ALTER TABLE public.comment_rate_limits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow insert" ON public.comment_rate_limits;
DROP POLICY IF EXISTS "allow select" ON public.comment_rate_limits;

CREATE POLICY "allow insert" ON public.comment_rate_limits
  FOR INSERT WITH CHECK (true);

CREATE POLICY "allow select" ON public.comment_rate_limits
  FOR SELECT USING (true);

-- ── 違禁詞 + Rate limit 過濾函數 ──
CREATE OR REPLACE FUNCTION check_banned_words()
RETURNS TRIGGER AS $$
DECLARE
  banned TEXT[] := ARRAY[
    '鸡巴','屌','屁眼','阴道','阴茎','阴蒂','阴户',
    '生殖器','睾丸','精液','射精','自慰','手淫',
    '做爱','性交','口交','肛交','3p','援交',
    '鷄巴','雞巴','陰道','陰莖','陰蒂','陰戶',
    '做愛','援交','半套','小姐姐','小妹妹','小妹','阿妹','小姐',
    '卖淫','妓女','嫖娼','妓院','皮条客','鸡女','站街','快餐','全套','特殊服务','上门服务','会所',
    '賣淫','皮條客','雞女','特殊服務','上門服務','會所',
    'escort','prostitute','hooker',
    '出轨','小三','偷情','出軌',
    '技师','按摩女','技師','按摩女',
    '婊子','骚货','荡妇','傻逼','煞笔','脑残','智障','废物','白痴',
    '騷貨','蕩婦','傻屄','腦殘','廢物',
    '死gay','基佬','死肥婆','nmb','nmsl','cnm',
    '操你妈','干你','肏','草泥马','卧槽','去死','死妈',
    '操你媽','幹你','臥槽',
    'fuck','pussy','cock','dick','bitch','shit','cunt','asshole',
    '加微信','加qq','加telegram','私聊','联系我','联系方式',
    '加QQ','加Telegram','私聊','聯繫我'
  ];
  w TEXT;
  combined TEXT;
  recent_count INT;
  client_ip TEXT;
  forwarded TEXT;
BEGIN
  -- 過濾違禁詞（去除所有非字母/漢字字符後比對）
  combined := lower(regexp_replace(NEW.name || NEW.message, '[^a-zA-Z\u4e00-\u9fff]', '', 'g'));
  FOREACH w IN ARRAY banned LOOP
    IF combined LIKE '%' || lower(w) || '%' THEN
      RAISE EXCEPTION '評論包含不當內容';
    END IF;
  END LOOP;

  -- 取 IP（x-forwarded-for 可能有多個，取第一個）
  BEGIN
    forwarded := current_setting('request.headers', true)::json->>'x-forwarded-for';
  EXCEPTION WHEN OTHERS THEN
    forwarded := NULL;
  END;

  IF forwarded IS NOT NULL THEN
    client_ip := trim(split_part(forwarded, ',', 1));
  END IF;

  -- Rate limit：5分鐘內同一 IP 最多 5 條
  IF client_ip IS NOT NULL AND client_ip <> '' THEN
    SELECT COUNT(*) INTO recent_count
    FROM public.comment_rate_limits
    WHERE ip = client_ip
      AND created_at > now() - INTERVAL '5 minutes';

    IF recent_count >= 5 THEN
      RAISE EXCEPTION '留言太頻繁，請稍後再試';
    END IF;

    INSERT INTO public.comment_rate_limits (ip) VALUES (client_ip);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── 綁定 trigger ──
DROP TRIGGER IF EXISTS trigger_check_banned ON comments;
CREATE TRIGGER trigger_check_banned
  BEFORE INSERT ON comments
  FOR EACH ROW
  EXECUTE FUNCTION check_banned_words();

-- ── 定期清理舊 rate limit 記錄 ──
CREATE OR REPLACE FUNCTION clean_rate_limits()
RETURNS void AS $$
BEGIN
  DELETE FROM public.comment_rate_limits
  WHERE created_at < now() - INTERVAL '1 hour';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── 自動排程：每小時清一次（需要 pg_cron extension）──
-- 先開啟 pg_cron（在 Supabase Dashboard > Database > Extensions 搜尋 pg_cron 開啟）
-- 然後執行下面這行：
SELECT cron.schedule('clean-rate-limits', '0 * * * *', 'SELECT clean_rate_limits();');
