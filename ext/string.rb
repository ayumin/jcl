class String

  def each_char
    self.scan(/./) do |c|
      yield c
    end
  end

  # パラメータ文字列をハッシュに変換します。
  #
  # ただし <tt>VOL=SER</tt> キーワードおよび <tt>VOL=AFF</tt> キーワードは
  # それぞれ +VOL_SER+、+VOL_AFF+の名前でハッシュに格納されます。
  #
  # Example:
  #  "ruby".parametize                    # => {'ruby' => nil}
  #  "ruby=fun".parametize                # => {'ruby' => 'fun'}
  #  "ruby=fun,perl=good".parametize      # => {'ruby' => 'fun', 'perl' => 'good'}
  #  "VOL=SER=foo,VOL=AFF=bar".parametize # => {'VOL_SER' => 'foo', 'VOL_AFF' => 'bar'}
  #
  def parametize
    str = ""
    res ={}
    op = 0
    self.gsub(/VOL=SER/,'VOL_SER').gsub(/VOL=AFF/,'VOL_AFF').each_char do |ch|
      if ch == "(" then op += 1 end
      if ch == ")" then op -= 1 end
      if ch == "," and  op == 0 then ch = "|" end
      if ch == "=" and  op == 0 then ch = "-" end
      str << ch
    end
    str.split("|").each do |pair|
      key, val = pair.split("-")
      res[key] = val
    end
    res
  end

end
