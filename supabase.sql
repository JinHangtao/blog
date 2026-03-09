-- 清掉所有舊 policy
DROP POLICY IF EXISTS "anyone can read" ON comments;
DROP POLICY IF EXISTS "anyone can insert" ON comments;
DROP POLICY IF EXISTS "anyone can delete" ON comments;

-- 確保 RLS 開啟
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

-- 違禁詞過濾函數
CREATE OR REPLACE FUNCTION check_banned_words()
RETURNS TRIGGER AS $$
DECLARE
  banned TEXT[] := ARRAY[
    -- 簡體
    '鸡巴','屌','屁眼','阴道','阴茎','阴蒂','阴户',
    '生殖器','睾丸','精液','射精','自慰','手淫',
    '强奸','轮奸','卖淫','妓女','婊子','骚货','荡妇','小妹妹','妹妹','傻逼','出轨',
    '操你妈','干你','肏','傻逼','煞笔','草泥马','卧槽','nmsl','cnm','妹子','姐姐','小姐姐','小姐',
    -- 繁體
    '鷄巴','雞巴','陰道','陰莖','陰蒂','陰戶','出軌',
    '强姦','輪姦','賣淫','騷貨','蕩婦',
    '操你媽','幹你','臥槽','傻屄',
    -- 英文
    'fuck','pussy','cock','dick','bitch','shit','ass','cunt'
  ];
  w TEXT;
  combined TEXT;
BEGIN
  combined := lower(regexp_replace(NEW.name || NEW.message, '\s', '', 'g'));
  FOREACH w IN ARRAY banned LOOP
    IF combined LIKE '%' || lower(w) || '%' THEN
      RAISE EXCEPTION '評論包含不當內容';
    END IF;
  END LOOP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 綁定 trigger
DROP TRIGGER IF EXISTS trigger_check_banned ON comments;
CREATE TRIGGER trigger_check_banned
  BEFORE INSERT ON comments
  FOR EACH ROW
  EXECUTE FUNCTION check_banned_words();
