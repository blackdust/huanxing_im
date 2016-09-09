class ImConfigure
  class << self
    def regularly_get_admin_token
      @@admin_token = `curl -X POST "https://a1.easemob.com/blackdust/huanxin123/token" -d '{"grant_type":"client_credentials","client_id":"","client_secret":""}'`
    end

    def get_admin_token
      @@admin_token
    end 
  end
end

ImConfigure.regularly_get_admin_token