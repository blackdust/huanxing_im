class ImConfigure
  class << self
    def regularly_get_admin_token
       str = `curl -X POST "https://a1.easemob.com/#{ENV["HUAN_XIN_USER_NAME"]}/#{ENV["HUAN_XIN_APP_NAME"]}/token" -d '{"grant_type":"client_credentials","client_id":"#{ENV["HUAN_CLIENT_ID"]}","client_secret":"#{ENV["HUAN_CLIENT_SECRET"]}"}'`
       @@admin_token = JSON.parse(str)["access_token"]
    end

    def get_admin_token
      @@admin_token
    end 

    def make_set_nickname(id, nickname)
      command = %~
      curl -X PUT -H "Authorization: Bearer #{@@admin_token}" -i  "https://a1.easemob.com/#{ENV["HUAN_XIN_USER_NAME"]}/#{ENV["HUAN_XIN_APP_NAME"]}/users/#{id}" -d '{"nickname" : "#{nickname}"}'
      ~
      puts "设置昵称结果------------------------"
      puts `#{command}`
      puts "------------------------------------"
    end
  end
end

ImConfigure.regularly_get_admin_token