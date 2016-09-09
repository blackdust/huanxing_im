PlayAuth::User.class_eval  do |variable|
  after_create :set_im_code
  def set_im_code
    # 此时发送请求申请环信im的账号（目前采用授权注册）
    # 在 URL 指定的 org 和 APP 中创建一个新的用户，分两种模式：开放注册和授权注册。
    # “开放注册”模式：注册环信账号时，不用携带管理员身份认证信息；
    # “授权注册”模式：注册环信账号时，必须携带管理员身份认证信息。推荐使用“授权注册”，这样可以防止某些已经获取了注册 URL 和知晓注册流程的人恶意向服务器大量注册垃圾用户。
    str = ImConfigure.get_admin_token
    admin_token = JSON.parse(str)["access_token"]
    command = %~
    curl -X POST -H "Authorization: Bearer #{admin_token}" -i "https://a1.easemob.com/blackdust/huanxin123/users" -d '{"username":"#{self.id}","password":"123456"}'
    ~
    
    str       = `#{command}`
    regex     =  /{.*}/m
    match_str =  regex.match(str)
    p "成功回调创建了子账号"
    # JSON.parse(match_str[0])["entities"][0]["username"]  
  end
end