PlayAuth::User.class_eval  do |variable|
  after_create :set_im_code
  around_update :set_nick_name?
  def set_im_code
    # 此时发送请求申请环信im的账号（目前采用授权注册）
    # 在 URL 指定的 org 和 APP 中创建一个新的用户，分两种模式：开放注册和授权注册。
    # “开放注册”模式：注册环信账号时，不用携带管理员身份认证信息；
    # “授权注册”模式：注册环信账号时，必须携带管理员身份认证信息。推荐使用“授权注册”，这样可以防止某些已经获取了注册 URL 和知晓注册流程的人恶意向服务器大量注册垃圾用户。
    admin_token = ImConfigure.get_admin_token
    command = %~
    curl -X POST -H "Authorization: Bearer #{admin_token}" -i "https://a1.easemob.com/blackdust/huanxin123/users" -d '{"username":"#{self.id}","password":"123456"}'
    ~
    
    str       = `#{command}`
    regex     =  /{.*}/m
    match_str =  regex.match(str)
    puts "@@@@@@@@@@@@@@@@@@创建子账号"
    puts  match_str
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    # match_str 转json后没有 error的key 算是创建成功 
    # JSON.parse(match_str[0])["entities"][0]["username"]  

    "-> 可以修改昵称(创建昵称)"
    ImConfigure.make_set_nickname(self.id, self.name)
  end

  def set_nick_name?
    if !self.changes["name"].nil?
      nick_name = self.changes["name"][1]
      ImConfigure.make_set_nickname(self.id, nick_name)
    end
  end
end